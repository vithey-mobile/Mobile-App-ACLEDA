# Vithey AI API Contract (for Python implementation)

Base path: `/api/v1/ai`

All endpoints require authentication (Vithey JWT or gateway `X-User-*` headers).

## Chat

| Method | Path | Body | Response |
| --- | --- | --- | --- |
| POST | `/chat` | `ChatRequest` | `ChatResponse` |
| GET | `/sessions?page=1&limit=20` | — | paginated `SessionResponse[]` |
| GET | `/sessions/{id}/messages?page=1&limit=20` | — | paginated `MessageResponse[]` |
| DELETE | `/sessions/{id}` | — | 204 |

## CV suggestions

| Method | Path | Body | Response |
| --- | --- | --- | --- |
| POST | `/cv/suggest` | `CvSuggestRequest` | `CvSuggestResponse` |

## Health

| Method | Path | Response |
| --- | --- | --- |
| GET | `/actuator/health` | `{"status":"UP"}` |

## Request schemas

### ChatRequest

```json
{
  "message": "How to write a good CV?",
  "topic": "CV",
  "session_id": null
}
```

Topics: `CV`, `JOB`, `INTERVIEW`, `STUDENT`, `FINANCE`

### CvSuggestRequest

```json
{
  "section": "experiences",
  "original_text": "I did coding",
  "cv_id": "uuid-or-null"
}
```

## Response schemas (inside `data`)

### ChatResponse

```json
{
  "session_id": "uuid",
  "reply": "A good CV should include...",
  "topic": "CV",
  "message_id": "uuid"
}
```

### CvSuggestResponse

```json
{
  "suggested_text": "Developed mobile applications...",
  "interaction_id": "uuid"
}
```

### SessionResponse

```json
{
  "id": "uuid",
  "topic": "CV",
  "title": "How to write a CV?",
  "created_at": "2026-07-05T04:00:00Z",
  "updated_at": "2026-07-05T04:05:00Z"
}
```

### MessageResponse

```json
{
  "id": "uuid",
  "role": "USER",
  "content": "Hello",
  "created_at": "2026-07-05T04:00:00Z"
}
```

Roles: `USER`, `ASSISTANT`

## Error envelope

```json
{
  "data": null,
  "error": {
    "code": "RATE_LIMITED",
    "message": "Rate limit exceeded",
    "details": null
  }
}
```

| Code | HTTP |
| --- | --- |
| `UNAUTHORIZED` | 401 |
| `VALIDATION_ERROR` | 400 |
| `NOT_FOUND` | 404 |
| `RATE_LIMITED` | 429 |
| `UPSTREAM_ERROR` | 502 |

## Flutter chatbot usage

Screens in `prompt/Prompt Frontend/Screen prompt/chatbot/` call these endpoints via gateway `http://localhost:8080/api/v1/ai/...`.
