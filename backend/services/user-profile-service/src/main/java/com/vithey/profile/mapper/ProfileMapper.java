package com.vithey.profile.mapper;

import com.vithey.profile.dto.response.MeProfileResponse;
import com.vithey.profile.dto.response.ProfileResponse;
import com.vithey.profile.entity.AppLanguage;
import com.vithey.profile.entity.AppTheme;
import com.vithey.profile.entity.Profile;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface ProfileMapper {

  ProfileResponse toResponse(Profile profile);

  @Mapping(target = "userId", source = "profile.userId")
  @Mapping(target = "fullName", source = "profile.fullName")
  @Mapping(target = "bio", source = "profile.bio")
  @Mapping(target = "avatarUrl", source = "profile.avatarUrl")
  @Mapping(target = "telegramLink", source = "profile.telegramLink")
  @Mapping(target = "facebookLink", source = "profile.facebookLink")
  @Mapping(target = "university", source = "profile.university")
  @Mapping(target = "major", source = "profile.major")
  @Mapping(target = "graduationYear", source = "profile.graduationYear")
  @Mapping(target = "language", source = "language")
  @Mapping(target = "theme", source = "theme")
  MeProfileResponse toMeResponse(Profile profile, AppLanguage language, AppTheme theme);
}
