# Chat Service — Service Prompt

Authoritative API contract and build checklist for the Vithey Chat microservice
(REST + WebSocket). Read `KICKOFF_PROMPT.md` and both `COMMON_CONTEXT.md` files first.

## Conventions (avoid drift)

- **JSON fields:** `snake_case`. **Java fields:** `camelCase`. Map via MapStruct/Jackson.
- **All responses** use the root envelope (`{ "data": ... }` / `{ "error": ... }`).
- **All IDs** are UUID strings. Lists are paginated per root pagination rules.
- **Current user** comes from the JWT (`sub`), never from the request body.

## API Endpoints

### Conversations

| Method | Path                                 | Description                            | Success |
| ------ | ------------------------------------ | -------------------------------------- | ------- |
| GET    | `/api/v1/conversations`              | Chat list for current user (paginated) | 200     |
| POST   | `/api/v1/conversations/request`      | Send a message request to a user       | 201     |
| POST   | `/api/v1/conversations/{id}/accept`  | Accept request → status `ACTIVE`       | 200     |
| POST   | `/api/v1/conversations/{id}/decline` | Decline request → status stays/closed  | 200     |
| POST   | `/api/v1/conversations/{id}/block`   | Block the other participant            | 200     |
| POST   | `/api/v1/users/{userId}/report`      | Report a user                          | 201     |

### Messages

| Method | Path                                  | Description                       | Success |
| ------ | ------------------------------------- | --------------------------------- | ------- |
| GET    | `/api/v1/conversations/{id}/messages` | Paginated messages (newest first) | 200     |
| POST   | `/api/v1/conversations/{id}/messages` | Send a message                    | 201     |
| PATCH  | `/api/v1/messages/{id}/read`          | Mark a message as read            | 200     |

### Message Requests

| Method | Path                       | Description                       | Success |
| ------ | -------------------------- | --------------------------------- | ------- |
| GET    | `/api/v1/message-requests` | Pending requests for current user | 200     |

## Request / Response Shapes

### Send message request — request

```json
{ "to_user_id": "uuid", "initial_message": "Hi, I'd like to connect" }
```

### Send message — request

```json
{ "text": "Hello!" }
```

### Message — response

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

### Report user — request

```json
{ "reason": "Spam or harassment" }
```

## WebSocket (STOMP)

- Connect: `ws://localhost:8087/ws/chat` with JWT in the handshake header.
- Subscribe: `/user/queue/messages` (server routes to `/user/{userId}/queue/messages`).
- Send: `/app/chat.send`.
- Server pushes new messages to the recipient in real time.
- Status transitions: `SENT` → `DELIVERED` on recipient receive → `READ` when the
  recipient opens the conversation.

## Business Rules

- First contact between two users creates a `MessageRequest`; the recipient must
  accept before the `Conversation` becomes `ACTIVE`.
- Sending into a `PENDING`/`BLOCKED` conversation is rejected.
- Blocked users cannot send messages.
- A user cannot message themselves.

## Error Behavior (use root envelope + codes)

| Case                               | Code                      | HTTP |
| ---------------------------------- | ------------------------- | ---- |
| Message to self                    | `BUSINESS_RULE_VIOLATION` | 422  |
| Sender blocked / not a participant | `FORBIDDEN`               | 403  |
| Conversation/message not found     | `NOT_FOUND`               | 404  |
| Duplicate request to same user     | `CONFLICT`                | 409  |
| Validation failure                 | `VALIDATION_ERROR`        | 400  |

## Required Modules

- Controllers: `ConversationController`, `MessageController`, `MessageRequestController`, `ReportController`
- Services: `ChatService`, `MessageService`, `BlockService`, `ReportService`
- Real-time: `WebSocketConfig`, `ChatMessageController` (STOMP)
- Events: `ChatEventPublisher`
- Config: Redis config (optional presence), `GlobalExceptionHandler`
- Migration: `V1__init_chat_schema.sql`

## Testing

- WebSocket/STOMP integration test (send → recipient receives).
- Message-request accept/decline flow test.
- Block prevents send (403) test.
- Cannot-message-self (422) test.
- Event-published assertions with mocked RabbitMQ.

## Docs

`README.md` (run, env vars, port), `API.md` (endpoint summary), `ARCHITECTURE.md` (boundaries, DB, events, WebSocket).

## Output

Complete, runnable chat-service on port 8087.
