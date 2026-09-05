package com.vithey.profile.service;

import com.vithey.profile.client.FileServiceClient;
import com.vithey.profile.dto.request.UpdateAvatarRequest;
import com.vithey.profile.dto.request.UpdateProfileRequest;
import com.vithey.profile.dto.response.FileMetadataResponse;
import com.vithey.profile.dto.response.MeProfileResponse;
import com.vithey.profile.dto.response.ProfileResponse;
import com.vithey.profile.entity.AppLanguage;
import com.vithey.profile.entity.AppTheme;
import com.vithey.profile.entity.Profile;
import com.vithey.profile.event.payload.UserRegisteredEvent;
import com.vithey.profile.exception.ApiException;
import com.vithey.profile.exception.ErrorCode;
import com.vithey.profile.mapper.ProfileMapper;
import com.vithey.profile.repository.LanguageThemeProjection;
import com.vithey.profile.repository.ProfileRepository;
import com.vithey.profile.repository.UserSettingsRepository;
import com.vithey.profile.util.ApiResponseWrapper;
import java.util.Objects;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;
import org.springframework.util.StringUtils;

@Service
public class ProfileService {

  private final ProfileRepository profileRepository;
  private final UserSettingsRepository userSettingsRepository;
  private final ProfileMapper profileMapper;
  private final FileServiceClient fileServiceClient;
  private final SettingsService settingsService;
  private final TransactionTemplate transactionTemplate;

  public ProfileService(
      ProfileRepository profileRepository,
      UserSettingsRepository userSettingsRepository,
      ProfileMapper profileMapper,
      FileServiceClient fileServiceClient,
      SettingsService settingsService,
      PlatformTransactionManager transactionManager
  ) {
    this.profileRepository = profileRepository;
    this.userSettingsRepository = userSettingsRepository;
    this.profileMapper = profileMapper;
    this.fileServiceClient = fileServiceClient;
    this.settingsService = settingsService;
    this.transactionTemplate = new TransactionTemplate(transactionManager);
  }

  @Transactional(readOnly = true)
  public MeProfileResponse getMyProfile(UUID userId) {
    Profile profile = requireProfile(userId);
    LanguageThemeProjection languageTheme = userSettingsRepository.findLanguageThemeByUserId(userId)
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND, "Settings not found"));
    return profileMapper.toMeResponse(
        profile,
        languageTheme.getLanguage() != null ? languageTheme.getLanguage() : AppLanguage.en,
        languageTheme.getTheme() != null ? languageTheme.getTheme() : AppTheme.system
    );
  }

  @Transactional(readOnly = true)
  public ProfileResponse getPublicProfile(UUID userId) {
    return profileMapper.toResponse(requireProfile(userId));
  }

  @Transactional
  public ProfileResponse updateProfile(UUID userId, UpdateProfileRequest request) {
    Profile profile = requireProfile(userId);
    applyProfileUpdates(profile, request);
    return profileMapper.toResponse(profileRepository.save(profile));
  }

  /**
   * Resolves avatar metadata outside the DB transaction so a slow file-service call
   * does not hold a Hikari connection.
   */
  public ProfileResponse updateAvatar(UUID userId, UpdateAvatarRequest request) {
    UUID avatarFileId = request.avatarFileId();
    Profile existing = transactionTemplate.execute(status -> requireProfile(userId));
    if (existing != null && avatarFileId.equals(existing.getAvatarFileId())) {
      return profileMapper.toResponse(existing);
    }

    FileMetadataResponse file = resolveAvatarFile(avatarFileId);
    return transactionTemplate.execute(status -> {
      Profile profile = requireProfile(userId);
      if (file.fileId().equals(profile.getAvatarFileId())
          && Objects.equals(file.url(), profile.getAvatarUrl())) {
        return profileMapper.toResponse(profile);
      }
      profile.setAvatarFileId(file.fileId());
      profile.setAvatarUrl(file.url());
      return profileMapper.toResponse(profileRepository.save(profile));
    });
  }

  @Transactional
  public void createFromRegistration(UserRegisteredEvent event) {
    if (profileRepository.existsById(event.userId())) {
      return;
    }

    Profile profile = new Profile();
    profile.setUserId(event.userId());
    profile.setFullName(StringUtils.hasText(event.fullName()) ? event.fullName() : "Vithey User");
    profileRepository.save(profile);
    settingsService.createDefaultSettings(event.userId());
  }

  private Profile requireProfile(UUID userId) {
    return profileRepository.findById(userId)
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND, "Profile not found"));
  }

  private FileMetadataResponse resolveAvatarFile(UUID fileId) {
    ApiResponseWrapper<FileMetadataResponse> response = fileServiceClient.getFile(fileId);
    if (response == null || response.data() == null) {
      throw new ApiException(ErrorCode.INVALID_FILE);
    }
    return response.data();
  }

  private void applyProfileUpdates(Profile profile, UpdateProfileRequest request) {
    if (request.fullName() != null && !Objects.equals(request.fullName(), profile.getFullName())) {
      profile.setFullName(request.fullName());
    }
    if (request.bio() != null && !Objects.equals(request.bio(), profile.getBio())) {
      profile.setBio(request.bio());
    }
    if (request.telegramLink() != null && !Objects.equals(request.telegramLink(), profile.getTelegramLink())) {
      profile.setTelegramLink(request.telegramLink());
    }
    if (request.facebookLink() != null && !Objects.equals(request.facebookLink(), profile.getFacebookLink())) {
      profile.setFacebookLink(request.facebookLink());
    }
    if (request.university() != null && !Objects.equals(request.university(), profile.getUniversity())) {
      profile.setUniversity(request.university());
    }
    if (request.major() != null && !Objects.equals(request.major(), profile.getMajor())) {
      profile.setMajor(request.major());
    }
    if (request.graduationYear() != null
        && !Objects.equals(request.graduationYear(), profile.getGraduationYear())) {
      profile.setGraduationYear(request.graduationYear());
    }
  }
}
