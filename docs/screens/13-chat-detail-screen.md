# Chat Detail Screen

## Quick info

| Field | Value |
|-------|-------|
| Screen ID | `13` |
| Route | `Routes.CHAT_DETAIL` |
| Flutter module | `lib/modules/chat_detail/` |
| Backend service(s) | `chat-service` |
| Auth required | Yes |

## Purpose

Send and receive **private messages** with read/delivered status.

## Open from

- Chat list (active conversation)

## Main UI

| Element | Description |
|---------|-------------|
| Message list | Bubbles left (other) / right (self) |
| Date separators | Between days |
| Input bar | Text field + send button |
| Read ticks | On own messages |
| App bar menu | Block user |

## Message status

| Status | Display |
|--------|---------|
| SENT | Single tick |
| DELIVERED | Double tick |
| READ | Blue double tick |

## User actions

| Action | Result |
|--------|--------|
| Send | POST message, append to list |
| Scroll up | Load older messages |
| Block | From app bar menu |

## Logic & behavior

- WebSocket real-time when available; polling fallback
- `conversationId` from route args
- Mark read when screen opens

## API endpoints

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/v1/conversations/{id}/messages` | Paginated |
| POST | `/api/v1/conversations/{id}/messages` | Send |
| PATCH | `/api/v1/messages/{id}/read` | Read receipt |
| WS | `/ws/chat` | Real-time (STOMP) |

## Status checklist

- [ ] UX/UI designed
- [ ] Send/receive works
- [ ] WebSocket or polling
