# Notification Service — API Endpoints

Base path: `/api/v1`

All endpoints require JWT. Full contract: **`UPGRADE_FOR_UI.md`**.

## Notifications

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/notifications?page=&limit=&is_read=` | Paginated inbox; `is_read=true\|false` filters server-side |
| GET | `/notifications/unread-count` | Unread badge count (Home bell) |
| PATCH | `/notifications/{id}/read` | Mark one notification read |
| PATCH | `/notifications/read-all` | Mark all current user's notifications read |
| DELETE | `/notifications/{id}` | Delete one notification (owner-only) |

### List query params

| Param | Default | Notes |
|-------|---------|-------|
| `page` | `1` | 1-based |
| `limit` | `20` | max `50` |
| `is_read` | *(omit)* | omit = all; `false` = unread only; `true` = read only |

### List response item

```json
{
  "id": "uuid",
  "type": "LIKE",
  "event": "reaction.added",
  "title": "New like",
  "body": "Kimheang liked your post.",
  "is_read": false,
  "created_at": "2026-07-09T14:30:00Z",
  "read_at": null,
  "actor": {
    "id": "uuid",
    "full_name": "Kimheang",
    "avatar_url": "https://cdn.example/avatar.jpg"
  },
  "destination": {
    "reference_type": "POST",
    "reference_id": "post-uuid",
    "post_id": "post-uuid"
  },
  "dedupe_key": "reaction.added:reaction-uuid"
}
```

`notification_id` accepted as alias for `id` in responses.

### List meta

```json
{
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 42,
    "unread_total": 7
  }
}
```

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

`LIKE`, `COMMENT`, `MENTION`, `POST_SHARE`, `FOLLOW`, `CHAT`, `CHAT_REQUEST`, `JOB`, `PAYMENT`, `AI`, `SYSTEM`, `STUDENT_VERIFICATION`.

## Errors

| HTTP | code | When |
|------|------|------|
| 400 | `VALIDATION_ERROR` | Invalid page/limit/platform |
| 401 | `UNAUTHORIZED` | Missing/invalid JWT |
| 404 | `NOT_FOUND` | Notification not found or not owned |
