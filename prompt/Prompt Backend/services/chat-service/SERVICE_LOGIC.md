# Chat Service — Service Logic

## Ownership

Owns private conversations, message requests, messages, read status, blocks, reports, real-time STOMP delivery, Redis presence/typing/cache.

Does not own user search/profile data, MinIO blobs, device tokens, or FCM push delivery.

## Core flows

| Flow | Logic |
| --- | --- |
| First contact | Create `PENDING` conversation and first message, publish `chat.request.received`. |
| Accept request | Recipient changes conversation to `ACTIVE`. |
| Decline request | Recipient changes conversation to `DECLINED`; no further messages. |
| Send message (REST or STOMP) | Require participant and `ACTIVE` conversation; validate `file_id` if media; check `client_message_id` idempotency; save to PostgreSQL; append to Redis recent cache; STOMP `MESSAGE` to recipient; set `DELIVERED` when recipient session acks; publish `chat.message.sent`. |
| Mark read | Recipient marks message(s) as `READ` in DB; STOMP `READ_RECEIPT` to sender; idempotent. |
| Typing | Set Redis `chat:typing:{conv}:{user}` 5s TTL; STOMP `TYPING` to other participant; no DB write. |
| Presence connect | On STOMP session open: set Redis `chat:presence:{userId}` 90s; broadcast `PRESENCE ONLINE` to conversation partners. |
| Presence heartbeat | `/app/chat.heartbeat` refreshes TTL every 30s from client. |
| Presence disconnect | On session close or TTL expiry: `PRESENCE OFFLINE` with `last_seen_at`. |
| Block | Change status to `BLOCKED`; blocked user cannot send. |
| Report | Save report for moderation; no automatic ban in first version. |
| File attachment | Client uploads to file-service; chat-service validates ownership via Feign before saving `file_id` on message. |

## WebSocket rules

- Authenticate handshake with JWT or gateway-forwarded principal.
- Deliver messages to `/user/queue/messages`; presence to `/user/queue/presence`.
- One STOMP session per user (multiple tabs: last-writer or broadcast to all sessions — pick one and document).
- REST remains source of truth for message history and read state.
- Do not send FCM from chat-service — only publish RabbitMQ events.

## Redis rules

| Key | Behavior |
| --- | --- |
| `chat:presence:{userId}` | Value: `{ status, lastSeen }`. TTL 90s, refresh on heartbeat. |
| `chat:typing:{conv}:{user}` | Exists = typing. TTL 5s, no refresh extension beyond resend. |
| `chat:recent:{conv}` | List of last 50 message IDs. Used to warm cache on list load; PostgreSQL is authoritative. |

## Push notification gating

Publish `chat.message.sent` always. notification-service decides FCM:

- Recipient has no Redis presence → send FCM.
- Recipient online but not viewing that `conversation_id` → send FCM (optional product rule).
- Recipient active in same conversation → skip FCM.

## Message status lifecycle

```text
SENT (persisted)
  → DELIVERED (recipient REST poll, STOMP receive, or ack)
    → READ (recipient PATCH read or batch read)
```

## Events published

| Event | When |
| --- | --- |
| `chat.request.received` | New message request created |
| `chat.message.sent` | Message saved and ready for notify |

Payload for `chat.message.sent`:

```json
{
  "messageId": "uuid",
  "conversationId": "uuid",
  "senderId": "uuid",
  "recipientId": "uuid",
  "preview": "text or [Image]",
  "messageType": "TEXT"
}
```

## Errors

| Case | Code | HTTP |
| --- | --- | --- |
| Self-message | `BUSINESS_RULE_VIOLATION` | 422 |
| Not participant | `FORBIDDEN` | 403 |
| Blocked conversation | `FORBIDDEN` | 403 |
| Duplicate request | `CONFLICT` | 409 |
| Invalid / foreign file_id | `VALIDATION_ERROR` | 400 |
| Duplicate client_message_id | return existing | 200/201 |

## Testing focus

- STOMP connect with JWT; message round-trip between two users.
- Read receipt STOMP after PATCH.
- Typing expires after 5s without resend.
- Presence OFFLINE after disconnect + TTL.
- Idempotent send with same `client_message_id`.
- Media message rejected without valid `file_id`.
- `chat.message.sent` consumed by notification-service test container.
