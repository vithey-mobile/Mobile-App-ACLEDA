# Notification Service — DevOps Prompt

Create independent Docker Compose and GitHub Actions CI for `notification-service`.

**Compose rules:** `Prompt Devops/v1/06-per-service-docker-compose-prompt.md` · **Registry:** `_shared/SERVICE_REGISTRY.md`

## Service

| Item | Value |
| --- | --- |
| Source path | `backend/services/notification-service` |
| Port | `8088` |
| Image | `ghcr.io/<owner>/vithey-notification-service` |
| Database | `notification_db` |

## Docker Compose Output

```text
backend/services/notification-service/docker-compose.yml
backend/services/notification-service/.env.example
```

**Service compose containers only:** `notification-service`, `notification-postgres`  
**Shared infra:** `rabbitmq`, `eureka-server`, `config-server`

## Verification

```bash
cd backend/infrastructure && docker compose up -d --build
cd ../services/notification-service && copy .env.example .env
docker compose up -d --build
curl http://localhost:8088/actuator/health
```

## GitHub Actions

`.github/workflows/notification-service-ci.yml` — Maven test, Docker build `SERVICE_PORT=8088`.
