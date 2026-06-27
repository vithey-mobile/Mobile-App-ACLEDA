# Chat Service — Service Prompt

Build the Chat microservice with REST + WebSocket.

## API Endpoints

### Conversations
| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/conversations` | Chat list for current user |
| POST | `/api/v1/conversations/request` | Send message request to user |
| POST | `/api/v1/conversations/{id}/accept` | Accept request → ACTIVE |
| POST | `/api/v1/conversations/{id}/decline` | Decline request |
| POST | `/api/v1/conversations/{id}/block` | Block user |
| POST | `/api/v1/users/{userId}/report` | Report user |

### Messages
| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/conversations/{id}/messages` | Paginated messages |
| POST | `/api/v1/conversations/{id}/messages` | Send message |
| PATCH | `/api/v1/messages/{id}/read` | Mark as read |

### Message Requests
| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/message-requests` | Pending requests for current user |

## Send Message Request
```json
{ "to_user_id": "uuid", "initial_message": "Hi, I'd like to connect" }
```

## Send Message
```json
{ "text": "Hello!" }
```

## Message Response
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
- Connect: `ws://localhost:8087/ws/chat` with JWT in handshake header
- Subscribe: `/user/queue/messages`
- Send: `/app/chat.send`
- Push new messages to recipient in real-time
- Update status: DELIVERED on receive, READ on open conversation

## Business Rules
- First contact creates `MessageRequest` — recipient must accept
- After accept, conversation status = ACTIVE
- Blocked users cannot send messages (403)
- Cannot message self

## Required Modules
- `ConversationController`, `MessageController`, `MessageRequestController`
- `ChatService`, `MessageService`, `BlockService`
- `WebSocketConfig`, `ChatMessageController` (STOMP)
- `ChatEventPublisher`
- Redis config for optional presence
- Flyway, OpenAPI, WebSocket integration test

## Output
Runnable chat-service on port 8087.
