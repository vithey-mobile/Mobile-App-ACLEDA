# Notification Service — Complete API Design

> Read `SERVICE_BLUEPRINT.md`, `COMMON_CONTEXT.md`.  
> **Scope:** Backend REST API only — in-app notifications + FCM push.  
> **UI upgrade:** `UPGRADE_FOR_UI.md` (authoritative for V2 contract).

## Identity

| Item | Value |
|------|-------|
| Path | `backend/services/notification-service/` |
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

**Notification:** `id`, `user_id`, `type`, `event`, `title`, `body`, `actor_id`, `actor_name`, `actor_avatar_url`, `destination` (jsonb), `reference_id`, `reference_type`, `dedupe_key`, `is_read`, `read_at`, `created_at`

Types: `LIKE`, `COMMENT`, `MENTION`, `POST_SHARE`, `FOLLOW`, `CHAT`, `CHAT_REQUEST`, `JOB`, `PAYMENT`, `AI`, `SYSTEM`, `STUDENT_VERIFICATION`

**DeviceToken:** `id`, `user_id`, `fcm_token`, `platform` ANDROID|IOS, `created_at` — unique(fcm_token)

## Complete API (all JWT)

| Method | Path | Request | HTTP |
|--------|------|---------|------|
| GET | `/api/v1/notifications` | `?page&limit&is_read` | 200 |
| GET | `/api/v1/notifications/unread-count` | — | 200 |
| PATCH | `/api/v1/notifications/{id}/read` | — | 200 |
| PATCH | `/api/v1/notifications/read-all` | — | 200 |
| DELETE | `/api/v1/notifications/{id}` | — | 204 |
| POST | `/api/v1/notifications/devices` | `{ "fcm_token", "platform" }` | 201 |
| DELETE | `/api/v1/notifications/devices/{token}` | — | 204 |

**Notification list item:**
```json
{
  "id": "uuid",
  "type": "LIKE",
  "event": "reaction.added",
  "title": "New like",
  "body": "Jane liked your post",
  "is_read": false,
  "created_at": "2026-01-01T00:00:00Z",
  "read_at": null,
  "actor": { "id": "uuid", "full_name": "Jane", "avatar_url": "https://..." },
  "destination": { "reference_type": "POST", "reference_id": "post-uuid", "post_id": "post-uuid" },
  "dedupe_key": "reaction.added:reaction-uuid"
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
| `mention.created` | Mentioned user | MENTION |
| `post.shared` | Original author | POST_SHARE |
| `follow.created` | Followed user | FOLLOW |
| `chat.request.received` | Recipient | CHAT_REQUEST |
| `chat.message.sent` | Recipient | CHAT |
| `payment.due` / `payment.overdue` | Student | PAYMENT |
| `job.application.submitted` | Job poster | JOB |
| `job.application.status_changed` | Applicant | JOB |
| `ai.response.ready` | Requesting user | AI |
| `system.announcement` | Target users | SYSTEM |
| `student.verification.updated` | Student | STUDENT_VERIFICATION |

## FCM push logic

On notification insert → load user's device tokens → `FcmPushService.send()` with v2 data map (see `UPGRADE_FOR_UI.md`):
```json
{ "notification_id", "type", "event", "title", "body", "actor_id", "actor_name", "reference_type", "reference_id", "conversation_id", "post_id", "dedupe_key" }
```
Credentials: `vithey.firebase.credentials-path` from config.

## Business logic

| Rule | Logic |
|------|-------|
| Idempotency | Required `dedupe_key` per event; unique `(user_id, dedupe_key)` |
| Read | Only owner can mark read |
| Delete | Only owner can delete; does not delete domain entities |
| Device register | Upsert token for user |
| List filter | `is_read` query param server-side |

## Output

Runnable notification-service on **8088**.
