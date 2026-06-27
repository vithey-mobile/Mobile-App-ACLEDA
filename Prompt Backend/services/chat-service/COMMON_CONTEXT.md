# Chat Service — Common Context

> Service-specific context. **Extends** the root `../../COMMON_CONTEXT.md` — all
> global rules (tech stack, package layout, response envelope, HTTP codes, auth,
> DB rules) still apply. This file only adds or overrides what is specific to the
> chat-service. On conflict, the **more specific** file wins:
> `SERVICE_PROMPT.md` > this file > root `COMMON_CONTEXT.md`.

## Service Role

Private user-to-user chat with a message-request flow, read receipts, block, and
report. Owns conversations and messages only — never user profile or notification data.

## Identity

| Item         | Value                     |
| ------------ | ------------------------- |
| Eureka name  | `chat-service`            |
| Port         | 8087                      |
| Database     | `chat_db` (PostgreSQL 16) |
| Cache        | Redis (presence, typing)  |
| Base package | `com.vithey.chat`         |

## Entities

Use UUID primary keys and `created_at` / `updated_at` on every entity (root DB rules).

### `Conversation`

| Field            | Type      | Notes                              |
| ---------------- | --------- | ---------------------------------- |
| `id`             | UUID      | PK                                 |
| `participant1Id` | UUID      | lower UUID, to keep a pair unique  |
| `participant2Id` | UUID      | higher UUID                        |
| `status`         | enum      | `PENDING` \| `ACTIVE` \| `BLOCKED` |
| `createdAt`      | timestamp |                                    |

> Store the participant pair in a stable order (e.g. sorted UUIDs) and add a
> unique constraint so the same two users can't open duplicate conversations.

### `Message`

| Field            | Type      | Notes                           |
| ---------------- | --------- | ------------------------------- |
| `id`             | UUID      | PK                              |
| `conversationId` | UUID      | FK → `Conversation.id`          |
| `senderId`       | UUID      | participant in the conversation |
| `text`           | String    | not null, max length enforced   |
| `status`         | enum      | `SENT` \| `DELIVERED` \| `READ` |
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
| `chat.message.sent`     | `{ messageId, conversationId, senderId, recipientId }` | Notification |
| `chat.request.received` | `{ requestId, fromUserId, toUserId }`                  | Notification |

## Real-Time (WebSocket / STOMP)

- Endpoint: `/ws/chat` (STOMP over WebSocket); JWT passed in the handshake header.
- Recipient queue: `/user/{userId}/queue/messages`.
- Send destination: `/app/chat.send`.
- Redis for online presence is optional.

## API Prefix (owned by this service)

`/api/v1/conversations/**`, `/api/v1/messages/**`, `/api/v1/message-requests/**`,
plus `POST /api/v1/users/{userId}/report` (report action only).

## Does NOT Own

- User identity / profile → **User-Profile / Auth Service**
- Notification delivery → **Notification Service** (chat only publishes events)
