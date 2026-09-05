package com.vithey.chat.websocket;

import com.vithey.chat.dto.request.ChatSendPayload;
import com.vithey.chat.dto.request.SendMessageRequest;
import com.vithey.chat.dto.response.MessageResponse;
import com.vithey.chat.security.CurrentUser;
import com.vithey.chat.service.MessageService;
import java.security.Principal;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Controller;

@Controller
public class ChatStompController {

  private final MessageService messageService;

  public ChatStompController(MessageService messageService) {
    this.messageService = messageService;
  }

  @MessageMapping("/chat.send")
  public com.vithey.chat.dto.response.MessageResponse send(ChatSendPayload payload, Principal principal) {
    if (!(principal instanceof UsernamePasswordAuthenticationToken auth)
        || !(auth.getPrincipal() instanceof CurrentUser currentUser)) {
      throw new com.vithey.chat.exception.ApiException(com.vithey.chat.exception.ErrorCode.UNAUTHORIZED);
    }
    return messageService.sendMessage(
        payload.conversationId(),
        currentUser.userId(),
        new SendMessageRequest(payload.text())
    );
  }
}
