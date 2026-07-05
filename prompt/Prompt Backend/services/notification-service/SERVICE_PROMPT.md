# Notification Service — Complete API Design

> Read `SERVICE_BLUEPRINT.md`, `COMMON_CONTEXT.md`.  
> **Scope:** Backend REST API only — in-app notifications + FCM push.

## Identity

| Item | Value |
|------|-------|
| Path | `vithey-backend/services/notification-service/` |
| Port | 8088 |
| Eureka | `notification-service` |
| Database | `notification_db` |
| Package | `com.vithey.notification` |

## Spring Cloud + tools

Eureka, Config, RabbitMQ listeners, **Firebase Admin SDK**, JPA, Flyway.

## Folder structure

```text
services/notification-service/
└── src/main/java/com/vithey/notification/
    ├── NotificationServiceApplication.java
    ├── config/FirebaseConfig.java, RabbitMqConfig.java, SecurityConfig.java, OpenApiConfig.java
    ├── controller/NotificationController.java, DeviceTokenController.java
    ├── service/NotificationService.java, FcmPushService.java, DeviceTokenService.java
    ├── repository/NotificationRepository.java, DeviceTokenRepository.java
    ├── entity/Notification.java, DeviceToken.java
    ├── dto/request/RegisterDeviceRequest.java
    ├── dto/response/NotificationResponse.java, UnreadCountResponse.java
    ├── event/listener/
    │   ├── ContentEventListener.java      # comment, reaction, follow, mention
    │   ├── ChatEventListener.java
    │   ├── CareerEventListener.java
    │   ├── FinanceEventListener.java
    │   └── UserEventListener.java
    ├── event/mapper/EventToNotificationMapper.java
    └── exception/GlobalExceptionHandler.java
```

## Database

**Notification:** `id`, `user_id`, `type` LIKE|COMMENT|MENTION|FOLLOW|CHAT|CHAT_REQUEST|PAYMENT|JOB, `title`, `body`, `reference_id`, `reference_type`, `is_read`, `created_at`

**DeviceToken:** `id`, `user_id`, `fcm_token`, `platform` ANDROID|IOS, `created_at` — unique(fcm_token)

## Complete API (all JWT)

| Method | Path | Request | HTTP |
|--------|------|---------|------|
| GET | `/api/v1/notifications` | `?page&limit` | 200 |
| GET | `/api/v1/notifications/unread-count` | — | 200 |
| PATCH | `/api/v1/notifications/{id}/read` | — | 200 |
| PATCH | `/api/v1/notifications/read-all` | — | 200 |
| POST | `/api/v1/notifications/devices` | `{ "fcm_token", "platform" }` | 201 |
| DELETE | `/api/v1/notifications/devices/{token}` | — | 204 |

**Notification list item:**
```json
{
  "notification_id": "uuid",
  "type": "LIKE",
  "title": "New like",
  "body": "Jane liked your post",
  "reference_id": "post-uuid",
  "reference_type": "POST",
  "is_read": false,
  "created_at": "2026-01-01T00:00:00Z"
}
```

**Unread count:**
```json
{ "data": { "count": 5 } }
```

## Event listeners → notifications

| Event | Notify | Type |
|-------|--------|------|
| `comment.added` | Post author | COMMENT |
| `reaction.added` | Post author | LIKE |
| `follow.created` | Followed user | FOLLOW |
| `mention.created` | Mentioned user | MENTION |
| `chat.request.received` | Recipient | CHAT_REQUEST |
| `chat.message.sent` | Recipient (if offline) | CHAT |
| `payment.due` / `payment.overdue` | Student | PAYMENT |
| `job.application.submitted` | Job poster | JOB |
| `job.application.status_changed` | Applicant | JOB |

## FCM push logic

On notification insert → load user's device tokens → `FcmPushService.send()` with payload:
```json
{ "notification_id", "type", "reference_id", "title", "body" }
```
Credentials: `vithey.firebase.credentials-path` from config.

## Business logic

| Rule | Logic |
|------|-------|
| Idempotency | Optional dedupe key per event+user |
| Read | Only owner can mark read |
| Device register | Upsert token for user |

## Output

Runnable notification-service on **8088**.
