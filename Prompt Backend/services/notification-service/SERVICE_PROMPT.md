# Notification Service — Service Prompt

Build the Notification microservice.

## API Endpoints
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/v1/notifications` | JWT | Paginated notifications |
| GET | `/api/v1/notifications/unread-count` | JWT | Unread badge count |
| PATCH | `/api/v1/notifications/{id}/read` | JWT | Mark one as read |
| PATCH | `/api/v1/notifications/read-all` | JWT | Mark all read |
| POST | `/api/v1/notifications/devices` | JWT | Register FCM device token |
| DELETE | `/api/v1/notifications/devices/{token}` | JWT | Unregister device |

## Notification Response
```json
{
  "data": [
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
  ],
  "meta": { "page": 1, "limit": 20, "total": 42, "total_pages": 3 }
}
```

## Event Listeners
Create `@RabbitListener` for each event:
| Event | Action |
|-------|--------|
| `comment.added` | Notify post author |
| `reaction.added` | Notify post author |
| `follow.created` | Notify followed user |
| `mention.created` | Notify mentioned user |
| `chat.request.received` | Notify recipient |
| `chat.message.sent` | Notify recipient (if not active) |
| `payment.due` | Notify student |
| `job.application.submitted` | Notify job poster |
| `job.application.status_changed` | Notify applicant |

## FCM Push
- On notification create → send FCM to user's registered device tokens
- Payload: `{ "notification_id", "type", "reference_id", "title", "body" }`
- Firebase credentials from env: `FIREBASE_CREDENTIALS_PATH`

## Device Register Request
```json
{
  "fcm_token": "device-token",
  "platform": "ANDROID"
}
```

## Required Modules
- `NotificationController`, `DeviceTokenController`
- `NotificationService`, `FcmPushService`
- Event listeners package (one class per domain or grouped)
- `FirebaseConfig`
- Flyway, OpenAPI, tests with mocked FCM

## Output
Runnable notification-service on port 8088.
