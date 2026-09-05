package com.vithey.ai.dto.response;

import com.vithey.ai.entity.AiMessageRole;
import java.time.Instant;
import java.util.UUID;

public record MessageResponse(
    UUID id,
    AiMessageRole role,
    String content,
    Instant createdAt
) {
}
