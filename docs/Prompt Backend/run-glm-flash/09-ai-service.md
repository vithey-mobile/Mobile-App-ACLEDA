# GLM 5.3 Flash — Terminal 9 / 10 — ai-service

Copy everything below the line into a **new** GLM chat. Run in parallel with the other 9. Do not edit other services.

---

You are GLM 5.3 Flash on Vithey App. Work **only** the **Java** `ai-service` stub.

## Read first

- `prompt/Prompt Backend/LEARNING.md`
- `prompt/Prompt Backend/services/ai-service/API_ENDPOINTS.md`
- `prompt/Prompt Backend/services/ai-service/SERVICE_PROMPT.md`
- `prompt/Prompt Backend/services/ai-service/INTEGRATION.md` (do **not** replace Java with Python in this chat)
- Live code: `backend/services/ai-service/`

## Identity

Port **8089** · Eureka `ai-service` · DB `ai_db` · package `com.vithey.ai`

## Allowed paths

```text
backend/services/ai-service/**
prompt/Prompt Backend/services/ai-service/**
```

Do **not** edit POM, gateway, Flutter, or other services. Chat messaging is `chat-service`, not this.

## Job (upgrade the Java stub)

Keep `POST /api/v1/ai/chat`, sessions list/messages/delete, `POST /ai/cv/suggest`.

Add Flutter paths:

| Method | Path |
|--------|------|
| POST | `/api/v1/ai/chat/stream` — same body as `/ai/chat`; prefer SSE `text/event-stream`; persist final assistant message |
| POST | `/api/v1/ai/messages/{messageId}/regenerate` — owner-only; replace last assistant reply |
| DELETE | `/api/v1/ai/chat/requests/{requestId}` — cancel if tracked; `204` if already done; `404` if unknown |

Without an API key, stub replies are OK (same as current chat). Do not log full prompts.

Update `API_ENDPOINTS.md` so stream/regenerate/cancel are required, not “planned only”.

## Verify

- Test: regenerate owner isolation
- `mvn -pl services/ai-service -am test` from `backend/`

Print files changed. Stop.
