package com.vithey.content.dto.response;

import java.util.UUID;

public record AuthorSummaryResponse(
    UUID userId,
    String fullName,
    String avatarUrl
) {
}
