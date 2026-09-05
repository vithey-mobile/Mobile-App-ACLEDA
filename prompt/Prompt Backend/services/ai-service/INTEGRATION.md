# AI / Chatbot — Java Platform Integration

> **Integration only.** You build chatbot + AI in Python.  
> Vithey Java repo provides gateway routing, JWT auth, and Eureka — not AI code.

## Architecture

```text
Vithey Flutter (chatbot module)
    │
    ▼
Java API Gateway :8080
    │  JWT validate → X-User-Id, X-User-Email, X-User-Roles
    │  /api/v1/ai/**
    ▼
Your Python ai-service :8089  (Eureka name: ai-service)
    └── your chatbot / LLM / orchestrator / RAG stack
```

## Java side — already configured

| Component | Status |
| --- | --- |
| Gateway route `/api/v1/ai/**` | `GatewayRouteConfig.java` |
| JWT + identity headers | `JwtAuthenticationGlobalFilter` |
| Eureka server | `infrastructure/eureka-server` |
| Integration docs | `Prompt Backend/services/ai-service/` |

**No Java implementation** for AI or chatbot in this repo.

## Python side — you implement

| Requirement | Detail |
| --- | --- |
| Eureka name | `ai-service` |
| Port | 8089 |
| API | `/api/v1/ai/**` per `API_ENDPOINTS.md` |
| Auth | `X-User-*` headers or Vithey JWT |
| Envelope | `{ data, meta, error }`, snake_case |
| Health | `GET /actuator/health` → `{"status":"UP"}` |

Full guide: this file (`Prompt Backend/services/ai-service/INTEGRATION.md`)

## chat-service vs ai-service

| Service | Lang | Port | Use |
| --- | --- | --- | --- |
| `chat-service` | Java | 8087 | User-to-user messaging |
| `ai-service` | Python | 8089 | Vithey AI chatbot |

## Reusing your GDCE Docker stack (optional)

Location: `D:\GDCE-chatbot\chatbot_review\`

| Container | Port |
| --- | --- |
| `orchestrator-service` | 8001 |
| `general-service` | 8005 |
| `api-layer-api-layer-1` | 8000 |
| `retrieval-service` | 8003 |

Network: `gdce-network`. Your Vithey Python service joins `vithey-network` + `gdce-network`.

Start:

```powershell
cd "D:\GDCE-chatbot\chatbot_review\backend\api-layer\scripts"
.\start-development.ps1 -SkipBuild
```

Prefer calling orchestrator `POST /internal/chat/send` with Vithey `user_id` — avoids GDCE's separate login.

## Verification

```powershell
curl http://localhost:8761/eureka/apps/AI-SERVICE
curl -X POST http://localhost:8080/api/v1/ai/chat `
  -H "Authorization: Bearer <vithey-jwt>" `
  -H "Content-Type: application/json" `
  -d '{"message":"Hello","topic":"CV"}'
```

## Checklist

- [ ] Register with Eureka as `ai-service` on port 8089
- [ ] Expose `/api/v1/ai/**` routes per `API_ENDPOINTS.md`
- [ ] Return `{ data, meta, error }` envelope with snake_case JSON
- [ ] Implement `GET /actuator/health` → `{"status":"UP"}`
- [ ] Join Docker network `vithey-network` (and `gdce-network` if using GDCE stack)
