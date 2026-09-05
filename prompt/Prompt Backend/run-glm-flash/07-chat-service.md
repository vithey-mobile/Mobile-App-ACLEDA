# GLM 5.3 Flash — Terminal 7 / 10 — chat-service

Copy everything below the line into a **new** GLM chat. Run in parallel with the other 9. Do not edit other services.

---

You are GLM 5.3 Flash on Vithey App. Work **only** `chat-service`.

## Read first

- `prompt/Prompt Backend/LEARNING.md`
- `prompt/Prompt Backend/services/chat-service/`
- `prompt/Prompt Frontend/Screen prompt/chat/05.chat_api_realtime.md` if present
- Live code: `backend/services/chat-service/`

## Identity

Port **8087** · Eureka `chat-service` · DB `chat_db` · Redis presence · package `com.vithey.chat`

## Allowed paths

```text
backend/services/chat-service/**
prompt/Prompt Backend/services/chat-service/**
```

Do **not** edit POM, gateway, Flutter, or other services. Gateway already proxies `/ws/**` — do not change gateway YAML.

## Job (complete / verify)

REST must match `API_ENDPOINTS.md`:

- `GET /api/v1/conversations`
- `POST /api/v1/conversations/request`
- `POST /conversations/{id}/accept|decline|block`
- `GET /conversations/{id}/presence`
- `GET/POST /conversations/{id}/messages`
- `PATCH /messages/{id}/read` and batch read
- `GET /api/v1/message-requests`
- `POST /api/v1/users/{userId}/report`

STOMP broker stays on this service. Do not invent a second websocket path.

If already complete, only fix drift / missing tests. Do not merge with `ai-service`.

## Verify

`mvn -pl services/chat-service -am test` from `backend/`

Print files changed. Stop.
