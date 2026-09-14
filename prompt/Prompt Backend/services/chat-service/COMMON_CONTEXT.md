# Chat Service — Common Context

> Service-specific context. **Extends** the root `../../COMMON_CONTEXT.md` — all
> global rules (tech stack, package layout, response envelope, HTTP codes, auth,
> DB rules) still apply. This file only adds or overrides what is specific to the
> chat-service. On conflict, the **more specific** file wins:
> `SERVICE_PROMPT.md` > this file > root `COMMON_CONTEXT.md`.

## Service Role

Private user-to-user chat with a message-request flow, read receipts, typing,
online presence, media attachments, block, and report. Owns conversations and
messages only — never user profile, MinIO blobs, or FCM delivery.

Full architecture: **`ARCHITECTURE.md`**.

## Identity

| Item         | Value                     |
| ------------ | ------------------------- |
| Eureka name  | `chat-service`            |
| Port         | 8087                      |
| Database     | `chat_db` (PostgreSQL 16) |
| Cache        | Redis 7 (presence, typing, recent messages) |
| Events       | RabbitMQ (default); Kafka optional at scale |
| Base package | `com.vithey.chat`         |

## Technology stack (this service)

| Concern | Technology |
|---------|------------|
| REST API | Spring Web |
| Real-time | Spring WebSocket + STOMP |
| History | PostgreSQL + JPA + Flyway |
| Hot cache | Spring Data Redis |
| Media | OpenFeign → **file-service** (MinIO); store `file_id` only |
| Push trigger | RabbitMQ `chat.message.sent` → **notification-service** (Firebase Admin SDK) |
| Auth | Trust `X-User-Id` from gateway or JWT resource server |

## Real-time features

| Feature | Implementation |
|---------|----------------|
| Online status | Redis `chat:presence:{userId}` + STOMP `/user/queue/presence` |
| Typing indicator | Redis `chat:typing:{conv}:{user}` (5s TTL) + STOMP `TYPING` event |
| Read receipt | PostgreSQL `messages.status=READ` + STOMP `READ_RECEIPT` |
| Push notification | Publish `chat.message.sent`; notification-service sends FCM |
| File upload | Client uploads to file-service; message stores `file_id` |
| Message cache | Redis `chat:recent:{conversationId}` — last 50 message IDs |
| History | PostgreSQL paginated `GET /conversations/{id}/messages` |

## Entities

Use UUID primary keys and `created_at` / `updated_at` on every entity (root DB rules).

### `Conversation`

| Field            | Type      | Notes                              |
| ---------------- | --------- | ---------------------------------- |
| `id`             | UUID      | PK                                 |
| `participant1Id` | UUID      | lower UUID, to keep a pair unique  |
| `participant2Id` | UUID      | higher UUID                        |
| `status`         | enum      | `PENDING` \| `ACTIVE` \| `BLOCKED` \| `DECLINED` |
| `createdAt`      | timestamp |                                    |

> Store the participant pair in a stable order (e.g. sorted UUIDs) and add a
> unique constraint so the same two users can't open duplicate conversations.

### `Message`

| Field            | Type      | Notes                           |
| ---------------- | --------- | ------------------------------- |
| `id`             | UUID      | PK                              |
| `conversationId` | UUID      | FK → `Conversation.id`          |
| `senderId`       | UUID      | participant in the conversation |
| `text`           | String    | nullable when `messageType` is media |
| `messageType`    | enum      | `TEXT` \| `IMAGE` \| `FILE`     |
| `fileId`         | UUID      | nullable; validated via file-service |
| `replyToMessageId` | UUID    | nullable self-FK                |
| `clientMessageId` | String   | nullable; idempotency key from client |
| `status`         | enum      | `SENT` \| `DELIVERED` \| `READ` |
| `deletedAt`      | timestamp | nullable soft-delete (phase 2) |
| `createdAt`      | timestamp |                                 |

### `MessageRequest`

| Field        | Type | Notes                                 |
| ------------ | ---- | ------------------------------------- |
| `id`         | UUID | PK                                    |
| `fromUserId` | UUID | sender                                |
| `toUserId`   | UUID | recipient who must accept             |
| `status`     | enum | `PENDING` \| `ACCEPTED` \| `DECLINED` |

### `BlockedUser`

| Field       | Type | Notes              |
| ----------- | ---- | ------------------ |
| `id`        | UUID | PK                 |
| `blockerId` | UUID | user who blocks    |
| `blockedId` | UUID | user being blocked |

### `Report`

| Field        | Type      | Notes                  |
| ------------ | --------- | ---------------------- |
| `id`         | UUID      | PK                     |
| `reporterId` | UUID      | user filing the report |
| `reportedId` | UUID      | user being reported    |
| `reason`     | String    | not null               |
| `createdAt`  | timestamp |                        |

## Events Published

Publish to RabbitMQ using the root `<domain>.<action>` naming.

| Event                   | Payload                                                | Consumers    |
| ----------------------- | ------------------------------------------------------ | ------------ |
| `chat.message.sent`     | `{ messageId, conversationId, senderId, recipientId, preview, messageType }` | notification-service |
| `chat.request.received` | `{ requestId, fromUserId, toUserId }`                  | notification-service |

**Kafka (optional, production scale):** mirror same payloads to topic `chat.events` for analytics or multi-region fan-out. RabbitMQ remains required for v1.

## Real-Time (WebSocket / STOMP)

| Item | Value |
|------|-------|
| Service endpoint | `/ws/chat` |
| Gateway endpoint | `/ws` → `lb:ws://chat-service` |
| Auth | JWT in `Authorization` header on handshake |
| Inbox subscribe | `/user/queue/messages` |
| Presence subscribe | `/user/queue/presence` |
| Send message | `/app/chat.send` |
| Typing | `/app/chat.typing` |
| Heartbeat | `/app/chat.heartbeat` (refreshes Redis presence) |
| Mark read (optional) | `/app/chat.read` |

Frame `type` values: `MESSAGE`, `READ_RECEIPT`, `TYPING`, `PRESENCE`, `MESSAGE_DELETED`.

See `ARCHITECTURE.md` for JSON payloads and Redis keys.

## API Prefix (owned by this service)

`/api/v1/conversations/**`, `/api/v1/messages/**`, `/api/v1/message-requests/**`,
plus `POST /api/v1/users/{userId}/report` (report action only).

## Does NOT Own

- User identity / profile → **user-profile-service** / **auth-service**
- File blob storage → **file-service** (MinIO)
- FCM / device tokens → **notification-service** (Firebase Admin SDK)
- AI chatbot → **ai-service**
