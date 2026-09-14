# Career Service — DevOps Prompt

Create independent Docker Compose and GitHub Actions CI for `career-service`.

**Compose rules:** `Prompt Devops/v1/06-per-service-docker-compose-prompt.md` · **Registry:** `_shared/SERVICE_REGISTRY.md`

## Service

| Item | Value |
| --- | --- |
| Source path | `backend/services/career-service` |
| Port | `8085` |
| Image | `ghcr.io/<owner>/vithey-career-service` |
| Database | `career_db` |

## Docker Compose Output

```text
backend/services/career-service/docker-compose.yml
backend/services/career-service/.env.example
```

**Service compose containers only:** `career-service`, `career-postgres`  
**Shared infra:** `rabbitmq`, `eureka-server`, `config-server`

## Verification

```bash
cd backend/infrastructure && docker compose up -d --build
cd ../services/career-service && copy .env.example .env
docker compose up -d --build
curl http://localhost:8085/actuator/health
```

## GitHub Actions

`.github/workflows/career-service-ci.yml` — Maven test, Docker build `SERVICE_PORT=8085`.
