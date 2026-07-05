package com.vithey.notification.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.vithey.notification.entity.Notification;
import com.vithey.notification.exception.ApiException;
import com.vithey.notification.exception.ErrorCode;
import com.vithey.notification.mapper.NotificationMapper;
import com.vithey.notification.repository.NotificationRepository;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class NotificationServiceTest {

  @Mock
  private NotificationRepository notificationRepository;

  @Mock
  private NotificationMapper notificationMapper;

  @Mock
  private FcmPushService fcmPushService;

  @InjectMocks
  private NotificationService notificationService;

  @Test
  void markRead_rejectsForeignNotification() {
    UUID ownerId = UUID.randomUUID();
    UUID otherUserId = UUID.randomUUID();
    UUID notificationId = UUID.randomUUID();

    Notification notification = new Notification();
    notification.setId(notificationId);
    notification.setUserId(ownerId);
    when(notificationRepository.findById(notificationId)).thenReturn(Optional.of(notification));

    ApiException exception = assertThrows(
        ApiException.class,
        () -> notificationService.markRead(notificationId, otherUserId)
    );

    assertEquals(ErrorCode.NOT_FOUND, exception.getErrorCode());
    verify(notificationRepository, never()).save(any());
  }
}
