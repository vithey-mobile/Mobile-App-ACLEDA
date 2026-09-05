package com.vithey.chat.controller;

import com.vithey.chat.dto.response.ConversationResponse;
import com.vithey.chat.security.CurrentUserProvider;
import com.vithey.chat.service.ConversationService;
import com.vithey.chat.util.ApiResponseWrapper;
import java.util.List;
import java.util.UUID;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/message-requests")
public class MessageRequestController {

  private final ConversationService conversationService;
  private final CurrentUserProvider currentUserProvider;

  public MessageRequestController(
      ConversationService conversationService,
      CurrentUserProvider currentUserProvider
  ) {
    this.conversationService = conversationService;
    this.currentUserProvider = currentUserProvider;
  }

  @GetMapping
  ResponseEntity<ApiResponseWrapper<List<ConversationResponse>>> listPendingRequests() {
    UUID userId = currentUserProvider.requireCurrentUser().userId();
    return ResponseEntity.ok(ApiResponseWrapper.success(conversationService.listPendingRequests(userId)));
  }
}
