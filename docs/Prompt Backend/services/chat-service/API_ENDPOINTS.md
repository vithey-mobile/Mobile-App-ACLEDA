# Chat Service — API Endpoints

Base path: `/api/v1`

All REST endpoints require JWT (via gateway `X-User-Id` or Bearer token).

Gateway: `http://localhost:8080` · Service direct: `http://localhost:8087`

## Conversations

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/conversations?page=&limit=` | Current user's conversations with `last_message`, `unread_count`, `is_online` |
| POST | `/conversations/request` | Send first contact request |
| POST | `/conversations/{id}/accept` | Accept message request |
| POST | `/conversations/{id}/decline` | Decline request |
| POST | `/conversations/{id}/block` | Block conversation/user |
| GET | `/conversations/{id}/presence` | Partner online status (Redis) |

## Messages

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/conversations/{id}/messages?page=&limit=&before=` | Message history (PostgreSQL) |
| POST | `/conversations/{id}/messages` | Send text or media message |
| PATCH | `/messages/{message_id}/read` | Mark one message read |
| POST | `/conversations/{id}/messages/read` | Batch mark messages read |

### Send message body

```json
{
  "text": "optional caption",
  "client_message_id": "client-generated-uuid",
  "reply_to_message_id": "uuid",
  "message_type": "TEXT",
  "file_id": "uuid"
}
```

| `message_type` | Required fields |
| --- | --- |
| `TEXT` | `text` |
| `IMAGE` | `file_id` (upload via `POST /files/upload` type `CHAT_ATTACHMENT`) |
| `FILE` | `file_id` |

## Requests and safety

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/message-requests` | Pending requests for current user |
| POST | `/users/{user_id}/report` | Report a user |

## WebSocket (STOMP)

| Item | Value |
| --- | --- |
| Gateway endpoint | `ws://localhost:8080/ws` |
| Service endpoint | `ws://localhost:8087/ws/chat` |
| Protocol | STOMP 1.2 |
| Auth | `Authorization: Bearer {jwt}` on CONNECT |
| Subscribe inbox | `/user/queue/messages` |
| Subscribe presence | `/user/queue/presence` |
| Send message | `/app/chat.send` |
| Typing | `/app/chat.typing` |
| Heartbeat | `/app/chat.heartbeat` |
| Mark read (optional) | `/app/chat.read` |

### STOMP outbound `type` values

| `type` | Queue | Description |
| --- | --- | --- |
| `MESSAGE` | `/user/queue/messages` | New/updated message |
| `READ_RECEIPT` | `/user/queue/messages` | Read status update |
| `TYPING` | `/user/queue/messages` | Typing indicator |
| `PRESENCE` | `/user/queue/presence` | Online/offline |
| `MESSAGE_DELETED` | `/user/queue/messages` | Soft delete (phase 2) |

## Related services

| Need | Service | Endpoint |
| --- | --- | --- |
| File upload | file-service | `POST /api/v1/files/upload` (`type=CHAT_ATTACHMENT`) |
| FCM push | notification-service | Consumes `chat.message.sent` from RabbitMQ |
| Participant profile | user-profile-service | Enriched in conversation list (optional Feign) |

See `ARCHITECTURE.md` for Redis keys, event flow, and production topology.
