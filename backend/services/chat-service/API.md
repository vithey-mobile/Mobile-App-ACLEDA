# Chat Service API

Base path: `/api/v1`

All REST endpoints require JWT.

## Conversations

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/conversations` | Current user's conversations |
| POST | `/conversations/request` | Send first contact request |
| POST | `/conversations/{id}/accept` | Accept message request |
| POST | `/conversations/{id}/decline` | Decline request |
| POST | `/conversations/{id}/block` | Block conversation/user |

## Messages

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/conversations/{id}/messages` | Message history |
| POST | `/conversations/{id}/messages` | Send message |
| PATCH | `/messages/{id}/read` | Mark one message read |

## Requests and safety

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/message-requests` | Pending requests for current user |
| POST | `/users/{userId}/report` | Report a user |

## WebSocket (STOMP)

| Item | Value |
| --- | --- |
| Endpoint | `/ws/chat` |
| Subscribe | `/user/queue/messages` |
| Send | `/app/chat.send` |

## Events published

- `chat.request.received`
- `chat.message.sent`
