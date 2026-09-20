# Notification Service — Common Context

## Service Role
In-app notification storage and Firebase Cloud Messaging (FCM) push delivery for the Facebook-style Notification Center UI.

## Identity
| Item | Value |
|------|-------|
| Eureka name | `notification-service` |
| Port | 8088 |
| Database | `notification_db` |
| Package | `com.vithey.notification` |

## Entities
- `Notification` — id, userId, type, event, title, body, actorId, actorName, actorAvatarUrl, destination (JSON), referenceId, referenceType, dedupeKey, isRead, readAt, createdAt
- `DeviceToken` — id, userId, fcmToken, platform (ANDROID/IOS), updatedAt

## Notification Types (API enum)
`LIKE`, `COMMENT`, `MENTION`, `POST_SHARE`, `FOLLOW`, `CHAT`, `CHAT_REQUEST`, `JOB`, `PAYMENT`, `AI`, `SYSTEM`, `STUDENT_VERIFICATION`

## Events Consumed (RabbitMQ)
See `SERVICE_LOGIC.md` and `UPGRADE_FOR_UI.md` event table.

## External
- Firebase Admin SDK (`firebase-admin`)
- Redis (optional unread count cache)

## API Prefix
`/api/v1/notifications/**`

## UI upgrade
Read **`UPGRADE_FOR_UI.md`** before implementing or extending this service.
