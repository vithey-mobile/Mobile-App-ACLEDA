# AI / Chatbot — Integration Contract (Python)

> **Not a build prompt.** You implement chatbot + AI in Python yourself.  
> This file is the contract for connecting to the Vithey Java platform.

## Identity

| Item | Value |
| --- | --- |
| Implementation | Python (your repo — e.g. GDCE chatbot stack) |
| Eureka | `ai-service` |
| Port | 8089 |
| Gateway | `/api/v1/ai/**` → `lb://ai-service` (Java — already configured) |
| Java repo | `backend/services/ai-service/` — integration docs only |

## Java platform (already built — do not duplicate)

```text
Flutter → API Gateway :8080 → ai-service :8089 (your Python)
                ↓
         auth-service (JWT)
         eureka-server (discovery)
```

## Python service requirements

### 1. Eureka

Register instance `ai-service` on port 8089.

### 2. Auth

Accept `X-User-Id`, `X-User-Email`, `X-User-Roles` from gateway, or validate Vithey JWT with `VITHEY_JWT_SECRET`.

### 3. API endpoints

| Method | Path |
| --- | --- |
| POST | `/api/v1/ai/chat` |
| GET | `/api/v1/ai/sessions` |
| GET | `/api/v1/ai/sessions/{id}/messages` |
| DELETE | `/api/v1/ai/sessions/{id}` |
| POST | `/api/v1/ai/cv/suggest` |
| GET | `/actuator/health` |

Full schemas: `API_ENDPOINTS.md` and `backend/services/ai-service/API.md`.

### 4. Response envelope

```json
{ "data": {}, "meta": null, "error": null }
```

Snake_case JSON. Same error codes as Java services.

### 5. Docker

Join external network `vithey-network`. Optionally `gdce-network` if reusing existing Python stack.

Example: `backend/services/ai-service/docker-compose.integration.example.yml`

## Chatbot vs chat-service

| Service | Language | Purpose |
| --- | --- | --- |
| `chat-service` :8087 | Java | User-to-user private messaging |
| `ai-service` :8089 | **Python** | Vithey AI chatbot (CV, job, interview, …) |

## Reusing existing Python stack

If you already have Docker services (orchestrator, general, api-layer, retrieval):

- Keep them on `gdce-network`
- Your Vithey-facing Python service calls orchestrator `/internal/chat/send`
- Do not expose GDCE api-layer auth to Vithey users — use Vithey JWT at gateway

See `INTEGRATION.md` for details.

## Verification

```powershell
curl http://localhost:8761/eureka/apps/AI-SERVICE
curl -X POST http://localhost:8080/api/v1/ai/chat `
  -H "Authorization: Bearer <vithey-token>" `
  -H "Content-Type: application/json" `
  -d '{"message":"Hello","topic":"CV"}'
```

## Out of scope for Java repo

- Python source code
- `pom.xml` / Maven module
- LLM provider implementation
- Qdrant / RAG setup

Build those in your Python project. Java repo keeps integration docs only.
