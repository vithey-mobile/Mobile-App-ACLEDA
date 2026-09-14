# User Profile Service — DevOps Prompt

Create independent Docker Compose and GitHub Actions CI for `user-profile-service`.

**Compose rules:** `Prompt Devops/v1/06-per-service-docker-compose-prompt.md` · **Registry:** `_shared/SERVICE_REGISTRY.md`

## Service

| Item | Value |
| --- | --- |
| Source path | `backend/services/user-profile-service` |
| Port | `8082` |
| Image | `ghcr.io/<owner>/vithey-user-profile-service` |
| Database | `user_db` |

## Docker Compose Output

```text
backend/services/user-profile-service/docker-compose.yml
backend/services/user-profile-service/.env.example
```

**Service compose containers only:** `user-profile-service`, `profile-postgres`  
**Shared infra:** `rabbitmq`, `eureka-server`, `config-server`

## Verification

```bash
cd backend/infrastructure && docker compose up -d --build
cd ../services/user-profile-service && copy .env.example .env
docker compose up -d --build
curl http://localhost:8082/actuator/health
```

## GitHub Actions

`.github/workflows/user-profile-service-ci.yml` — Maven test, Docker build `SERVICE_PORT=8082`.
