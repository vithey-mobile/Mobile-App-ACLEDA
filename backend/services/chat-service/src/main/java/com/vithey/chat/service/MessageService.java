package com.vithey.chat.service;

import com.vithey.chat.dto.request.SendMessageRequest;
import com.vithey.chat.dto.response.MessageResponse;
import com.vithey.chat.entity.Conversation;
import com.vithey.chat.entity.Message;
import com.vithey.chat.entity.MessageStatus;
import com.vithey.chat.event.payload.ChatMessageSentEvent;
import com.vithey.chat.event.publisher.ChatEventPublisher;
import com.vithey.chat.exception.ApiException;
import com.vithey.chat.exception.ErrorCode;
import com.vithey.chat.mapper.ChatMapper;
import com.vithey.chat.repository.ConversationRepository;
import com.vithey.chat.repository.MessageRepository;
import com.vithey.chat.util.ApiResponseWrapper;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class MessageService {

  private static final int MAX_LIMIT = 50;

  private final MessageRepository messageRepository;
  private final ConversationRepository conversationRepository;
  private final ConversationAccessService accessService;
  private final ChatMapper chatMapper;
  private final ChatEventPublisher chatEventPublisher;
  private final RealtimeMessageService realtimeMessageService;

  public MessageService(
      MessageRepository messageRepository,
      ConversationRepository conversationRepository,
      ConversationAccessService accessService,
      ChatMapper chatMapper,
      ChatEventPublisher chatEventPublisher,
      RealtimeMessageService realtimeMessageService
  ) {
    this.messageRepository = messageRepository;
    this.conversationRepository = conversationRepository;
    this.accessService = accessService;
    this.chatMapper = chatMapper;
    this.chatEventPublisher = chatEventPublisher;
    this.realtimeMessageService = realtimeMessageService;
  }

  @Transactional(readOnly = true)
  public ApiResponseWrapper<List<MessageResponse>> listMessages(
      UUID conversationId,
      UUID userId,
      int page,
      int limit
  ) {
    accessService.requireParticipantConversation(conversationId, userId);

    int safePage = Math.max(page, 1);
    int safeLimit = Math.min(Math.max(limit, 1), MAX_LIMIT);
    PageRequest pageable = PageRequest.of(safePage - 1, safeLimit);

    Page<Message> messages = messageRepository.findByConversationIdOrderByCreatedAtDesc(conversationId, pageable);
    List<MessageResponse> content = messages.getContent().stream()
        .map(chatMapper::toMessageResponse)
        .toList();

    return ApiResponseWrapper.paginated(
        content,
        new ApiResponseWrapper.Meta(safePage, safeLimit, messages.getTotalElements(), messages.getTotalPages())
    );
  }

  @Transactional
  public MessageResponse sendMessage(UUID conversationId, UUID senderId, SendMessageRequest request) {
    accessService.requireActiveMessaging(conversationId, senderId);
    UUID recipientId = accessService.findOtherParticipantId(conversationId, senderId);

    OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
    Message message = new Message();
    message.setId(UUID.randomUUID());
    message.setConversationId(conversationId);
    message.setSenderId(senderId);
    message.setText(request.text());
    message.setStatus(MessageStatus.SENT);
    message.setCreatedAt(now);
    Message saved = messageRepository.save(message);

    Conversation conversation = conversationRepository.findById(conversationId)
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND));
    conversation.setUpdatedAt(now);
    conversationRepository.save(conversation);

    MessageResponse response = chatMapper.toMessageResponse(saved);
    realtimeMessageService.deliverToUser(recipientId, response);
    chatEventPublisher.publishMessageSent(new ChatMessageSentEvent(
        saved.getId(),
        saved.getConversationId(),
        saved.getSenderId(),
        recipientId,
        saved.getText(),
        saved.getStatus(),
        saved.getCreatedAt()
    ));
    return response;
  }

  @Transactional
  public MessageResponse markRead(UUID messageId, UUID userId) {
    Message message = messageRepository.findById(messageId)
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND));
    accessService.requireParticipantConversation(message.getConversationId(), userId);
    if (message.getSenderId().equals(userId)) {
      throw new ApiException(ErrorCode.FORBIDDEN, "Sender cannot mark their own message as read");
    }
    message.setStatus(MessageStatus.READ);
    return chatMapper.toMessageResponse(messageRepository.save(message));
  }
}
