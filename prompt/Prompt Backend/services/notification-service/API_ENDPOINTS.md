# Notification Service — API Endpoints

Base path: `/api/v1`

All endpoints require JWT.

## Notifications

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/notifications?page=&limit=` | Current user's notifications |
| GET | `/notifications/unread-count` | Unread badge count |
| PATCH | `/notifications/{id}/read` | Mark one notification read |
| PATCH | `/notifications/read-all` | Mark all current user's notifications read |

## Device tokens

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/notifications/devices` | Register/update FCM token |
| DELETE | `/notifications/devices/{token}` | Remove FCM token |

## Device request

```json
{ "fcm_token": "...", "platform": "ANDROID" }
```

Platform: `ANDROID`, `IOS`.

## Notification types

`LIKE`, `COMMENT`, `MENTION`, `FOLLOW`, `CHAT`, `CHAT_REQUEST`, `PAYMENT`, `JOB`.

