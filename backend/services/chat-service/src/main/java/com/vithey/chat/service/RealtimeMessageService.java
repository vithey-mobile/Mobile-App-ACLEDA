package com.vithey.chat.service;

import com.vithey.chat.dto.response.MessageResponse;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

@Service
public class RealtimeMessageService {

  private final SimpMessagingTemplate messagingTemplate;

  public RealtimeMessageService(SimpMessagingTemplate messagingTemplate) {
    this.messagingTemplate = messagingTemplate;
  }

  public void deliverToUser(java.util.UUID userId, MessageResponse message) {
    messagingTemplate.convertAndSendToUser(userId.toString(), "/queue/messages", message);
  }
}
