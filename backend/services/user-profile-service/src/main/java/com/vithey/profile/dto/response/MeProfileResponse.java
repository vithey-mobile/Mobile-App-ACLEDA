package com.vithey.profile.dto.response;

import com.vithey.profile.entity.AppLanguage;
import com.vithey.profile.entity.AppTheme;
import java.util.UUID;

public record MeProfileResponse(
    UUID userId,
    String fullName,
    String bio,
    String avatarUrl,
    String telegramLink,
    String facebookLink,
    String university,
    String major,
    Integer graduationYear,
    AppLanguage language,
    AppTheme theme
) {
}
