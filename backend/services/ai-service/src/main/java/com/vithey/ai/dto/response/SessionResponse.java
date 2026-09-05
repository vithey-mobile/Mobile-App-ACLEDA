package com.vithey.ai.dto.response;

import com.vithey.ai.entity.AiTopic;
import java.time.Instant;
import java.util.UUID;

public record SessionResponse(
    UUID id,
    AiTopic topic,
    String title,
    Instant createdAt,
    Instant updatedAt
) {
}
