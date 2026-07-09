# AI Service — API Endpoints

> **Implementation:** Python FastAPI. **Integration:** Java API Gateway routes
> `/api/v1/ai/**` here.

Base path: `/api/v1`

All endpoints require JWT (gateway forwards `Authorization` + `X-User-Id`).

**Flutter module:** `Screen prompt/chatbot/05.chatbot_api_streaming.md`

## Chat sessions

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/ai/chat` | Send message; create or continue session |
| GET | `/ai/sessions?page=&limit=` | List sessions for history drawer |
| GET | `/ai/sessions/{id}/messages?page=&limit=` | Load conversation for active session |
| DELETE | `/ai/sessions/{id}` | Delete session (drawer trash icon) |

## Planned extensions

| Method | Path | Purpose |
| --- | --- | --- |
| PATCH | `/ai/sessions/{id}` | Rename title, pin/unpin |
| POST | `/ai/chat/stream` | SSE token streaming |
| DELETE | `/ai/chat/requests/{request_id}` | Cancel generation (Stop button) |
| POST | `/ai/messages/{message_id}/regenerate` | Regenerate assistant reply |

## POST `/ai/chat`

**Request:**

```json
{
  "message": "How to write a good CV?",
  "topic": "CV",
  "session_id": null,
  "client_message_id": "client-1735123456789"
}
```

| Field | Rule |
| --- | --- |
| `message` | Required, trim, max 4000 chars |
| `session_id` | `null` on first message in New Chat |
| `topic` | Optional: `CV`, `JOB`, `INTERVIEW`, `STUDENT`, `FINANCE` |
| `client_message_id` | Idempotency key from Flutter |

**Response:**

```json
{
  "data": {
    "session_id": "uuid",
    "message_id": "uuid",
    "reply": "Markdown assistant text…",
    "topic": "CV"
  },
  "meta": null
}
```

`reply` must be **Markdown** — rendered by `flutter_markdown` in Flutter.

## GET `/ai/sessions`

```json
{
  "data": [
    {
      "session_id": "uuid",
      "title": "Study Plan - Arch 201",
      "topic": "STUDENT",
      "is_pinned": false,
      "preview": "Here is a study plan…",
      "updated_at": "2026-07-09T12:00:00Z"
    }
  ],
  "meta": { "page": 1, "limit": 20, "total": 5, "total_pages": 1 }
}
```

Auto-generate `title` from first user message when not provided.

## GET `/ai/sessions/{id}/messages`

Ordered ASC by `created_at`. Roles: `user`, `assistant`.

```json
{
  "data": [
    {
      "message_id": "uuid",
      "role": "user",
      "content": "Help with my CV",
      "status": "complete",
      "created_at": "2026-07-09T12:00:00Z"
    },
    {
      "message_id": "uuid",
      "role": "assistant",
      "content": "## CV Tips\n\n1. …",
      "status": "complete",
      "created_at": "2026-07-09T12:00:05Z"
    }
  ]
}
```

## DELETE `/ai/sessions/{id}`

- `204` or `{ "data": null }`
- `404` if not owned — Flutter reconciles as deleted

## CV suggestions (separate)

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/ai/cv/suggest` | Improve a CV section |

## Health

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/actuator/health` | `{"status":"UP"}` |

## Security

- Validate `session_id` belongs to `X-User-Id`
- Rate limit per user (429)
- Do not log full prompts in production
- Finance topic: read-only guidance — no real account data from finance-service in prompt

## Flutter paths (no `/api/v1` prefix)

```dart
static const aiChat = '/ai/chat';
static const aiSessions = '/ai/sessions';
static String aiSessionById(String id) => '/ai/sessions/$id';
static String aiSessionMessages(String id) => '/ai/sessions/$id/messages';
```
