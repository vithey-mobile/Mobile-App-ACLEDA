# AI / Chatbot — Common Context (Integration)

> Implemented as Python **`ai_core/`** (Compose: `ai-core`, port **8100**).  
> Java platform provides gateway, auth, and discovery only.  
> See `INTEGRATION.md` for the current wiring.

## Service Role

Vithey AI chatbot for students: CV help, job advice, interview prep, student support, finance Q&A.

Java services do not contain chatbot or LLM logic. Chat defaults to **stub** mode.

## Identity

| Item | Value |
| --- | --- |
| Language | Python (FastAPI) |
| Folder | `ai_core/` (repo root) |
| Compose name | `ai-core` |
| Port | **8100** |
| API prefix | `/api/v1/ai/**` |
| Flutter module | `lib/modules/chatbot/` (+ AI CV surfaces) |

> Java `backend/services/ai-service/` is **retired**. Do not use port 8089 / Eureka name `ai-service`.

## Distinction from chat-service

| | chat-service | ai_core |
| --- | --- | --- |
| Language | Java | Python |
| Port | 8087 | 8100 |
| Purpose | Private user messaging | AI chatbot + CV |
| Gateway path | `/api/v1/conversations/**` | `/api/v1/ai/**` → `http://ai-core:8100` |

## Auth flow

1. User logs in via `auth-service` → Vithey JWT
2. Flutter calls gateway `8080/api/v1/ai/**` with JWT
3. Gateway validates JWT, adds `X-User-*`, forwards to `ai-core`
4. Python trusts headers or re-validates JWT

## API contract

See `API_ENDPOINTS.md` and `INTEGRATION.md`. Prefer Vithey `{ data, meta, error }` snake_case envelope.
