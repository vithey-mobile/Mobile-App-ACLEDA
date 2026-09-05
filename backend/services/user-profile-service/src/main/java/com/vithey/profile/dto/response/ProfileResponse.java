package com.vithey.profile.dto.response;

import java.util.UUID;

public record ProfileResponse(
    UUID userId,
    String fullName,
    String bio,
    String avatarUrl,
    String telegramLink,
    String facebookLink,
    String university,
    String major,
    Integer graduationYear
) {
}
