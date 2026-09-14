# Notification Service — Service Logic

> **UI upgrade spec:** `UPGRADE_FOR_UI.md`

## Ownership

Owns in-app notifications, unread count, read state, delete, FCM device tokens, and push delivery.

Does not own source domain behavior such as comments, payments, jobs, or chat messages.

## Event mapping

| Event | Notify | Type | event field |
| --- | --- | --- | --- |
| `reaction.added` | Post author | `LIKE` | `reaction.added` |
| `comment.added` | Post author | `COMMENT` | `comment.added` |
| `mention.created` | Mentioned user | `MENTION` | `mention.created` |
| `post.shared` | Original author | `POST_SHARE` | `post.shared` |
| `follow.created` | Followed user | `FOLLOW` | `follow.created` |
| `chat.message.sent` | Recipient | `CHAT` | `chat.message.sent` |
| `chat.request.received` | Recipient | `CHAT_REQUEST` | `chat.request.received` |
| `job.application.submitted` | Job poster | `JOB` | `job.application.submitted` |
| `job.application.status_changed` | Applicant | `JOB` | `job.application.status_changed` |
| `payment.due` | Student | `PAYMENT` | `payment.due` |
| `payment.overdue` | Student | `PAYMENT` | `payment.overdue` |
| `ai.response.ready` | Requesting user | `AI` | `ai.response.ready` |
| `system.announcement` | Target users | `SYSTEM` | `system.announcement` |
| `student.verification.updated` | Student | `STUDENT_VERIFICATION` | `student.verification.updated` |

Skip notification when recipient equals actor (self-like, self-comment).

## Core flows

| Flow | Logic |
| --- | --- |
| Event consumed | Map payload → title, body, actor snapshot, destination, dedupe_key; insert with idempotency |
| Push | After insert, load device tokens → FCM data map mirrors REST `destination` |
| List | Paginate by `user_id`, optional `is_read` filter, sort `created_at DESC` |
| Unread count | Count `is_read=false` for current user; optional Redis cache |
| Mark read | Owner-only; set `read_at`; decrement cache |
| Mark all read | Bulk update; reset cache |
| Delete | Owner-only hard delete; decrement cache if was unread |
| Device register | Upsert by `fcm_token` |

## FCM payload (v2)

Data map — all string values:

```json
{
  "notification_id": "uuid",
  "type": "CHAT",
  "event": "chat.message.sent",
  "title": "New message",
  "body": "Kimheang sent you a message.",
  "actor_id": "uuid",
  "actor_name": "Kimheang",
  "reference_type": "CONVERSATION",
  "reference_id": "conversation-uuid",
  "conversation_id": "conversation-uuid",
  "post_id": "",
  "job_post_id": "",
  "application_id": "",
  "payment_id": "",
  "ai_thread_id": "",
  "dedupe_key": "chat.message.sent:msg-uuid"
}
```

**Privacy:** Never include CV URLs, card data, or full chat message body in push.

## Chat vs STOMP

| Concern | Owner |
|---------|-------|
| Live thread | chat-service WebSocket |
| Inbox row + background push | notification-service |

chat-service publishes events only — does not call Firebase.

## Errors

| Case | Code | HTTP |
| --- | --- | --- |
| Notification not owned | `NOT_FOUND` | 404 |
| Invalid device token | `VALIDATION_ERROR` | 400 |
| FCM failure | log; in-app row still saved | 200/201 success |
