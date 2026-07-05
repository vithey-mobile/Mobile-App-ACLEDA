# AI / Chatbot — Kickoff Prompt (Integration Only)

> **Do not build AI or chatbot in Java.**  
> You build chatbot + AI in **Python** (your own project).  
> This prompt folder defines the **integration contract** only.

## Read First

1. `../../COMMON_CONTEXT.md` — platform rules (envelope, auth, HTTP codes)
2. `INTEGRATION.md` — how Python plugs into Java gateway + Eureka
3. `API_ENDPOINTS.md` — API your Python service must expose
4. `../../../backend/services/ai-service/` — integration docs in the Java repo

## Fixed Facts

| Item | Value |
| --- | --- |
| Implementation | **Python** — built by you, outside Java repo |
| Eureka name | `ai-service` |
| Port | 8089 |
| Gateway route | `/api/v1/ai/**` → `lb://ai-service` (already in Java gateway) |
| Java repo folder | `backend/services/ai-service/` — **docs only**, no code |
| Maven module | **No** |

## What Java already provides

- API Gateway JWT validation + `X-User-*` headers
- Eureka service discovery
- Route `/api/v1/ai/**` configured

## What you build (Python)

- FastAPI (or your stack) on port 8089
- Vithey API contract from `API_ENDPOINTS.md`
- Eureka registration as `ai-service`
- Your chatbot / LLM / RAG logic internally

## Non-Negotiable Rules

- **No Java AI code** in Vithey backend
- **No chatbot logic** in Java `chat-service` (that is user messaging)
- Python must use Vithey response envelope and snake_case JSON
- Python must accept gateway headers or Vithey JWT

## Definition of Done (integration)

- [ ] Python service registers in Eureka as `ai-service`
- [ ] `POST http://localhost:8080/api/v1/ai/chat` works through gateway with Vithey JWT
- [ ] Flutter chatbot screens can call AI endpoints
- [ ] Java repo contains integration docs only (no implementation)
