# AI / Chatbot — Common Context (Integration)

> Python implementation — built by you.  
> Java platform provides gateway, auth, and discovery only.

## Service Role

Vithey AI chatbot for students: CV help, job advice, interview prep, student support, finance Q&A.

Implemented in **Python** by you. Java services do not contain chatbot or LLM logic.

## Identity

| Item | Value |
| --- | --- |
| Language | Python (your project) |
| Eureka name | `ai-service` |
| Port | 8089 |
| API prefix | `/api/v1/ai/**` |
| Flutter module | `lib/modules/chatbot/` |

## Distinction from chat-service

| | chat-service | ai-service |
| --- | --- | --- |
| Language | Java | Python |
| Port | 8087 | 8089 |
| Purpose | Private user messaging | AI chatbot assistant |
| Gateway path | `/api/v1/conversations/**` | `/api/v1/ai/**` |

## Auth flow

1. User logs in via `auth-service` → Vithey JWT
2. Flutter calls gateway `8080/api/v1/ai/chat` with JWT
3. Gateway validates JWT, adds `X-User-Id`, forwards to Python `ai-service`
4. Python trusts headers or re-validates JWT

## API contract

See `API_ENDPOINTS.md`. Response envelope matches all Java services.

## Does NOT live in Java repo

- LLM calls, RAG, prompts, session DB implementation
- Eureka client code
- Docker image for Python service

See `INTEGRATION.md` in this folder for wiring guide.
