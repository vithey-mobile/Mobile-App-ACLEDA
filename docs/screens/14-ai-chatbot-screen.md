# AI Chatbot Screen

## Quick info

| Field | Value |
|-------|-------|
| Screen ID | `14` |
| Route | `Routes.CHATBOT` |
| Flutter module | `lib/modules/chatbot/` |
| Backend service(s) | `ai-service` |
| Auth required | Yes |
| Competition feature | **AI assistant** |

## Purpose

AI helper for CV writing, jobs, interviews, student support, and finance questions.

## Open from

- Home FAB, menu, or dedicated nav item

## Main UI

| Element | Description |
|---------|-------------|
| Message list | User + AI bubbles |
| Suggestion chips | Example questions when empty |
| Input bar | Text + send |
| Typing indicator | While AI responds |

## Question topics

| Topic | Example |
|-------|---------|
| CV | "How to write a good CV?" |
| Job | Job search and applications |
| Interview | Interview preparation |
| Student | AUB student support |
| Finance | Tuition and payment guidance |

## User actions

| Action | Result |
|--------|--------|
| Type + send | POST to AI API, show reply |
| Tap suggestion | Fill input and send |

## Logic & behavior

- Keep session history for context
- Show loading dots while waiting
- Graceful error if AI unavailable

## API endpoints

| Method | Path | Notes |
|--------|------|-------|
| POST | `/api/v1/ai/chat` | `message`, `topic`, `session_id` |
| GET | `/api/v1/ai/sessions/{id}/messages` | History |

## Status checklist

- [ ] UX/UI designed
- [ ] Chat UI works
- [ ] AI API integrated
