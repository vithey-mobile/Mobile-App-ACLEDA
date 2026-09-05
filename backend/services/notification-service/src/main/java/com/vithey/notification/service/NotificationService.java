package com.vithey.notification.service;

import com.vithey.notification.dto.response.NotificationResponse;
import com.vithey.notification.dto.response.UnreadCountResponse;
import com.vithey.notification.entity.Notification;
import com.vithey.notification.entity.NotificationType;
import com.vithey.notification.exception.ApiException;
import com.vithey.notification.exception.ErrorCode;
import com.vithey.notification.mapper.NotificationMapper;
import com.vithey.notification.repository.NotificationRepository;
import com.vithey.notification.util.ApiResponseWrapper;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class NotificationService {

  private static final int MAX_LIMIT = 50;

  private final NotificationRepository notificationRepository;
  private final NotificationMapper notificationMapper;
  private final FcmPushService fcmPushService;

  public NotificationService(
      NotificationRepository notificationRepository,
      NotificationMapper notificationMapper,
      FcmPushService fcmPushService
  ) {
    this.notificationRepository = notificationRepository;
    this.notificationMapper = notificationMapper;
    this.fcmPushService = fcmPushService;
  }

  @Transactional(readOnly = true)
  public ApiResponseWrapper<List<NotificationResponse>> listNotifications(UUID userId, int page, int limit) {
    int safePage = Math.max(page, 1);
    int safeLimit = Math.min(Math.max(limit, 1), MAX_LIMIT);
    PageRequest pageable = PageRequest.of(safePage - 1, safeLimit);

    Page<Notification> notifications = notificationRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable);
    List<NotificationResponse> content = notifications.getContent().stream()
        .map(notificationMapper::toResponse)
        .toList();

    return ApiResponseWrapper.paginated(
        content,
        new ApiResponseWrapper.Meta(safePage, safeLimit, notifications.getTotalElements(), notifications.getTotalPages())
    );
  }

  @Transactional(readOnly = true)
  public UnreadCountResponse unreadCount(UUID userId) {
    return new UnreadCountResponse(notificationRepository.countByUserIdAndReadFalse(userId));
  }

  @Transactional
  public NotificationResponse markRead(UUID notificationId, UUID userId) {
    Notification notification = notificationRepository.findById(notificationId)
        .filter(value -> value.getUserId().equals(userId))
        .orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND));
    notification.setRead(true);
    return notificationMapper.toResponse(notificationRepository.save(notification));
  }

  @Transactional
  public void markAllRead(UUID userId) {
    notificationRepository.markAllRead(userId);
  }

  @Transactional
  public NotificationResponse createAndPush(
      UUID userId,
      NotificationType type,
      String title,
      String body,
      UUID referenceId,
      String referenceType
  ) {
    if (userId == null) {
      return null;
    }

    OffsetDateTime now = OffsetDateTime.now(ZoneOffset.UTC);
    Notification notification = new Notification();
    notification.setId(UUID.randomUUID());
    notification.setUserId(userId);
    notification.setType(type);
    notification.setTitle(title);
    notification.setBody(body);
    notification.setReferenceId(referenceId);
    notification.setReferenceType(referenceType);
    notification.setRead(false);
    notification.setCreatedAt(now);

    Notification saved = notificationRepository.save(notification);
    NotificationResponse response = notificationMapper.toResponse(saved);
    fcmPushService.sendPush(userId, saved.getId(), type, referenceId, title, body);
    return response;
  }
}
