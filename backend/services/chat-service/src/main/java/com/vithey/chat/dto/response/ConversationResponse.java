package com.vithey.chat.dto.response;

import com.vithey.chat.entity.ConversationStatus;
import java.time.OffsetDateTime;
import java.util.UUID;

public record ConversationResponse(
    UUID conversationId,
    ConversationStatus status,
    ParticipantSummaryResponse otherUser,
    String lastMessageText,
    OffsetDateTime lastMessageAt,
    OffsetDateTime updatedAt
) {
}
