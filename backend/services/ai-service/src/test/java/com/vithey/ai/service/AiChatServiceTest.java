package com.vithey.ai.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

import com.vithey.ai.client.GeneralRetrievalClient;
import com.vithey.ai.dto.request.ChatRequest;
import com.vithey.ai.dto.response.ChatResponse;
import com.vithey.ai.entity.AiChatMessage;
import com.vithey.ai.entity.AiChatSession;
import com.vithey.ai.entity.AiTopic;
import com.vithey.ai.repository.AiChatMessageRepository;
import com.vithey.ai.repository.AiChatSessionRepository;
import com.vithey.ai.security.CurrentUser;
import com.vithey.ai.util.ApiResponseWrapper;
import java.util.List;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class AiChatServiceTest {

  @Mock
  private AiChatSessionRepository sessionRepository;

  @Mock
  private AiChatMessageRepository messageRepository;

  @Mock
  private GeneralRetrievalClient generalRetrievalClient;

  @InjectMocks
  private AiChatService aiChatService;

  @Test
  void chatReturnsReplyFromGeneralService() {
    UUID userId = UUID.randomUUID();
    CurrentUser user = new CurrentUser(userId, "user@example.com", List.of("USER"));

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
    when(generalRetrievalClient.retrieve(any(), any())).thenReturn("A good CV should include relevant experience.");

    ApiResponseWrapper<ChatResponse> response = aiChatService.chat(
        user,
        new ChatRequest("How to write a CV?", AiTopic.CV, null)
    );

    assertThat(response.data()).isNotNull();
    assertThat(response.data().reply()).contains("CV");
    assertThat(response.data().topic()).isEqualTo(AiTopic.CV);
  }
}
