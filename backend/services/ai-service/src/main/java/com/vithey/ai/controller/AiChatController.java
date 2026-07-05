package com.vithey.ai.controller;

import com.vithey.ai.dto.request.ChatRequest;
import com.vithey.ai.dto.response.ChatResponse;
import com.vithey.ai.dto.response.MessageResponse;
import com.vithey.ai.dto.response.SessionResponse;
import com.vithey.ai.security.CurrentUserProvider;
import com.vithey.ai.service.AiChatService;
import com.vithey.ai.util.ApiResponseWrapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/ai")
@Tag(name = "AI Chat")
public class AiChatController {

  private final AiChatService aiChatService;
  private final CurrentUserProvider currentUserProvider;

  public AiChatController(AiChatService aiChatService, CurrentUserProvider currentUserProvider) {
    this.aiChatService = aiChatService;
    this.currentUserProvider = currentUserProvider;
  }

  @PostMapping("/chat")
  @Operation(summary = "Send chatbot message")
  public ApiResponseWrapper<ChatResponse> chat(@Valid @RequestBody ChatRequest request) {
    return aiChatService.chat(currentUserProvider.requireCurrentUser(), request);
  }

  @GetMapping("/sessions")
  @Operation(summary = "List chat sessions")
  public ApiResponseWrapper<List<SessionResponse>> listSessions(
      @RequestParam(defaultValue = "1") int page,
      @RequestParam(defaultValue = "20") int limit
  ) {
    return aiChatService.listSessions(currentUserProvider.requireCurrentUser(), page, limit);
  }

  @GetMapping("/sessions/{sessionId}/messages")
  @Operation(summary = "List session messages")
  public ApiResponseWrapper<List<MessageResponse>> listMessages(
      @PathVariable UUID sessionId,
      @RequestParam(defaultValue = "1") int page,
      @RequestParam(defaultValue = "20") int limit
  ) {
    return aiChatService.listMessages(currentUserProvider.requireCurrentUser(), sessionId, page, limit);
  }

  @DeleteMapping("/sessions/{sessionId}")
  @Operation(summary = "Delete chat session")
  public ResponseEntity<Void> deleteSession(@PathVariable UUID sessionId) {
    aiChatService.deleteSession(currentUserProvider.requireCurrentUser(), sessionId);
    return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
  }
}
