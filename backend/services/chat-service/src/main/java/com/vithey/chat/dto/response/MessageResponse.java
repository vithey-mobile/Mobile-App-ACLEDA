package com.vithey.chat.dto.response;

import com.vithey.chat.entity.MessageStatus;
import java.time.OffsetDateTime;
import java.util.UUID;

public record MessageResponse(
    UUID messageId,
    UUID conversationId,
    UUID senderId,
    String text,
    MessageStatus status,
    OffsetDateTime createdAt
) {
}
