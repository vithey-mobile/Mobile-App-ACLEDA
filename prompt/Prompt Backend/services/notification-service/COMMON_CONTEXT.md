# Notification Service — Common Context

## Service Role
In-app notification storage and Firebase Cloud Messaging (FCM) push delivery.

## Identity
| Item | Value |
|------|-------|
| Eureka name | `notification-service` |
| Port | 8088 |
| Database | `notification_db` |
| Package | `com.vithey.notification` |

## Entities
- `Notification` — id, userId, type, title, body, referenceId, referenceType, isRead, createdAt
- `DeviceToken` — id, userId, fcmToken, platform (ANDROID/IOS), updatedAt

## Notification Types
`LIKE`, `COMMENT`, `MENTION`, `FOLLOW`, `CHAT_REQUEST`, `CHAT_MESSAGE`, `PAYMENT_ALERT`, `JOB_APPLICATION`, `JOB_STATUS`

## Events Consumed (RabbitMQ)
All events from root COMMON_CONTEXT event table.

## External
- Firebase Admin SDK (`firebase-admin`)

## API Prefix
`/api/v1/notifications/**`
