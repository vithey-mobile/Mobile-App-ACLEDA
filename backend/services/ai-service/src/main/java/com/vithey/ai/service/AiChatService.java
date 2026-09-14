package com.vithey.ai.service;

import com.vithey.ai.client.GeneralRetrievalClient;
import com.vithey.ai.dto.request.ChatRequest;
import com.vithey.ai.dto.response.ChatResponse;
import com.vithey.ai.dto.response.MessageResponse;
import com.vithey.ai.dto.response.SessionResponse;
import com.vithey.ai.dto.response.StreamEvents;
import com.vithey.ai.entity.AiChatMessage;
import com.vithey.ai.entity.AiChatSession;
import com.vithey.ai.entity.AiMessageRole;
import com.vithey.ai.entity.AiTopic;
import com.vithey.ai.exception.ApiException;
import com.vithey.ai.exception.ErrorCode;
import com.vithey.ai.repository.AiChatMessageRepository;
import com.vithey.ai.repository.AiChatSessionRepository;
import com.vithey.ai.security.CurrentUser;
import com.vithey.ai.support.QueryEnricher;
import com.vithey.ai.util.ApiResponseWrapper;
import com.vithey.ai.util.ApiResponseWrapper.Meta;
import java.io.IOException;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.Executor;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

@Service
public class AiChatService {

  private static final long STREAM_TIMEOUT_MILLIS = 180_000L;
  private static final long TOKEN_DELAY_MILLIS = 20L;
  private static final int MAX_CHUNK_LENGTH = 24;

  private final AiChatSessionRepository sessionRepository;
  private final AiChatMessageRepository messageRepository;
  private final GeneralRetrievalClient generalRetrievalClient;
  private final ChatRequestRegistry requestRegistry;
  private final Executor streamExecutor;

  public AiChatService(
      AiChatSessionRepository sessionRepository,
      AiChatMessageRepository messageRepository,
      GeneralRetrievalClient generalRetrievalClient,
      ChatRequestRegistry requestRegistry,
      @Qualifier("aiStreamExecutor") Executor streamExecutor
  ) {
    this.sessionRepository = sessionRepository;
    this.messageRepository = messageRepository;
    this.generalRetrievalClient = generalRetrievalClient;
    this.requestRegistry = requestRegistry;
    this.streamExecutor = streamExecutor;
  }

  @Transactional
  public ApiResponseWrapper<ChatResponse> chat(CurrentUser user, ChatRequest request) {
    UUID requestId = requestRegistry.register(user.userId());

    PreparedTurn prepared = prepareTurn(user.userId(), request);
    String reply = retrieveReply(request.message(), prepared);
    CompletedTurn completed = completeTurn(prepared, reply);

    requestRegistry.markDone(requestId);

    return ApiResponseWrapper.success(new ChatResponse(
        completed.session().getId(),
        reply,
        prepared.topic(),
        completed.assistantMessage().getId(),
        requestId
    ));
  }

  /**
   * Streams a chat reply as Server-Sent Events ({@code text/event-stream}).
   * Emits {@code meta} → {@code token}* → {@code done}; persists the final
   * assistant message (partial content when the client cancels mid-stream).
   */
  public SseEmitter chatStream(CurrentUser user, ChatRequest request) {
    SseEmitter emitter = new SseEmitter(STREAM_TIMEOUT_MILLIS);
    UUID requestId = requestRegistry.register(user.userId());
    streamExecutor.execute(() -> runStream(user, requestId, request, emitter));
    return emitter;
  }

  void runStream(CurrentUser user, UUID requestId, ChatRequest request, SseEmitter emitter) {
    boolean cancelled = false;
    UUID assistantMessageId = null;
    try {
      PreparedTurn prepared = prepareTurn(user.userId(), request);
      send(emitter, SseEmitter.event()
          .name("meta")
          .data(new StreamEvents.Meta(
              requestId,
              prepared.session().getId(),
              prepared.userMessage().getId(),
              prepared.topic()
          ), MediaType.APPLICATION_JSON));

      String reply = retrieveReply(request.message(), prepared);

      StringBuilder streamed = new StringBuilder();
      for (String chunk : chunkReply(reply)) {
        if (requestRegistry.isCancelled(requestId)) {
          cancelled = true;
          break;
        }
        streamed.append(chunk);
        send(emitter, SseEmitter.event()
            .name("token")
            .data(chunk, MediaType.TEXT_PLAIN));
        Thread.sleep(TOKEN_DELAY_MILLIS);
      }

      String finalContent = streamed.toString();
      if (!finalContent.isBlank() || !cancelled) {
        // Persist the streamed content; when nothing was cancelled and nothing
        // streamed, fall back to the upstream reply so history stays complete.
        CompletedTurn completed = completeTurn(prepared, finalContent.isBlank() ? reply : finalContent);
        assistantMessageId = completed.assistantMessage().getId();
      }

      send(emitter, SseEmitter.event()
          .name("done")
          .data(new StreamEvents.Done(
              requestId,
              prepared.session().getId(),
              assistantMessageId,
              cancelled
          ), MediaType.APPLICATION_JSON));
    } catch (InterruptedException exception) {
      Thread.currentThread().interrupt();
      sendError(emitter, ErrorCode.UPSTREAM_ERROR, "Streaming interrupted");
    } catch (ApiException exception) {
      sendError(emitter, exception.getErrorCode(), exception.getMessage());
    } catch (Exception exception) {
      sendError(emitter, ErrorCode.UPSTREAM_ERROR, "Streaming failed");
    } finally {
      requestRegistry.markDone(requestId);
      emitter.complete();
    }
  }

