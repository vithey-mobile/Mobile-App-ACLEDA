# Chat Service — Complete API Design

> Read `SERVICE_BLUEPRINT.md`, `COMMON_CONTEXT.md`.  
> **Scope:** Backend REST API + WebSocket (STOMP) — conversations, messages, requests.

## Identity

| Item | Value |
|------|-------|
| Path | `vithey-backend/services/chat-service/` |
| Port | 8087 |
| Eureka | `chat-service` |
| Database | `chat_db` |
| Package | `com.vithey.chat` |

## Spring Cloud + tools

Eureka, Config, RabbitMQ, **WebSocket/STOMP**, Redis (optional presence), JPA, Flyway.

## Folder structure

```text
services/chat-service/
└── src/main/java/com/vithey/chat/
    ├── ChatServiceApplication.java
    ├── config/WebSocketConfig.java, SecurityConfig.java, RabbitMqConfig.java, RedisConfig.java
    ├── controller/
    │   ├── ConversationController.java
    │   ├── MessageController.java
    │   ├── MessageRequestController.java
    │   └── ReportController.java
    ├── websocket/ChatMessageController.java, ChatEventListener.java
    ├── service/ConversationService.java, MessageService.java, BlockService.java, ReportService.java
    ├── repository/ConversationRepository.java, MessageRepository.java, BlockRepository.java, UserReportRepository.java
    ├── entity/Conversation.java, Message.java, ConversationParticipant.java, Block.java, UserReport.java
    ├── dto/request/SendMessageRequest.java, MessageRequestDto.java, ReportUserRequest.java
    ├── dto/response/ConversationResponse.java, MessageResponse.java
    ├── event/publisher/ChatEventPublisher.java
    └── exception/GlobalExceptionHandler.java
```

## Database

**Conversation:** `id`, `status` PENDING|ACTIVE|BLOCKED|DECLINED, `created_at`

**ConversationParticipant:** `conversation_id`, `user_id`, `role` REQUESTER|RECIPIENT

**Message:** `id`, `conversation_id`, `sender_id`, `text`, `status` SENT|DELIVERED|READ, `created_at`

**Block:** `blocker_id`, `blocked_id`, unique pair

**UserReport:** `id`, `reporter_id`, `reported_id`, `reason`, `created_at`

## Complete REST API (all JWT)

### Conversations

| Method | Path | Request | HTTP |
|--------|------|---------|------|
| GET | `/api/v1/conversations` | paginated list | 200 |
| POST | `/api/v1/conversations/request` | `{ "to_user_id", "initial_message" }` | 201 |
| POST | `/api/v1/conversations/{id}/accept` | — | 200 |
| POST | `/api/v1/conversations/{id}/decline` | — | 200 |
| POST | `/api/v1/conversations/{id}/block` | — | 200 |

### Messages

| Method | Path | Request | HTTP |
|--------|------|---------|------|
| GET | `/api/v1/conversations/{id}/messages` | paginated | 200 |
| POST | `/api/v1/conversations/{id}/messages` | `{ "text": "Hello!" }` | 201 |
| PATCH | `/api/v1/messages/{id}/read` | — | 200 |

### Message requests

| Method | Path | HTTP |
|--------|------|------|
| GET | `/api/v1/message-requests` | 200 pending for current user |

### Reports

| Method | Path | Request | HTTP |
|--------|------|---------|------|
| POST | `/api/v1/users/{userId}/report` | `{ "reason": "..." }` | 201 |

**Message response:**
```json
{
  "data": {
    "message_id": "uuid",
    "conversation_id": "uuid",
    "sender_id": "uuid",
    "text": "Hello!",
    "status": "SENT",
    "created_at": "2026-01-01T00:00:00Z"
  }
}
```

## WebSocket (STOMP)

| Item | Value |
|------|-------|
| Endpoint | `ws://localhost:8087/ws/chat` (or via gateway `/ws` proxy) |
| Connect | JWT in `Authorization` header on handshake |
| Subscribe | `/user/queue/messages` |
| Send | `/app/chat.send` with `{ conversation_id, text }` |
| Push | Server delivers to recipient in real time |

Status flow: `SENT` → `DELIVERED` on receive → `READ` on PATCH read.

## Business logic

| Rule | Logic |
|------|-------|
| First contact | Create PENDING conversation + message request → publish `chat.request.received` |
| Accept | Status ACTIVE — both can message |
| Send | Reject if PENDING/BLOCKED; reject self-message |
| Block | Set BLOCKED; blocked user cannot send |
| New message | Publish `chat.message.sent` for notification |

## Events published

`chat.request.received`, `chat.message.sent`

## Errors

| Case | HTTP |
|------|------|
| Message self | 422 |
| Blocked / not participant | 403 |
| Not found | 404 |
| Duplicate request | 409 |

## Output

Runnable chat-service on **8087** with REST + STOMP.
