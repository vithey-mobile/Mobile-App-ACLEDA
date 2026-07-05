package com.vithey.profile.mapper;

import com.vithey.profile.dto.response.MeProfileResponse;
import com.vithey.profile.dto.response.ProfileResponse;
import com.vithey.profile.dto.response.SettingsResponse;
import com.vithey.profile.dto.response.UserSearchResultResponse;
import com.vithey.profile.entity.Profile;
import com.vithey.profile.entity.UserSettings;
import com.vithey.profile.entity.UserSettings;
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
  @Mapping(target = "language", source = "settings.language")
  @Mapping(target = "theme", source = "settings.theme")
  MeProfileResponse toMeResponse(Profile profile, UserSettings settings);

  UserSearchResultResponse toSearchResult(Profile profile);
}
