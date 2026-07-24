package com.vithey.profile.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

import com.vithey.profile.dto.response.MeProfileResponse;
import com.vithey.profile.entity.AppLanguage;
import com.vithey.profile.entity.AppTheme;
import com.vithey.profile.entity.Profile;
import com.vithey.profile.mapper.ProfileMapper;
import com.vithey.profile.mapper.ProfileMapperImpl;
import com.vithey.profile.repository.LanguageThemeProjection;
import com.vithey.profile.repository.ProfileRepository;
import com.vithey.profile.repository.UserSettingsRepository;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Spy;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.transaction.PlatformTransactionManager;

@ExtendWith(MockitoExtension.class)
class ProfileServiceTest {

  @Mock
  private ProfileRepository profileRepository;

  @Mock
  private UserSettingsRepository userSettingsRepository;

  @Spy
  private ProfileMapper profileMapper = new ProfileMapperImpl();

  @Mock
  private com.vithey.profile.client.FileServiceClient fileServiceClient;

  @Mock
  private SettingsService settingsService;

  @Mock
  private PlatformTransactionManager transactionManager;

  @InjectMocks
  private ProfileService profileService;

  @Test
  void getMyProfileReturnsProfileAndSettingsSummary() {
    UUID userId = UUID.randomUUID();
    Profile profile = new Profile();
    profile.setUserId(userId);
    profile.setFullName("Jane Doe");

    LanguageThemeProjection languageTheme = new LanguageThemeProjection() {
      @Override
      public AppLanguage getLanguage() {
        return AppLanguage.km;
      }

      @Override
      public AppTheme getTheme() {
        return AppTheme.dark;
      }
    };

    when(profileRepository.findById(userId)).thenReturn(Optional.of(profile));
    when(userSettingsRepository.findLanguageThemeByUserId(userId)).thenReturn(Optional.of(languageTheme));

    MeProfileResponse response = profileService.getMyProfile(userId);

    assertThat(response.userId()).isEqualTo(userId);
    assertThat(response.fullName()).isEqualTo("Jane Doe");
    assertThat(response.language()).isEqualTo(AppLanguage.km);
    assertThat(response.theme()).isEqualTo(AppTheme.dark);
  }
}
