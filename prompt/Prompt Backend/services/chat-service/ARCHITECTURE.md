# Chat Service — Architecture

> End-to-end architecture for **private user-to-user chat** (not AI chatbot — see `ai-service`).

## System overview

```text
Flutter App
│
├── Dio (REST) ──────────────────► API Gateway :8080 ──► chat-service :8087
│                                      │
│                                      ├── PostgreSQL chat_db (history, receipts)
│                                      ├── Redis (presence, typing, message cache)
│                                      └── RabbitMQ (domain events → notification-service)
│
├── web_socket_channel (STOMP) ──► Gateway /ws ──► chat-service STOMP broker
│
├── Isar (local offline cache — Flutter only)
│
└── firebase_messaging ◄──────── notification-service ◄── RabbitMQ chat.message.sent
                                 (Firebase Admin SDK)
```

## Chat service internal stack

| Layer | Technology | Responsibility |
|-------|------------|----------------|
| REST API | Spring Web | Conversations, messages, requests, block, report |
| Real-time | WebSocket + STOMP | Live delivery, typing, read receipts, presence |
| History | PostgreSQL 16 | Durable conversations, messages, participants |
| Hot cache | Redis 7 | Online status, typing state, recent message window |
| Media refs | MinIO via **file-service** | Image/file attachments (`file_id` on message) |
| Push trigger | RabbitMQ events | `chat.message.sent` → notification-service → FCM |
| Discovery | Eureka | `chat-service` registration |
| Config | Spring Cloud Config | JWT trust, Redis/DB/RabbitMQ connection |

> **Firebase Admin SDK** lives in **notification-service**, not chat-service. Chat-service only publishes events; notification-service owns FCM delivery.

## Real-time feature matrix

| Feature | Technology | Owner |
|---------|------------|-------|
| Online status | Redis TTL + WebSocket `PRESENCE` event | chat-service |
| Typing indicator | Redis short TTL + WebSocket `TYPING` event | chat-service |
| Read receipt | PostgreSQL `status` + WebSocket `READ_RECEIPT` | chat-service |
| Push notification (background) | RabbitMQ → notification-service → Firebase FCM | notification-service |
| File / image message | file-service upload + `file_id` on message row | file-service + chat-service |
| Message cache (hot window) | Redis sorted set / list per conversation | chat-service |
| Message history (cold) | PostgreSQL paginated REST | chat-service |
| In-app live delivery | WebSocket STOMP `MESSAGE` event | chat-service |

## STOMP contract (canonical)

| Item | Value |
|------|-------|
| Gateway URL | `wss://{host}/ws` (dev: `ws://localhost:8080/ws`) |
| Service endpoint | `/ws/chat` |
| Connect | `Authorization: Bearer {jwt}` on handshake |
| User inbox | Subscribe `/user/queue/messages` |
| Presence | Subscribe `/user/queue/presence` |
| Send message | `/app/chat.send` |
| Typing | `/app/chat.typing` |
| Mark read (optional) | `/app/chat.read` — REST `PATCH` remains source of truth |

### Inbound frame types (`/user/queue/messages`)

| `type` | When |
|--------|------|
| `MESSAGE` | New or updated message delivered to participant |
| `READ_RECEIPT` | Recipient marked message read |
| `MESSAGE_DELETED` | Sender soft-deleted message (phase 2) |

### Presence frame (`/user/queue/presence`)

```json
{
  "type": "PRESENCE",
  "user_id": "uuid",
  "status": "ONLINE",
  "last_seen_at": "2026-07-09T14:00:00Z"
}
```

`status`: `ONLINE` | `OFFLINE` | `AWAY` (optional).

## Redis key design

| Key pattern | TTL | Purpose |
|-------------|-----|---------|
| `chat:presence:{userId}` | 90s (refresh on heartbeat) | Online status |
| `chat:typing:{conversationId}:{userId}` | 5s | Typing indicator |
| `chat:recent:{conversationId}` | 24h | Last N message IDs (cache warm-up) |
| `chat:unread:{userId}:{conversationId}` | — | Optional unread counter cache |

**Presence heartbeat:** client sends STOMP `/app/chat.heartbeat` every 30s; server refreshes Redis TTL and broadcasts `PRESENCE` to conversation partners.

**Typing:** client sends `/app/chat.typing` with `is_typing: true`; server sets Redis key with 5s TTL and fans out to other participants. No DB write.

## File attachment flow

```text
1. Flutter → POST /api/v1/files/upload  (file-service, type=CHAT_ATTACHMENT)
2. file-service → MinIO bucket chat-attachments/ → returns file_id + presigned url
3. Flutter → POST /api/v1/conversations/{id}/messages
             { "text": "optional caption", "file_id": "uuid", "message_type": "IMAGE" }
4. chat-service validates participant + file ownership → saves message → STOMP + event
```

Chat-service calls file-service via OpenFeign to validate `file_id` exists and belongs to sender.

## Event flow (push notification)

```text
chat-service: message saved
    → publish RabbitMQ chat.message.sent { messageId, conversationId, senderId, recipientId, preview }
    → notification-service consumes
    → if recipient has no active STOMP session (or app backgrounded): Firebase FCM
    → else: skip FCM (in-app STOMP already delivered)
```

Notification-service checks Redis `chat:presence:{recipientId}` or a "active conversation" hint to avoid duplicate push.

## Production topology

```text
                    ┌─────────────────┐
                    │   API Gateway   │
                    │  REST + /ws     │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
       ┌──────▼──────┐ ┌─────▼─────┐ ┌─────▼──────────────┐
       │ chat-service │ │file-service│ │notification-service│
       └──────┬──────┘ └─────┬─────┘ └─────────┬──────────┘
              │              │                  │
    ┌─────────┼─────────┐    │            Firebase Admin
    │         │         │    │
┌───▼───┐ ┌───▼───┐ ┌───▼───┐ ┌──▼──┐
│Postgres│ │ Redis │ │RabbitMQ│ │MinIO│
│chat_db │ │       │ │        │ │     │
└───────┘ └───────┘ └────────┘ └─────┘

Optional at scale:
    chat-service ──► Kafka (chat.events) ──► notification-service / analytics
    (RabbitMQ remains default for Vithey v1)
```

## Gateway routes (required)

| Path | Target |
|------|--------|
| `/api/v1/conversations/**` | `lb://chat-service` |
| `/api/v1/messages/**` | `lb://chat-service` |
| `/api/v1/message-requests/**` | `lb://chat-service` |
| `/ws/**` | `lb:ws://chat-service` (WebSocket upgrade) |

## Phase plan

| Phase | Scope |
|-------|-------|
| **v1** | REST + STOMP MESSAGE + read receipts + RabbitMQ → FCM |
| **v1.1** | Redis presence + typing + message hot cache |
| **v1.2** | File attachments via file-service, reply_to, client_message_id idempotency |
| **v2** | Kafka fan-out, per-conversation STOMP topics, message delete event |

## Related prompts

| Doc | Purpose |
|-----|---------|
| `SERVICE_PROMPT.md` | Implementation spec (authoritative) |
| `API_ENDPOINTS.md` | REST + STOMP quick reference |
| `DB_SCHEMA.md` | PostgreSQL tables |
| `SERVICE_LOGIC.md` | Business rules |
| `Prompt Frontend/Screen prompt/chat/05.chat_api_realtime.md` | Flutter contract mirror |
| `Prompt Backend/services/api-gateway/SERVICE_PROMPT.md` | Gateway `/ws` route |
| `Prompt Backend/services/notification-service/` | FCM delivery |
| `Prompt Backend/services/file-service/` | MinIO uploads |
