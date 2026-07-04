# Chat Service — API Endpoints

Base path: `/api/v1`

All REST endpoints require JWT.

## Conversations

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/conversations?page=&limit=` | Current user's conversations |
| POST | `/conversations/request` | Send first contact request |
| POST | `/conversations/{id}/accept` | Accept message request |
| POST | `/conversations/{id}/decline` | Decline request |
| POST | `/conversations/{id}/block` | Block conversation/user |

## Messages

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/conversations/{id}/messages?page=&limit=` | Message history |
| POST | `/conversations/{id}/messages` | Send message |
| PATCH | `/messages/{id}/read` | Mark one message read |

## Requests and safety

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/message-requests` | Pending requests for current user |
| POST | `/users/{user_id}/report` | Report a user |

## WebSocket

| Item | Value |
| --- | --- |
| Gateway endpoint | `/ws` |
| Service endpoint | `/ws/chat` |
| Subscribe | `/user/queue/messages` |
| Send | `/app/chat.send` |

