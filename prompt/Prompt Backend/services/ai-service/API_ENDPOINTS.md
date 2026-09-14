# AI Service — API Endpoints

> **Implementation:** Java Spring Boot (`backend/services/ai-service/`, package
> `com.vithey.ai`). An external Python chatbot stack may sit behind it later via
> `general-service` retrieval, but the Vithey-facing API is served by Java.

Base path: `/api/v1`

All endpoints require JWT (gateway forwards `Authorization` + `X-User-Id`).

**Flutter module:** `Screen prompt/chatbot/05.chatbot_api_streaming.md`

## Chat sessions

All endpoints below are **required and implemented** in the Java service —
stream / regenerate / cancel are **not** “planned only”.

| Method | Path | Purpose | Status |
| --- | --- | --- | --- |
| POST | `/ai/chat` | Send message; create or continue session | implemented |
| POST | `/ai/chat/stream` | Same body as `/ai/chat`; SSE token streaming | implemented |
| POST | `/ai/messages/{message_id}/regenerate` | Replace assistant reply (owner-only) | implemented |
| DELETE | `/ai/chat/requests/{request_id}` | Cancel in-flight generation (Stop button) | implemented |
| GET | `/ai/sessions?page=&limit=` | List sessions for history drawer | implemented |
| GET | `/ai/sessions/{id}/messages?page=&limit=` | Load conversation for active session | implemented |
| DELETE | `/ai/sessions/{id}` | Delete session (drawer trash icon) | implemented |

## Optional later

| Method | Path | Purpose |
| --- | --- | --- |
| PATCH | `/ai/sessions/{id}` | Rename title, pin/unpin — implement if Flutter calls it |

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
| `client_message_id` | Optional idempotency key from Flutter (accepted; dedup reserved) |

**Response:**

```json
{
  "data": {
    "session_id": "uuid",
    "reply": "Markdown assistant text…",
    "topic": "CV",
    "message_id": "uuid",
    "request_id": "uuid"
  },
  "meta": null
}
```

`reply` must be **Markdown** — rendered by `flutter_markdown` in Flutter.
`request_id` can be passed to `DELETE /ai/chat/requests/{request_id}` (the
non-stream request is already finished, so a delete answers `204`).

## POST `/ai/chat/stream` (required)

Same request body as `/ai/chat`. Responds with `Content-Type:
text/event-stream` (SSE). Event order: `meta` → zero or more `token` → `done`.
On failure an `error` event is sent instead of `done`.

```
event: meta
data: {"request_id":"uuid","session_id":"uuid","user_message_id":"uuid","topic":"CV"}

event: token
data: Markdown fragment…

event: done
data: {"request_id":"uuid","session_id":"uuid","message_id":"uuid","cancelled":false}
```

- Concatenate `token` payloads left-to-right to render the Markdown reply live.
- The final assistant message is persisted before `done` — refetching
  `GET /ai/sessions/{id}/messages` after the stream shows the complete turn.
- If the client cancels (`DELETE /ai/chat/requests/{request_id}`) mid-stream,
  the stream stops early and the already-streamed partial content is persisted;
  `done` is emitted with `"cancelled": true`. Cancelling before the first token
  persists no assistant message.
- Without a configured LLM key the stream still works — the service streams the
  stub/retrieval reply token by token.

## POST `/ai/messages/{message_id}/regenerate` (required)

Owner-only: the message must be an `assistant` message inside a session owned
by the caller. A message owned by another user answers `404` (never `403`, to
avoid leaking existence).

**Response:** same shape as `/ai/chat` (`session_id`, `reply`, `topic`,
`message_id`). The assistant message content is replaced in place — its id does
not change.

Errors: `404` unknown message / not owner · `400` message is not `assistant`
role or has no preceding user message.

## DELETE `/ai/chat/requests/{request_id}` (required)

Cancel an in-flight streamed generation (Flutter “Stop” button).

- `204` — request was running and is now cancelled
- `204` — request already finished (`done`/`error` already sent)
- `404` — unknown request id, or the request belongs to another user

Request ids stay tracked for 15 minutes after completion so a Stop tap racing
the `done` event still answers `204`, not `404`.

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

Ordered ASC by `created_at`. Roles: `user`, `assistant`. `status` is always
`"complete"` — messages are only persisted once generation finished (or was
cancelled, in which case the partial content is stored).

```json
{
  "data": [
    {
      "message_id": "uuid",
      "role": "user",
      "content": "Help with my CV",
      "status": "complete",
      "created_at": "2026-07-09T12:00:00Z"
    },    {
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
static const aiChatStream = '/ai/chat/stream';
static const aiSessions = '/ai/sessions';
static String aiSessionById(String id) => '/ai/sessions/$id';
static String aiSessionMessages(String id) => '/ai/sessions/$id/messages';
static String aiRegenerateMessage(String messageId) => '/ai/messages/$messageId/regenerate';
static String aiCancelChatRequest(String requestId) => '/ai/chat/requests/$requestId';
```
