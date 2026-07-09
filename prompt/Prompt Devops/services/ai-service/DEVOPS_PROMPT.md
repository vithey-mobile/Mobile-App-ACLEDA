# AI Service — DevOps Prompt

Java `ai-service` stub exists in `backend/services/ai-service/` with its own `docker-compose.yml`.

**Integration (Python optional):** `Prompt Backend/services/ai-service/INTEGRATION.md`  
**Registry:** `_shared/SERVICE_REGISTRY.md`

## Service

| Item | Value |
| --- | --- |
| Source path | `backend/services/ai-service` |
| Port | `8089` |
| Image | `ghcr.io/<owner>/vithey-ai-service` |
| Database | `ai_db` |

## Docker Compose Output

```text
backend/services/ai-service/docker-compose.yml
backend/services/ai-service/.env.example
```

**Service compose containers only:** `ai-service`, `ai-postgres`  
**Shared infra:** `redis`, `eureka-server`, `config-server`  
**Optional:** join external `gdce-network` if bridging to external Python stack.

## Verification

```bash
cd backend/infrastructure && docker compose up -d --build
cd ../services/ai-service && copy .env.example .env
docker compose up -d --build
curl http://localhost:8089/actuator/health
curl http://localhost:8761/eureka/apps/AI-SERVICE
```

## GitHub Actions

`.github/workflows/ai-service-ci.yml` — Maven test, Docker build `SERVICE_PORT=8089`.

For a **Python-only** replacement, build CI in your Python repo; keep Eureka name `ai-service` and port `8089`.
