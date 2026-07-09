# Chat Service — Complete API Design

> Read `ARCHITECTURE.md`, `SERVICE_BLUEPRINT.md`, `COMMON_CONTEXT.md`.  
> **Scope:** Backend REST API + WebSocket (STOMP) + Redis real-time — conversations, messages, requests, presence, typing, attachments.

## Identity

| Item | Value |
|------|-------|
| Path | `backend/services/chat-service/` |
| Port | 8087 |
| Eureka | `chat-service` |
| Database | `chat_db` |
| Package | `com.vithey.chat` |

## Spring Cloud + tools

Eureka, Config, RabbitMQ, **WebSocket/STOMP**, **Redis** (presence, typing, message cache), JPA, Flyway, OpenFeign (file-service).

**Not in this service:** Firebase Admin SDK (notification-service), MinIO SDK (file-service).

## Folder structure

```text
services/chat-service/
└── src/main/java/com/vithey/chat/
    ├── ChatServiceApplication.java
    ├── config/
    │   ├── WebSocketConfig.java
    │   ├── SecurityConfig.java
    │   ├── RabbitMqConfig.java
    │   ├── RedisConfig.java
    │   └── FeignConfig.java
    ├── controller/
    │   ├── ConversationController.java
    │   ├── MessageController.java
    │   ├── MessageRequestController.java
    │   └── ReportController.java
    ├── websocket/
    │   ├── ChatStompController.java      # /app/chat.send, typing, read, heartbeat
    │   ├── ChatEventListener.java        # connect/disconnect → presence
    │   └── StompUserPrincipalResolver.java
    ├── service/
    │   ├── ConversationService.java
    │   ├── MessageService.java
    │   ├── PresenceService.java          # Redis presence + heartbeat
    │   ├── TypingService.java            # Redis typing TTL
    │   ├── MessageCacheService.java      # Redis recent window
    │   ├── BlockService.java
    │   └── ReportService.java
    ├── client/FileServiceClient.java     # validate file_id
    ├── repository/
    ├── entity/
    ├── dto/request/
    │   ├── SendMessageRequest.java
    │   ├── BatchReadRequest.java
    │   ├── TypingRequest.java
    │   └── ReportUserRequest.java
    ├── dto/response/
    │   ├── ConversationResponse.java
    │   ├── MessageResponse.java
    │   └── PresenceResponse.java
    ├── event/publisher/ChatEventPublisher.java
    └── exception/GlobalExceptionHandler.java
```

## Database

See `DB_SCHEMA.md`. Summary:

**Conversation:** `id`, `status` PENDING|ACTIVE|BLOCKED|DECLINED, `created_at`

**ConversationParticipant:** `conversation_id`, `user_id`, `role` REQUESTER|RECIPIENT

**Message:** `id`, `conversation_id`, `sender_id`, `text`, `message_type` TEXT|IMAGE|FILE, `file_id`, `reply_to_message_id`, `client_message_id`, `status` SENT|DELIVERED|READ, `deleted_at`, `created_at`

**Block:** `blocker_id`, `blocked_id`, unique pair

**UserReport:** `id`, `reporter_id`, `reported_id`, `reason`, `created_at`

## Complete REST API (all JWT)

### Conversations

| Method | Path | Request | HTTP |
|--------|------|---------|------|
| GET | `/api/v1/conversations` | `?page=&limit=` | 200 — includes `participant`, `last_message`, `unread_count`, `is_online` |
| POST | `/api/v1/conversations/request` | `{ "to_user_id", "initial_message" }` | 201 |
| POST | `/api/v1/conversations/{id}/accept` | — | 200 |
| POST | `/api/v1/conversations/{id}/decline` | — | 200 |
| POST | `/api/v1/conversations/{id}/block` | — | 200 |
| GET | `/api/v1/conversations/{id}/presence` | — | 200 — partner online status from Redis |

### Messages

| Method | Path | Request | HTTP |
|--------|------|---------|------|
| GET | `/api/v1/conversations/{id}/messages` | `?page=&limit=&before=` | 200 |
| POST | `/api/v1/conversations/{id}/messages` | see below | 201 |
| PATCH | `/api/v1/messages/{id}/read` | — | 200 |
| POST | `/api/v1/conversations/{id}/messages/read` | `{ "message_ids": ["uuid"] }` | 200 — batch read |

**Send message body:**

```json
{
  "text": "Hello!",
  "client_message_id": "client-uuid-optional",
  "reply_to_message_id": "uuid-optional",
  "message_type": "TEXT",
  "file_id": "uuid-optional"
}
```

Rules:
- `message_type` default `TEXT`; `IMAGE`/`FILE` require `file_id` (uploaded via file-service first).
- `client_message_id` enables idempotent retry — return existing message on duplicate.

### Message requests

| Method | Path | HTTP |
|--------|------|------|
| GET | `/api/v1/message-requests` | 200 pending for current user |

### Reports

| Method | Path | Request | HTTP |
|--------|------|---------|------|
| POST | `/api/v1/users/{userId}/report` | `{ "reason": "..." }` | 201 |

