# AI / Chatbot — Integration with Vithey Java Platform

> **Scope:** Chatbot integrated in Java `ai-service`, calling GDCE `general-service` upstream.

## Architecture

```text
Vithey Flutter (chatbot screens)
    │
    ▼
Java API Gateway :8080
    │  validates JWT
    │  adds X-User-Id, X-User-Email, X-User-Roles
    │  route: /api/v1/ai/**
    ▼
Your Java `ai-service` (port **8089**) calls GDCE `general-service` for RAG/LLM answers.
    ▼
(Optional) your existing microservices
    orchestrator, general, retrieval, api-layer, …
```

## Java side — already done

These do **not** need AI code:

| Component | Status |
| --- | --- |
| Gateway route `/api/v1/ai/**` → `lb://ai-service` | Configured in `GatewayRouteConfig.java` |
| JWT validation at gateway | `JwtAuthenticationGlobalFilter` |
| Identity headers to downstream | `X-User-Id`, `X-User-Email`, `X-User-Roles` |
| Eureka server | `infrastructure/eureka-server` |
| Flutter chatbot API paths | `POST /api/v1/ai/chat`, sessions CRUD |

**Do not add** AI logic to `auth-service`, `chat-service`, or any other Java service.

> **Note:** `chat-service` (Java, port 8087) is **user-to-user messaging**.  
> **Chatbot / AI** (Python, port 8089) is a separate service.

## Python side — your responsibility

### Eureka registration

Register as **`ai-service`** on port **8089** so the gateway `lb://ai-service` route works.

Options:
- `py-eureka-client` in FastAPI startup
- Spring Cloud Netflix sidecar (not recommended)
- Static URI in gateway for local dev only (not for production)

### Authentication

Your Python service receives requests **after** gateway JWT validation.

Accept either:

| Source | Headers |
| --- | --- |
| Via gateway (production) | `X-User-Id`, `X-User-Email`, `X-User-Roles` |
| Direct call (local dev) | `Authorization: Bearer <vithey-jwt>` |

Use `VITHEY_JWT_SECRET` — same value as Java `auth-service` / gateway.

**Never** trust `user_id` from request body.

### Response format (must match Java services)

```json
{
  "data": { },
  "meta": { "page": 1, "limit": 20, "total": 0, "total_pages": 0 },
  "error": { "code": "NOT_FOUND", "message": "...", "details": null }
}
```

- JSON field names: **snake_case**
- Error codes: `UNAUTHORIZED`, `NOT_FOUND`, `VALIDATION_ERROR`, `RATE_LIMITED`, `UPSTREAM_ERROR`

### Required endpoints

See `API.md`. Minimum for Flutter chatbot:

- `POST /api/v1/ai/chat`
- `GET /api/v1/ai/sessions`
- `GET /api/v1/ai/sessions/{id}/messages`
- `DELETE /api/v1/ai/sessions/{id}`
- `POST /api/v1/ai/cv/suggest` (optional but in contract)
- `GET /actuator/health`

### Reusing GDCE `general-service` (chatbot only — recommended)

If your chatbot uses only the **`general`** container from `D:\GDCE-chatbot\chatbot_review\services_version2\general`:

| GDCE container | Port | Use for |
| --- | --- | --- |
| `general-service` | 8005 | RAG + LLM (`POST /retrieval/retrieve`) |
| `qdrant-general` | 6334 (host) | Vector DB (auto-started with general) |
| `redis-general` | 6382 (host) | Cache (auto-started with general) |

**Full chatbot guide:** `INTEGRATION-GENERAL.md`

Internal call from your Vithey Python `ai-service` → general:

```http
POST http://general-service:8005/retrieval/retrieve
Content-Type: application/json

{
  "query": "How to write a CV?",
  "session_id": "<vithey-session-uuid>",
  "generate_answer": true,
  "top_k": 10
}
```

Map `final_answer` → Vithey `data.reply`.

### Reusing full GDCE stack (optional, not needed for chatbot)

If you also use orchestrator / api-layer:

| GDCE service | Port | Use for |
| --- | --- | --- |
| `orchestrator-service` | 8001 | Query routing |
| `general-service` | 8005 | RAG + LLM |
| `api-layer` | 8000 | Has own auth — prefer orchestrator `/internal/*` for Vithey |

Internal call example (your Vithey Python → orchestrator):

```http
POST http://orchestrator-service:8001/internal/chat/send
Content-Type: application/json

{
  "chat_id": "<vithey-session-uuid>",
  "user_id": "<from X-User-Id>",
  "message": "How to write a CV?",
  "metadata": { "topic": "CV" }
}
```

## Docker networking

```text
vithey-network    ← Java: eureka, gateway, auth, redis, …
gdce-network      ← Your Python AI stack (optional)
```

Your Python `ai-service` container should join **both** networks when using GDCE upstream.

See `docker-compose.integration.example.yml`.

## Environment variables (Python ai-service)

```env
SERVER_PORT=8089
EUREKA_URL=http://eureka-server:8761/eureka/
EUREKA_ENABLED=true
VITHEY_JWT_SECRET=<same as auth-service>

# Your own DB for Vithey sessions (if needed)
AI_DB_URL=postgresql+asyncpg://postgres:postgres@ai-postgres:5432/ai_db

# Optional: upstream to your existing stack
GDCE_ORCHESTRATOR_URL=http://orchestrator-service:8001
```

## Verification checklist

```powershell
# Python service health
curl http://localhost:8089/actuator/health

# Eureka registration
curl http://localhost:8761/eureka/apps/AI-SERVICE

# Through Vithey gateway (needs valid JWT)
curl -X POST http://localhost:8080/api/v1/ai/chat `
  -H "Authorization: Bearer <token>" `
  -H "Content-Type: application/json" `
  -d '{"message":"Hello","topic":"STUDENT"}'
```

## What was removed from this Java repo

- Java `ai-service` Spring Boot implementation (deleted)
- `ai-service` Maven module (removed from `pom.xml`)
- Maven CI workflow for ai-service

Integration docs remain so you can wire your Python service correctly.
