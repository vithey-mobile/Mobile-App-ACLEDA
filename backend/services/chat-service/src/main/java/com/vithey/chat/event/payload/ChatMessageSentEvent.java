package com.vithey.chat.event.payload;

import com.vithey.chat.entity.MessageStatus;
import java.time.OffsetDateTime;
import java.util.UUID;

public record ChatMessageSentEvent(
    UUID messageId,
    UUID conversationId,
    UUID senderId,
    UUID recipientId,
    String text,
    MessageStatus status,
    OffsetDateTime createdAt
) {
}
