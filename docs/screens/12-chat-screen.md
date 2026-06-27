# Chat Screen

## Quick info

| Field | Value |
|-------|-------|
| Screen ID | `12` |
| Route | `Routes.CHAT` |
| Flutter module | `lib/modules/chat/` |
| Backend service(s) | `chat-service` |
| Auth required | Yes |
| Competition feature | **Private chat** |

## Purpose

List private conversations and **message requests** (receiver must accept first).

## Open from

- Bottom navigation, Home

## Main UI

| Element | Description |
|---------|-------------|
| Search box | Find users to message |
| Message requests | Pending requests section |
| Chat list | Avatar, name, last message, time, unread dot |
| Long-press menu | Block, report |

## User actions

| Action | Result |
|--------|--------|
| Tap chat | Chat Detail |
| Accept request | Start conversation |
| Decline request | Remove request |
| Block / report | Confirm dialog → API |

## Logic & behavior

- Privacy: receiver must accept before full chat
- Badge for pending request count
- Pull to refresh

## Navigation

| From | Action | To |
|------|--------|-----|
| Chat | Tap item | Chat Detail |

## API endpoints

| Method | Path | Notes |
|--------|------|-------|
| GET | `/api/v1/conversations` | Chat list |
| GET | `/api/v1/message-requests` | Pending |
| POST | `/api/v1/conversations/{id}/accept` | Accept |

## Status checklist

- [ ] UX/UI designed
- [ ] Request flow works
- [ ] Block/report wired
