package com.vithey.notification.service;

import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import com.vithey.notification.entity.NotificationType;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class FcmPushService {

  private static final Logger log = LoggerFactory.getLogger(FcmPushService.class);

  private final DeviceTokenService deviceTokenService;

  public FcmPushService(DeviceTokenService deviceTokenService) {
    this.deviceTokenService = deviceTokenService;
  }

  public void sendPush(
      UUID userId,
      UUID notificationId,
      NotificationType type,
      UUID referenceId,
      String title,
      String body
  ) {
    if (FirebaseApp.getApps().isEmpty()) {
      log.debug("Firebase not configured; skipping push for user {}", userId);
      return;
    }

    List<String> tokens = deviceTokenService.findTokensForUser(userId);
    if (tokens.isEmpty()) {
      return;
    }

    Map<String, String> data = new HashMap<>();
    data.put("notification_id", notificationId.toString());
    data.put("type", type.name());
    if (referenceId != null) {
      data.put("reference_id", referenceId.toString());
    }
    data.put("title", title);
    data.put("body", body);

    for (String token : tokens) {
      try {
        Message message = Message.builder()
            .setToken(token)
            .setNotification(Notification.builder().setTitle(title).setBody(body).build())
            .putAllData(data)
            .build();
        FirebaseMessaging.getInstance().send(message);
      } catch (Exception exception) {
        log.warn("FCM push failed for user {} token {}", userId, token, exception);
      }
    }
  }
}
