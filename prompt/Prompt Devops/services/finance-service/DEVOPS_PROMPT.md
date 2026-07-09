# Finance Service — DevOps Prompt

Create independent Docker Compose and GitHub Actions CI for `finance-service`.

**Compose rules:** `Prompt Devops/v1/06-per-service-docker-compose-prompt.md` · **Registry:** `_shared/SERVICE_REGISTRY.md`

## Service

| Item | Value |
| --- | --- |
| Source path | `backend/services/finance-service` |
| Port | `8086` |
| Image | `ghcr.io/<owner>/vithey-finance-service` |
| Database | `finance_db` |

## Docker Compose Output

```text
backend/services/finance-service/docker-compose.yml
backend/services/finance-service/.env.example
```

**Service compose containers only:** `finance-service`, `finance-postgres`  
**Shared infra:** `rabbitmq`, `eureka-server`, `config-server`

## Verification

```bash
cd backend/infrastructure && docker compose up -d --build
cd ../services/finance-service && copy .env.example .env
docker compose up -d --build
curl http://localhost:8086/actuator/health
```

## GitHub Actions

`.github/workflows/finance-service-ci.yml` — Maven test, Docker build `SERVICE_PORT=8086`.
