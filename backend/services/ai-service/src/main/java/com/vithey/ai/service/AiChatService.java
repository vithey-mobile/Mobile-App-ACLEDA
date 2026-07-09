package com.vithey.ai.service;

import com.vithey.ai.client.GeneralRetrievalClient;
import com.vithey.ai.dto.request.ChatRequest;
import com.vithey.ai.dto.response.ChatResponse;
import com.vithey.ai.dto.response.MessageResponse;
import com.vithey.ai.dto.response.SessionResponse;
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
import java.util.List;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AiChatService {

  private final AiChatSessionRepository sessionRepository;
  private final AiChatMessageRepository messageRepository;
  private final GeneralRetrievalClient generalRetrievalClient;

  public AiChatService(
      AiChatSessionRepository sessionRepository,
      AiChatMessageRepository messageRepository,
      GeneralRetrievalClient generalRetrievalClient
  ) {
    this.sessionRepository = sessionRepository;
    this.messageRepository = messageRepository;
    this.generalRetrievalClient = generalRetrievalClient;
  }

  @Transactional
  public ApiResponseWrapper<ChatResponse> chat(CurrentUser user, ChatRequest request) {
    AiTopic topic = request.topic() == null ? AiTopic.STUDENT : request.topic();
    AiChatSession session = resolveSession(user.userId(), request.sessionId(), topic, request.message());

    AiChatMessage userMessage = new AiChatMessage();
    userMessage.setSession(session);
    userMessage.setRole(AiMessageRole.USER);
    userMessage.setContent(request.message().trim());
    messageRepository.save(userMessage);

    String query = QueryEnricher.enrich(request.message(), topic);
    String reply = generalRetrievalClient.retrieve(query, session.getId().toString());

    AiChatMessage assistantMessage = new AiChatMessage();
    assistantMessage.setSession(session);
    assistantMessage.setRole(AiMessageRole.ASSISTANT);
    assistantMessage.setContent(reply);
    messageRepository.save(assistantMessage);

    session.setUpdatedAt(java.time.Instant.now());
    sessionRepository.save(session);

    return ApiResponseWrapper.success(new ChatResponse(
        session.getId(),
        reply,
        topic,
        assistantMessage.getId()
    ));
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
