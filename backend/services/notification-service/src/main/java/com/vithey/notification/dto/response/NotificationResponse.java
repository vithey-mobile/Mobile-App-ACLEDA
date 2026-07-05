package com.vithey.notification.dto.response;

import com.vithey.notification.entity.NotificationType;
import java.time.OffsetDateTime;
import java.util.UUID;

public record NotificationResponse(
    UUID notificationId,
    NotificationType type,
    String title,
    String body,
    UUID referenceId,
    String referenceType,
    boolean isRead,
    OffsetDateTime createdAt
) {
}
