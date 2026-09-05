package com.vithey.ai.dto.response;

import com.vithey.ai.entity.AiTopic;
import java.util.UUID;

/**
 * Payloads for the {@code POST /api/v1/ai/chat/stream} SSE events.
 *
 * <p>Event order: {@code meta} → zero or more {@code token} → {@code done}.
 * On failure an {@code error} event is sent before the stream completes.
 */
public final class StreamEvents {

  private StreamEvents() {
  }

  /** Sent once, before the first token. */
  public record Meta(
      UUID requestId,
      UUID sessionId,
      UUID userMessageId,
      AiTopic topic
  ) {
  }

  /** Raw text fragment; concatenated fragments form the Markdown reply. */
  public record Token(String content) {
  }

  /** Sent once, after the last token. */
  public record Done(
      UUID requestId,
      UUID sessionId,
      UUID messageId,
      boolean cancelled
  ) {
  }

  /** Sent once, instead of {@code done}, when generation fails. */
  public record Error(String code, String message) {
  }
}
