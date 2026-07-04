# Notification Service — Service Logic

## Ownership

Owns in-app notifications, unread count, read state, FCM device tokens, and push delivery.

Does not own source domain behavior such as comments, payments, jobs, or chat messages.

## Event mapping

| Event | Notify | Type |
| --- | --- | --- |
| `comment.added` | Post author | `COMMENT` |
| `reaction.added` | Post author | `LIKE` |
| `follow.created` | Followed user | `FOLLOW` |
| `mention.created` | Mentioned user | `MENTION` |
| `chat.request.received` | Recipient | `CHAT_REQUEST` |
| `chat.message.sent` | Recipient | `CHAT` |
| `payment.due`, `payment.overdue` | Student | `PAYMENT` |
| `job.application.submitted` | Job poster | `JOB` |
| `job.application.status_changed` | Applicant | `JOB` |

## Core flows

| Flow | Logic |
| --- | --- |
| Event consumed | Map event payload to notification title/body/reference and insert row. |
| Push | After insert, load user device tokens and send FCM payload. |
| List | Return current user's notifications paginated newest first. |
| Unread count | Count unread notifications by current user. |
| Mark read | Only owner can mark read. |
| Device register | Upsert token by `fcm_token`, update user/platform. |

## FCM payload

```json
{ "notification_id": "uuid", "type": "LIKE", "reference_id": "uuid", "title": "...", "body": "..." }
```

## Errors

| Case | Code | HTTP |
| --- | --- | --- |
| Notification not owned | `NOT_FOUND` | 404 |
| Invalid device token | `VALIDATION_ERROR` | 400 |
| FCM failure | log and keep in-app notification | 200/201 remains successful |

