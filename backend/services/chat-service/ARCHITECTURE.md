# Chat Service Architecture

## Responsibility

Owns private conversations, message requests, messages, read status, blocks, reports, and real-time message delivery.

Does not own user search/profile data or push notifications.

## Dependencies

| Service | Usage |
| --- | --- |
| `user-profile-service` | Participant display names and avatars |
| `rabbitmq` | Publish chat domain events |
| `eureka-server` | Service discovery |
| `config-server` | Externalized configuration |

## Data store

PostgreSQL database `chat_db` with tables: `conversations`, `conversation_participants`, `messages`, `blocks`, `user_reports`.

## Key flows

1. **First contact** — create `PENDING` conversation + initial message; publish `chat.request.received`.
2. **Accept/decline** — recipient updates conversation status.
3. **Send message** — requires `ACTIVE` conversation; REST + WebSocket delivery; publish `chat.message.sent`.
4. **Block/report** — safety controls for moderation.

## Port

`8087` (Eureka name: `chat-service`)
