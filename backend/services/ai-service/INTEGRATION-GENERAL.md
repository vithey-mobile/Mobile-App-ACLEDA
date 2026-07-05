# Chatbot Integration — `general` + `ai-service` (complete)

> Vithey chatbot uses **2 stacks only**. Other GDCE AI services can be stopped.

## Architecture

```text
Vithey Flutter (chatbot)
        │
        ▼
Java API Gateway :8080  (/api/v1/ai/**)
        │
        ▼
vithey-ai-service :8089        ← backend/services/ai-service (Python, built)
        │  POST /retrieval/retrieve
        ▼
general-service :8005            ← GDCE general stack
        ├── qdrant-general
        └── redis-general
```

## What is implemented in this repo

| Component | Location | Status |
| --- | --- | --- |
| Java ai-service | `backend/services/ai-service/` | **Built** |
| General HTTP client | `client/GeneralRetrievalClient.java` | **Built** |
| Sessions + messages DB | Flyway `V1__init_ai_schema.sql` | **Built** |
| Docker compose | `docker-compose.yml` | **Built** |
| Gateway route | `api-gateway` → `lb://ai-service` | Already in Java |

## Services you can STOP

These GDCE containers are **not needed** for Vithey chatbot:

| Container | Why not needed |
| --- | --- |
| `orchestrator-service` | Vithey ai-service calls general directly |
| `api-layer` | Has its own auth; not used |
| `retrieval-service` (8003) | HS-code retrieval, not chatbot |
| `qdrant` (6333) | HS-code vectors, not general |

**Keep running:**

- `general-service` (8005)
- `qdrant-general`
- `redis-general`

Stop others:

```powershell
cd "D:\project\Acleda Mobile App\backend\services\ai-service"
.\scripts\stop-other-gdce-services.ps1
```

## Start order

```powershell
# 1 Networks
docker network create vithey-network
docker network create gdce-network

# 2 Vithey infrastructure + gateway (if not running)
cd "D:\project\Acleda Mobile App\backend\infrastructure"
docker compose up -d --build

cd "D:\project\Acleda Mobile App\backend\services\api-gateway"
docker compose up -d --build

# 3 GDCE general only
cd "D:\GDCE-chatbot\chatbot_review\services_version2\general"
docker compose up -d --build

# 4 Stop other GDCE AI (optional)
cd "D:\project\Acleda Mobile App\backend\services\ai-service"
.\scripts\stop-other-gdce-services.ps1

# 5 Vithey ai-service
copy .env.example .env
docker compose up -d --build
```

## How ai-service calls general

On `POST /api/v1/ai/chat`:

1. Read `X-User-Id` from gateway (or JWT for direct calls)
2. Save user message to `vithey-ai-postgres`
3. Call general:

```http
POST http://general-service:8005/retrieval/retrieve

{
  "query": "CV and resume writing: How to write a good CV?",
  "session_id": "<uuid>",
  "generate_answer": true,
  "top_k": 10
}
```

4. Map `final_answer` → Vithey `data.reply`
5. Save assistant message, return Vithey envelope

## Environment variables

See `.env.example`:

| Variable | Default | Purpose |
| --- | --- | --- |
| `GENERAL_SERVICE_URL` | `http://general-service:8005` | GDCE general upstream |
| `EUREKA_URL` | `http://eureka-server:8761/eureka/` | Service discovery |
| `VITHEY_JWT_SECRET` | same as auth-service | JWT validation |
| `AI_DB_URL` | `postgresql+asyncpg://...@ai-postgres:5432/ai_db` | Chat sessions |

## Verify

```powershell
# General
curl http://localhost:8005/health

# ai-service
curl http://localhost:8089/actuator/health

# Eureka
curl http://localhost:8761/eureka/apps/AI-SERVICE

# Through gateway (needs JWT)
curl -X POST http://localhost:8080/api/v1/ai/chat `
  -H "Authorization: Bearer <token>" `
  -H "Content-Type: application/json" `
  -d '{"message":"How to write a CV?","topic":"CV"}'
```

## Stop only ai-service (general keeps running)

```powershell
cd "D:\project\Acleda Mobile App\backend\services\ai-service"
docker compose down
```

General stack continues independently on `gdce-network`.
