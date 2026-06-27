# Chat Service — Common Context

## Service Role
Private user-to-user chat with message request flow, read receipts, block and report.

## Identity
| Item | Value |
|------|-------|
| Eureka name | `chat-service` |
| Port | 8087 |
| Database | `chat_db` |
| Cache | Redis (presence, typing) |
| Package | `com.vithey.chat` |

## Entities
- `Conversation` — id, participant1Id, participant2Id, status (PENDING/ACTIVE/BLOCKED), createdAt
- `Message` — id, conversationId, senderId, text, status (SENT/DELIVERED/READ), createdAt
- `MessageRequest` — id, fromUserId, toUserId, status (PENDING/ACCEPTED/DECLINED)
- `BlockedUser` — id, blockerId, blockedId

## Events Published
`chat.message.sent`, `chat.request.received`

## Real-Time
- WebSocket endpoint: `/ws/chat` (STOMP)
- Topics: `/user/{userId}/queue/messages`
- Redis for online presence optional

## API Prefix
`/api/v1/conversations/**`, `/api/v1/messages/**`