  /**
   * Regenerates an assistant reply. Owner-only: a message that does not belong
   * to the caller's own session answers {@code 404} without leaking existence.
   */
  @Transactional
  public ApiResponseWrapper<ChatResponse> regenerate(CurrentUser user, UUID messageId) {
    AiChatMessage assistantMessage = messageRepository.findById(messageId)
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND, "Message not found"));

    AiChatSession session = assistantMessage.getSession();
    if (session == null || !session.getUserId().equals(user.userId())) {
      throw new ApiException(ErrorCode.NOT_FOUND, "Message not found");
    }
    if (assistantMessage.getRole() != AiMessageRole.ASSISTANT) {
      throw new ApiException(ErrorCode.VALIDATION_ERROR, "Only assistant messages can be regenerated");
    }

    AiChatMessage userMessage = messageRepository
        .findFirstBySessionIdAndRoleAndCreatedAtBeforeOrderByCreatedAtDesc(
            session.getId(),
            AiMessageRole.USER,
            assistantMessage.getCreatedAt()
        )
        .orElseThrow(() -> new ApiException(ErrorCode.VALIDATION_ERROR, "No user message to regenerate from"));

    String query = QueryEnricher.enrich(userMessage.getContent(), session.getTopic());
    String reply = generalRetrievalClient.retrieve(query, session.getId().toString());

    assistantMessage.setContent(reply);
    messageRepository.save(assistantMessage);

    session.setUpdatedAt(Instant.now());
    sessionRepository.save(session);

    return ApiResponseWrapper.success(new ChatResponse(
        session.getId(),
        reply,
        session.getTopic(),
        assistantMessage.getId()
    ));
  }

  /**
   * Cancels a tracked generation. Unknown ids — or ids owned by another user —
   * answer {@code 404}; already-finished requests answer {@code 204} too.
   */
  public void cancelRequest(CurrentUser user, UUID requestId) {
    ChatRequestRegistry.Entry entry = requestRegistry.find(requestId)
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND, "Unknown chat request"));
    if (!entry.userId().equals(user.userId())) {
      throw new ApiException(ErrorCode.NOT_FOUND, "Unknown chat request");
    }
    requestRegistry.cancel(requestId);
  }

  @Transactional(readOnly = true)
  public ApiResponseWrapper<List<SessionResponse>> listSessions(CurrentUser user, int page, int limit) {
    int safePage = Math.max(page, 1);
    int safeLimit = Math.min(Math.max(limit, 1), 100);
    Page<AiChatSession> sessions = sessionRepository.findByUserIdOrderByUpdatedAtDesc(
        user.userId(),
        PageRequest.of(safePage - 1, safeLimit)
    );

    List<SessionResponse> data = sessions.getContent().stream()
        .map(session -> new SessionResponse(
            session.getId(),
            session.getTopic(),
            session.getTitle(),
            previewForSession(session.getId()),
            session.getCreatedAt(),
            session.getUpdatedAt()
        ))
        .toList();

    return ApiResponseWrapper.paginated(data, new Meta(
        safePage,
        safeLimit,
        sessions.getTotalElements(),
        sessions.getTotalPages()
    ));
  }

  @Transactional(readOnly = true)
  public ApiResponseWrapper<List<MessageResponse>> listMessages(
      CurrentUser user,
      UUID sessionId,
      int page,
      int limit
  ) {
    requireSession(user.userId(), sessionId);

    int safePage = Math.max(page, 1);
    int safeLimit = Math.min(Math.max(limit, 1), 100);
    Page<AiChatMessage> messages = messageRepository.findBySessionIdOrderByCreatedAtAsc(
        sessionId,
        PageRequest.of(safePage - 1, safeLimit)
    );

    List<MessageResponse> data = messages.getContent().stream()
        .map(message -> new MessageResponse(
            message.getId(),
            message.getRole(),
            message.getContent(),
            "complete",
            message.getCreatedAt()
        ))
        .toList();

    return ApiResponseWrapper.paginated(data, new Meta(
        safePage,
        safeLimit,
        messages.getTotalElements(),
        messages.getTotalPages()
    ));
  }

  @Transactional
  public void deleteSession(CurrentUser user, UUID sessionId) {
    AiChatSession session = requireSession(user.userId(), sessionId);
    sessionRepository.delete(session);
  }

  private record PreparedTurn(AiChatSession session, AiTopic topic, AiChatMessage userMessage) {
  }

  private record CompletedTurn(AiChatSession session, AiChatMessage assistantMessage, String reply) {
  }

  private PreparedTurn prepareTurn(UUID userId, ChatRequest request) {
    AiTopic topic = request.topic() == null ? AiTopic.STUDENT : request.topic();
    AiChatSession session = resolveSession(userId, request.sessionId(), topic, request.message());

    AiChatMessage userMessage = new AiChatMessage();
    userMessage.setSession(session);
    userMessage.setRole(AiMessageRole.USER);
    userMessage.setContent(request.message().trim());
    messageRepository.save(userMessage);

    return new PreparedTurn(session, topic, userMessage);
  }

  private String retrieveReply(String message, PreparedTurn prepared) {
    String query = QueryEnricher.enrich(message, prepared.topic());
    return generalRetrievalClient.retrieve(query, prepared.session().getId().toString());
  }

  private CompletedTurn completeTurn(PreparedTurn prepared, String reply) {
    AiChatMessage assistantMessage = new AiChatMessage();
    assistantMessage.setSession(prepared.session());
    assistantMessage.setRole(AiMessageRole.ASSISTANT);
    assistantMessage.setContent(reply);
    messageRepository.save(assistantMessage);

    prepared.session().setUpdatedAt(Instant.now());
    sessionRepository.save(prepared.session());

    return new CompletedTurn(prepared.session(), assistantMessage, reply);
  }

  private List<String> chunkReply(String reply) {
    List<String> chunks = new ArrayList<>();
    if (reply == null || reply.isEmpty()) {
      return chunks;
    }
    for (String part : reply.split("(?<=\\s)")) {
      String piece = part;
      while (piece.length() > MAX_CHUNK_LENGTH) {
        chunks.add(piece.substring(0, MAX_CHUNK_LENGTH));
        piece = piece.substring(MAX_CHUNK_LENGTH);
      }
      if (!piece.isEmpty()) {
        chunks.add(piece);
      }
    }
    return chunks;
  }

  private void send(SseEmitter emitter, SseEmitter.SseEventBuilder event) {
    try {
      emitter.send(event);
    } catch (IOException exception) {
      throw new ApiException(ErrorCode.UPSTREAM_ERROR, "Client disconnected");
    } catch (IllegalStateException exception) {
      throw new ApiException(ErrorCode.UPSTREAM_ERROR, "Stream already completed");
    }
  }

  private void sendError(SseEmitter emitter, ErrorCode errorCode, String message) {
    try {
      emitter.send(SseEmitter.event()
          .name("error")
          .data(new StreamEvents.Error(errorCode.name(), message), MediaType.APPLICATION_JSON));
    } catch (IOException ignored) {
      // Client is gone; nothing to report.
    }
  }

  private AiChatSession resolveSession(UUID userId, UUID sessionId, AiTopic topic, String message) {
    if (sessionId != null) {
      return requireSession(userId, sessionId);
    }

    AiChatSession session = new AiChatSession();
    session.setUserId(userId);
    session.setTopic(topic);
    session.setTitle(buildTitle(message));
    return sessionRepository.save(session);
  }

  private AiChatSession requireSession(UUID userId, UUID sessionId) {
    return sessionRepository.findByIdAndUserId(sessionId, userId)
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND, "Session not found"));
  }

  private String buildTitle(String message) {
    String title = message.strip().replace('\n', ' ');
    if (title.length() > 80) {
      return title.substring(0, 77).strip() + "...";
    }
    return title.isBlank() ? "New chat" : title;
  }

  private String previewForSession(UUID sessionId) {
    return messageRepository
        .findFirstBySessionIdAndRoleOrderByCreatedAtDesc(sessionId, AiMessageRole.ASSISTANT)
        .map(AiChatMessage::getContent)
        .map(this::truncatePreview)
        .orElse("");
  }

  private String truncatePreview(String content) {
    String normalized = content.strip().replace('\n', ' ');
    if (normalized.length() <= 80) {
      return normalized;
    }
    return normalized.substring(0, 77).strip() + "...";
  }
}
