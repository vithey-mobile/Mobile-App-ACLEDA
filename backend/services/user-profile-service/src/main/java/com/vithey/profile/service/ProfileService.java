package com.vithey.profile.service;

import com.vithey.profile.client.FileServiceClient;
import com.vithey.profile.dto.request.UpdateAvatarRequest;
import com.vithey.profile.dto.request.UpdateProfileRequest;
import com.vithey.profile.dto.response.FileMetadataResponse;
import com.vithey.profile.dto.response.MeProfileResponse;
import com.vithey.profile.dto.response.ProfileResponse;
import com.vithey.profile.entity.Profile;
import com.vithey.profile.entity.UserSettings;
import com.vithey.profile.event.payload.UserRegisteredEvent;
import com.vithey.profile.exception.ApiException;
import com.vithey.profile.exception.ErrorCode;
import com.vithey.profile.mapper.ProfileMapper;
import com.vithey.profile.repository.ProfileRepository;
import com.vithey.profile.repository.UserSettingsRepository;
import com.vithey.profile.util.ApiResponseWrapper;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

@Service
public class ProfileService {

  private final ProfileRepository profileRepository;
  private final UserSettingsRepository userSettingsRepository;
  private final ProfileMapper profileMapper;
  private final FileServiceClient fileServiceClient;
  private final SettingsService settingsService;

  public ProfileService(
      ProfileRepository profileRepository,
      UserSettingsRepository userSettingsRepository,
      ProfileMapper profileMapper,
      FileServiceClient fileServiceClient,
      SettingsService settingsService
  ) {
    this.profileRepository = profileRepository;
    this.userSettingsRepository = userSettingsRepository;
    this.profileMapper = profileMapper;
    this.fileServiceClient = fileServiceClient;
    this.settingsService = settingsService;
  }

  @Transactional(readOnly = true)
  public MeProfileResponse getMyProfile(UUID userId) {
    Profile profile = requireProfile(userId);
    UserSettings settings = settingsService.requireSettings(userId);
    return profileMapper.toMeResponse(profile, settings);
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

  @Transactional
  public ProfileResponse updateAvatar(UUID userId, UpdateAvatarRequest request) {
    Profile profile = requireProfile(userId);
    FileMetadataResponse file = resolveAvatarFile(request.avatarFileId());
    profile.setAvatarFileId(file.fileId());
    profile.setAvatarUrl(file.url());
    return profileMapper.toResponse(profileRepository.save(profile));
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
    if (request.fullName() != null) {
      profile.setFullName(request.fullName());
    }
    if (request.bio() != null) {
      profile.setBio(request.bio());
    }
    if (request.telegramLink() != null) {
      profile.setTelegramLink(request.telegramLink());
    }
    if (request.facebookLink() != null) {
      profile.setFacebookLink(request.facebookLink());
    }
    if (request.university() != null) {
      profile.setUniversity(request.university());
    }
    if (request.major() != null) {
      profile.setMajor(request.major());
    }
    if (request.graduationYear() != null) {
      profile.setGraduationYear(request.graduationYear());
    }
  }
}
