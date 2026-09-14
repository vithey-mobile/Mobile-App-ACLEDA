# Content Service — DevOps Prompt

Create independent Docker Compose and GitHub Actions CI for `content-service`.

**Compose rules:** `Prompt Devops/v1/06-per-service-docker-compose-prompt.md` · **Registry:** `_shared/SERVICE_REGISTRY.md`

## Service

| Item | Value |
| --- | --- |
| Source path | `backend/services/content-service` |
| Port | `8084` |
| Image | `ghcr.io/<owner>/vithey-content-service` |
| Database | `content_db` |

## Docker Compose Output

```text
backend/services/content-service/docker-compose.yml
backend/services/content-service/.env.example
```

**Service compose containers only:**

- `content-service`
- `content-postgres`

**Shared infra:** `rabbitmq`, `eureka-server`, `config-server`

## Verification

```bash
cd backend/infrastructure && docker compose up -d --build
cd ../services/content-service && copy .env.example .env
docker compose up -d --build
curl http://localhost:8084/actuator/health
docker compose down
```

## GitHub Actions Output

```text
.github/workflows/content-service-ci.yml
```

CI: Maven test, Docker build `SERVICE_PORT=8084`, validate compose file.
