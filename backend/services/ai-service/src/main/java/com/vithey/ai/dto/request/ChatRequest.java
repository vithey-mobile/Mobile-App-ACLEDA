package com.vithey.ai.dto.request;

import com.vithey.ai.entity.AiTopic;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.util.UUID;

public record ChatRequest(
    @NotBlank @Size(max = 4000) String message,
    AiTopic topic,
    UUID sessionId,
    @Size(max = 100) String clientMessageId
) {

  public ChatRequest(String message, AiTopic topic, UUID sessionId) {
    this(message, topic, sessionId, null);
  }
}