**Conversation list item:**

```json
{
  "data": {
    "conversation_id": "uuid",
    "status": "ACTIVE",
    "participant": { "user_id": "uuid", "display_name": "...", "avatar_url": "..." },
    "last_message": { "text": "Hi", "created_at": "...", "sender_id": "uuid" },
    "unread_count": 2,
    "is_online": true,
    "updated_at": "2026-07-09T14:00:00Z"
  }
}
```

**Message response:**

```json
{
  "data": {
    "message_id": "uuid",
    "conversation_id": "uuid",
    "sender_id": "uuid",
    "text": "Hello!",
    "message_type": "TEXT",
    "file_id": null,
    "file_url": null,
    "reply_to_message_id": null,
    "status": "SENT",
    "created_at": "2026-01-01T00:00:00Z"
  }
}
```

## WebSocket (STOMP)

| Item | Value |
|------|-------|
| Gateway URL | `ws://localhost:8080/ws` (prod: `wss://{host}/ws`) |
| Service URL | `ws://localhost:8087/ws/chat` |
| Connect | JWT in `Authorization` header on handshake |
| Subscribe messages | `/user/queue/messages` |
| Subscribe presence | `/user/queue/presence` |
| Send message | `/app/chat.send` |
| Typing | `/app/chat.typing` `{ conversation_id, is_typing }` |
| Heartbeat | `/app/chat.heartbeat` — refresh Redis presence (every 30s) |
| Mark read | `/app/chat.read` `{ conversation_id, message_id }` (optional; REST preferred) |

### Outbound frame types

**MESSAGE**

```json
{
  "type": "MESSAGE",
  "conversation_id": "uuid",
  "message_id": "uuid",
  "sender_id": "uuid",
  "text": "Hello!",
  "message_type": "TEXT",
  "file_id": null,
  "status": "DELIVERED",
  "created_at": "2026-07-09T14:11:00Z"
}
```

**READ_RECEIPT**

```json
{
  "type": "READ_RECEIPT",
  "conversation_id": "uuid",
  "message_id": "uuid",
  "reader_id": "uuid",
  "read_at": "2026-07-09T14:12:00Z"
}
```

**TYPING**

```json
{
  "type": "TYPING",
  "conversation_id": "uuid",
  "user_id": "uuid",
  "is_typing": true
}
```

**PRESENCE** (on `/user/queue/presence`)

```json
{
  "type": "PRESENCE",
  "user_id": "uuid",
  "status": "ONLINE",
  "last_seen_at": "2026-07-09T14:00:00Z"
}
```

Status flow: `SENT` → `DELIVERED` on STOMP/REST ack to recipient → `READ` on PATCH read.

## Redis usage

| Key | TTL | Purpose |
|-----|-----|---------|
| `chat:presence:{userId}` | 90s | Online; refresh on heartbeat |
| `chat:typing:{conversationId}:{userId}` | 5s | Typing flag |
| `chat:recent:{conversationId}` | 24h | Last 50 message IDs |

On message save: append ID to `chat:recent:{conversationId}`, trim to 50, publish STOMP.

## Business logic

| Rule | Logic |
|------|-------|
| First contact | Create PENDING conversation + message request → publish `chat.request.received` |
| Accept | Status ACTIVE — both can message |
| Send | Reject if PENDING/BLOCKED; reject self-message; validate `file_id` via Feign |
| Idempotency | If `client_message_id` exists for sender+conversation, return existing |
| Block | Set BLOCKED; blocked user cannot send |
| New message | STOMP to recipient; update Redis cache; publish `chat.message.sent` |
| Mark read | Update DB; STOMP `READ_RECEIPT` to sender; idempotent |
| Typing | Redis only — no DB; fan-out to other participant |
| Presence | On STOMP connect → ONLINE; disconnect/TTL expiry → OFFLINE |
| Push | notification-service sends FCM only when recipient offline / not in active thread |

## Events published

`chat.request.received`, `chat.message.sent`

## Inter-service calls

| Client | Target | Purpose |
|--------|--------|---------|
| `FileServiceClient` | `file-service` | Validate `file_id` for attachments |
| (optional) `UserProfileClient` | `user-profile-service` | Enrich conversation list participant display |

## Errors

| Case | HTTP |
|------|------|
| Message self | 422 |
| Blocked / not participant | 403 |
| Not found | 404 |
| Duplicate request | 409 |
| Invalid file_id | 400 |
| Idempotent duplicate send | 200/201 with existing message |

## Production checklist

- [ ] API Gateway routes REST + `/ws/**` to `lb:ws://chat-service`
- [ ] Redis cluster or single instance with persistence disabled (cache only)
- [ ] PostgreSQL backups for `chat_db`
- [ ] RabbitMQ durable queues for `chat.message.sent`
- [ ] notification-service FCM credentials in Config Server
- [ ] (Optional) Kafka producer for `chat.events` topic

## Output

Runnable chat-service on **8087** with REST + STOMP + Redis presence/typing/cache, RabbitMQ events, and file attachment support via file-service.
