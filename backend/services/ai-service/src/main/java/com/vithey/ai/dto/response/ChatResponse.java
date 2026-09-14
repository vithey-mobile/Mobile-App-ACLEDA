package com.vithey.ai.dto.response;

import com.vithey.ai.entity.AiTopic;
import java.util.UUID;

public record ChatResponse(
    UUID sessionId,
    String reply,
    AiTopic topic,
    UUID messageId,
    UUID requestId
) {

  public ChatResponse(UUID sessionId, String reply, AiTopic topic, UUID messageId) {
    this(sessionId, reply, topic, messageId, null);
  }
}
