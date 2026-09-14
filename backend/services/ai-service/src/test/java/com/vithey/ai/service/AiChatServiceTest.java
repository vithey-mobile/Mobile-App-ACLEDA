package com.vithey.ai.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import com.vithey.ai.client.GeneralRetrievalClient;
import com.vithey.ai.dto.request.ChatRequest;
import com.vithey.ai.dto.response.ChatResponse;
import com.vithey.ai.entity.AiChatMessage;
import com.vithey.ai.entity.AiChatSession;
import com.vithey.ai.entity.AiMessageRole;
import com.vithey.ai.entity.AiTopic;
import com.vithey.ai.exception.ApiException;
import com.vithey.ai.exception.ErrorCode;
import com.vithey.ai.repository.AiChatMessageRepository;
import com.vithey.ai.repository.AiChatSessionRepository;
import com.vithey.ai.security.CurrentUser;
import com.vithey.ai.util.ApiResponseWrapper;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.Executor;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

@ExtendWith(MockitoExtension.class)
class AiChatServiceTest {

  @Mock
  private AiChatSessionRepository sessionRepository;

  @Mock
  private AiChatMessageRepository messageRepository;

  @Mock
  private GeneralRetrievalClient generalRetrievalClient;

  @Mock
  private ChatRequestRegistry requestRegistry;

  @Mock
  private Executor streamExecutor;

  @InjectMocks
  private AiChatService aiChatService;

  private CurrentUser user(UUID userId) {
    return new CurrentUser(userId, "user@example.com", List.of("USER"));
  }

  private void stubSaveAssignsIds() {
    when(sessionRepository.save(any())).thenAnswer(invocation -> {
      AiChatSession session = invocation.getArgument(0);
      if (session.getId() == null) {
        session.setId(UUID.randomUUID());
      }
      return session;
    });
    when(messageRepository.save(any())).thenAnswer(invocation -> {
      AiChatMessage message = invocation.getArgument(0);
      if (message.getId() == null) {
        message.setId(UUID.randomUUID());
      }
      return message;
    });
  }

  @Test
  void chatReturnsReplyFromGeneralService() {
    UUID userId = UUID.randomUUID();
    stubSaveAssignsIds();
    when(requestRegistry.register(userId)).thenReturn(UUID.randomUUID());
    when(generalRetrievalClient.retrieve(any(), any())).thenReturn("A good CV should include relevant experience.");

    ApiResponseWrapper<ChatResponse> response = aiChatService.chat(
        user(userId),
        new ChatRequest("How to write a CV?", AiTopic.CV, null)
    );

    assertThat(response.data()).isNotNull();
    assertThat(response.data().reply()).contains("CV");
    assertThat(response.data().topic()).isEqualTo(AiTopic.CV);
    assertThat(response.data().requestId()).isNotNull();
  }

  @Test
  void streamPersistsFinalAssistantMessageAndMarksRequestDone() {
    UUID userId = UUID.randomUUID();
    stubSaveAssignsIds();
    when(requestRegistry.register(userId)).thenReturn(UUID.randomUUID());
    when(generalRetrievalClient.retrieve(any(), any())).thenReturn("Here is a streamed answer.");

    AiChatService service = new AiChatService(
        sessionRepository,
        messageRepository,
        generalRetrievalClient,
        requestRegistry,
        Runnable::run
    );

    SseEmitter emitter = service.chatStream(
        user(userId),
        new ChatRequest("Help with my CV", AiTopic.CV, null)
    );

    assertThat(emitter).isNotNull();
    // One user message + one assistant message persisted.
    verify(messageRepository, times(2)).save(any(AiChatMessage.class));
    verify(messageRepository).save(org.mockito.ArgumentMatchers.argThat(saved ->
        saved.getRole() == AiMessageRole.ASSISTANT
            && "Here is a streamed answer.".equals(saved.getContent())
    ));
    verify(requestRegistry).markDone(any());
  }

