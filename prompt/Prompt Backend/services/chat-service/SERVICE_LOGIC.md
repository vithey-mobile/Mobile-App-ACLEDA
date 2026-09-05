# Chat Service — Service Logic

## Ownership

Owns private conversations, message requests, messages, read status, blocks, reports, and real-time message delivery.

Does not own user search/profile data or push notifications.

## Core flows

| Flow | Logic |
| --- | --- |
| First contact | Create `PENDING` conversation and first message, publish `chat.request.received`. |
| Accept request | Recipient changes conversation to `ACTIVE`. |
| Decline request | Recipient changes conversation to `DECLINED`; no further messages. |
| Send message | Require participant and `ACTIVE` conversation; save message; send WebSocket; publish `chat.message.sent`. |
| Mark read | Recipient marks message as `READ`; optionally push read event. |
| Block | Change status to `BLOCKED`; blocked user cannot send. |
| Report | Save report for moderation; no automatic ban in first version. |

## WebSocket rules

- Authenticate handshake with JWT or gateway-forwarded principal.
- Deliver to `/user/queue/messages`.
- Do not fake online status unless Redis presence is implemented.
- REST remains source of truth for message history and read state.

## Events published

- `chat.request.received`
- `chat.message.sent`

## Errors

| Case | Code | HTTP |
| --- | --- | --- |
| Self-message | `BUSINESS_RULE_VIOLATION` | 422 |
| Not participant | `FORBIDDEN` | 403 |
| Blocked conversation | `FORBIDDEN` | 403 |
| Duplicate request | `CONFLICT` | 409 |

