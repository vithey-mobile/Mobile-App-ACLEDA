# AI Service — API Endpoints

> **Implementation:** Python FastAPI. **Integration:** Java API Gateway routes
> `/api/v1/ai/**` here. API contract unchanged from the Java design.

Base path: `/api/v1`

All endpoints require JWT (or gateway `X-User-*` headers).

## Chat

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/ai/chat` | Send user message and receive assistant reply |
| GET | `/ai/sessions?page=&limit=` | List current user's AI sessions |
| GET | `/ai/sessions/{id}/messages?page=&limit=` | Session messages |
| DELETE | `/ai/sessions/{id}` | Delete current user's session |

## CV suggestions

| Method | Path | Purpose |
| --- | --- | --- |
| POST | `/ai/cv/suggest` | Improve a CV section |

## Health (DevOps / Java compatibility)

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/actuator/health` | Liveness — returns `{"status":"UP"}` |

## Chat request

```json
{ "message": "How to write a good CV?", "topic": "CV", "session_id": null }
```

Topics: `CV`, `JOB`, `INTERVIEW`, `STUDENT`, `FINANCE`.

## Chat response

```json
{
  "data": {
    "session_id": "uuid",
    "reply": "A good CV should include...",
    "topic": "CV",
    "message_id": "uuid"
  }
}
```
