# Frontend API Integration Prompts

**All frontend API integration prompts and contracts live here only.**

Use this folder when wiring the Flutter app to the live Spring Boot backend through API Gateway.

## Read Order

1. `integration-contract.md` — single source of truth for frontend ↔ backend API behavior
2. `api-overview.md` — endpoint index, relative paths, auth rules
3. `00-api-intergration-prompt.md` — AI prompt to wire live Dio/services/repositories

## Folder Contents

| File | Purpose |
|------|---------|
| `integration-contract.md` | Full frontend ↔ backend contract, gateway routing, events, cross-service flows |
| `api-overview.md` | Endpoint index grouped by backend service |
| `00-api-intergration-prompt.md` | Prompt to implement live API wiring in Flutter |

### Detailed Service Contracts (`services/`)

| File | Service | Focus |
|------|---------|-------|
| [`01-auth-service.md`](services/01-auth-service.md) | `auth-service` | Login, Register, Tokens, Student Verification |
| [`02-user-profile-service.md`](services/02-user-profile-service.md) | `user-profile-service` | Profile, Bio, Avatar, Settings, User Search |
| [`03-file-service.md`](services/03-file-service.md) | `file-service` | Multipart Upload, MinIO S3 Presigned URLs, Download |
| [`04-content-service.md`](services/04-content-service.md) | `content-service` | Feeds, Posts, Comments, Likes/Reactions, Followers |
| [`05-career-service.md`](services/05-career-service.md) | `career-service` | Job Applications, Application Status, Student CV |
| [`06-finance-service.md`](services/06-finance-service.md) | `finance-service` | University Fees, Tuition, Payments, Due Alerts |
| [`07-chat-service.md`](services/07-chat-service.md) | `chat-service` | Conversations, Message Requests, STOMP WebSockets |
| [`08-notification-service.md`](services/08-notification-service.md) | `notification-service` | In-app Notification Feed, Unread Badges, FCM Push Tokens |
| [`09-ai-service.md`](services/09-ai-service.md) | `ai-service` | Chatbot Assistant, SSE Streaming, CV Suggestions |
| [`10-map-service.md`](services/10-map-service.md) | `map-service` | Nearby Places, Search Autocomplete, Favorites & History |

## Rule

Do not create or use API integration prompts in `reference/`, screen prompt folders, or elsewhere. Screen prompts may mention endpoint needs, but the implementation contract must point back here.

## Build Command

Give the coding agent this task when the backend and UI shell are ready:

```text
TASK: Prompt Frontend/api-intergration/00-api-intergration-prompt.md
```

