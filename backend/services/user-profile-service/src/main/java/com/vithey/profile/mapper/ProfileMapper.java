package com.vithey.profile.mapper;

import com.vithey.profile.dto.response.MeProfileResponse;
import com.vithey.profile.dto.response.ProfileSkillResponse;
import com.vithey.profile.dto.response.UserSearchResultResponse;
import com.vithey.profile.entity.Profile;
import com.vithey.profile.entity.ProfileSkillEntry;
import com.vithey.profile.entity.UserSettings;
import java.util.List;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.springframework.util.StringUtils;

@Mapper(componentModel = "spring")
public interface ProfileMapper {

  @Mapping(target = "userId", source = "profile.userId")
  @Mapping(target = "fullName", source = "profile.fullName")
  @Mapping(target = "bio", source = "profile.bio")
  @Mapping(target = "avatarUrl", source = "profile.avatarUrl")
  @Mapping(target = "telegramLink", source = "profile.telegramLink")
  @Mapping(target = "facebookLink", source = "profile.facebookLink")
  @Mapping(target = "university", source = "profile.university")
  @Mapping(target = "major", source = "profile.major")
  @Mapping(target = "graduationYear", source = "profile.graduationYear")
  @Mapping(target = "location", source = "profile.location")
  @Mapping(target = "dateOfBirth", source = "profile.dateOfBirth")
  @Mapping(target = "workplace", source = "profile.workplace")
  @Mapping(target = "portfolioUrl", source = "profile.portfolioUrl")
  @Mapping(target = "phone", source = "profile.phone")
  @Mapping(target = "email", source = "profile.email")
  @Mapping(target = "skills", expression = "java(mapSkillEntries(profile.getSkills()))")
  @Mapping(target = "education", source = "profile.education")
  @Mapping(target = "fieldVisibility", source = "profile.fieldVisibility")
  @Mapping(target = "language", source = "settings.language")
  @Mapping(target = "theme", source = "settings.theme")
  MeProfileResponse toMeResponse(Profile profile, UserSettings settings);

  @Mapping(target = "userId", source = "userId")
  @Mapping(target = "fullName", source = "fullName")
  @Mapping(target = "avatarUrl", source = "avatarUrl")
  @Mapping(target = "university", source = "university")
  @Mapping(target = "major", source = "major")
  @Mapping(target = "headline", expression = "java(buildSearchHeadline(profile))")
  UserSearchResultResponse toSearchResult(Profile profile);

  default String buildSearchHeadline(Profile profile) {
    if (profile == null) {
      return null;
    }
    if (StringUtils.hasText(profile.getWorkplace())) {
      return profile.getWorkplace();
    }
    if (StringUtils.hasText(profile.getMajor()) && StringUtils.hasText(profile.getUniversity())) {
      return profile.getMajor() + " · " + profile.getUniversity();
    }
    if (StringUtils.hasText(profile.getMajor())) {
      return profile.getMajor();
    }
    if (StringUtils.hasText(profile.getUniversity())) {
      return profile.getUniversity();
    }
    return null;
  }

  default List<ProfileSkillResponse> mapSkillEntries(List<ProfileSkillEntry> skills) {
    if (skills == null || skills.isEmpty()) {
      return List.of();
    }
    return skills.stream()
        .map(skill -> new ProfileSkillResponse(skill.name(), skill.proficiency()))
        .toList();
  }
}
