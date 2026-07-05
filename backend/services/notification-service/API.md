# Notification Service API

Base path: `/api/v1`

All endpoints require JWT (or gateway `X-User-*` headers).

## Notifications

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/notifications?page=&limit=` | Paginated notification list |
| GET | `/notifications/unread-count` | Unread badge count |
| PATCH | `/notifications/{id}/read` | Mark one notification read |
| PATCH | `/notifications/read-all` | Mark all notifications read |

## Device tokens

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/notifications/devices` | Register or update FCM token |
| DELETE | `/notifications/devices/{token}` | Remove FCM token |

### Register device

```json
{ "fcmToken": "...", "platform": "ANDROID" }
```

Platform values: `ANDROID`, `IOS`.

## Notification types

`LIKE`, `COMMENT`, `MENTION`, `FOLLOW`, `CHAT`, `CHAT_REQUEST`, `PAYMENT`, `JOB`.