  @Test
  void streamStopsWithoutAssistantMessageWhenCancelledImmediately() {
    UUID userId = UUID.randomUUID();
    stubSaveAssignsIds();
    when(requestRegistry.register(userId)).thenReturn(UUID.randomUUID());
    when(requestRegistry.isCancelled(any())).thenReturn(true);
    when(generalRetrievalClient.retrieve(any(), any())).thenReturn("This reply gets cancelled.");

    AiChatService service = new AiChatService(
        sessionRepository,
        messageRepository,
        generalRetrievalClient,
        requestRegistry,
        Runnable::run
    );

    service.chatStream(user(userId), new ChatRequest("Hello", AiTopic.STUDENT, null));

    // Only the user message is persisted; no assistant reply survived the cancel.
    verify(messageRepository, times(1)).save(any(AiChatMessage.class));
    verify(requestRegistry).markDone(any());
  }

  @Test
  void regenerateReplacesAssistantReplyForOwner() {
    UUID userId = UUID.randomUUID();
    UUID messageId = UUID.randomUUID();
    AiChatSession session = ownedSession(userId);
    AiChatMessage assistantMessage = message(messageId, session, AiMessageRole.ASSISTANT, "Old reply");
    assistantMessage.setCreatedAt(Instant.now().minusSeconds(10));
    AiChatMessage userMessage = message(UUID.randomUUID(), session, AiMessageRole.USER, "Help with my CV");
    userMessage.setCreatedAt(assistantMessage.getCreatedAt().minusSeconds(30));

    when(messageRepository.findById(messageId)).thenReturn(Optional.of(assistantMessage));
    when(messageRepository.findFirstBySessionIdAndRoleAndCreatedAtBeforeOrderByCreatedAtDesc(
        any(), any(), any())).thenReturn(Optional.of(userMessage));
    when(generalRetrievalClient.retrieve(any(), any())).thenReturn("Regenerated reply");

    ApiResponseWrapper<ChatResponse> response = aiChatService.regenerate(user(userId), messageId);

    assertThat(response.data().reply()).isEqualTo("Regenerated reply");
    assertThat(response.data().messageId()).isEqualTo(messageId);
    assertThat(assistantMessage.getContent()).isEqualTo("Regenerated reply");
  }

  @Test
  void regenerateRejectsMessageOwnedByAnotherUser() {
    UUID ownerId = UUID.randomUUID();
    UUID messageId = UUID.randomUUID();
    AiChatSession session = ownedSession(ownerId);
    AiChatMessage assistantMessage = message(messageId, session, AiMessageRole.ASSISTANT, "Not yours");
    assistantMessage.setCreatedAt(Instant.now());

    when(messageRepository.findById(messageId)).thenReturn(Optional.of(assistantMessage));

    CurrentUser intruder = new CurrentUser(UUID.randomUUID(), "intruder@example.com", List.of("USER"));

    assertThatThrownBy(() -> aiChatService.regenerate(intruder, messageId))
        .isInstanceOfSatisfying(ApiException.class, exception ->
            assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.NOT_FOUND));

    verify(messageRepository, never()).save(any());
    verifyNoInteractions(generalRetrievalClient);
  }

  @Test
  void regenerateRejectsUnknownMessage() {
    when(messageRepository.findById(any())).thenReturn(Optional.empty());

    assertThatThrownBy(() -> aiChatService.regenerate(user(UUID.randomUUID()), UUID.randomUUID()))
        .isInstanceOfSatisfying(ApiException.class, exception ->
            assertThat(exception.getErrorCode()).isEqualTo(ErrorCode.NOT_FOUND));
  }

  private AiChatSession ownedSession(UUID userId) {
    AiChatSession session = new AiChatSession();
    session.setId(UUID.randomUUID());
    session.setUserId(userId);
    session.setTopic(AiTopic.CV);
    session.setTitle("Session");
    return session;
  }

  private AiChatMessage message(UUID id, AiChatSession session, AiMessageRole role, String content) {
    AiChatMessage message = new AiChatMessage();
    message.setId(id);
    message.setSession(session);
    message.setRole(role);
    message.setContent(content);
    message.setCreatedAt(Instant.now());
    return message;
  }
}
