# AI Service — DevOps Prompt

Create independent Docker Compose and GitHub Actions CI for `ai-service`.

## Service

| Item | Value |
| --- | --- |
| Source path | `vithey-backend/services/ai-service` |
| Port | `8089` |
| Image | `ghcr.io/<owner>/vithey-ai-service` |
| Database | `ai_db` |

## Docker Compose Output

Create:

```text
vithey-backend/docker-compose.ai-service.yml
vithey-backend/services/ai-service/.env.example
```

Required containers:

- `ai-service`
- `ai-postgres`
- `ai-redis`
- `ai-eureka-server`
- `ai-config-server`

AI provider keys must be optional in local dev. Tests must use a mock provider and never call a real AI API in CI.

Verification:

```bash
docker compose -f docker-compose.ai-service.yml up -d --build
curl http://localhost:8089/actuator/health
docker compose -f docker-compose.ai-service.yml down -v
```

## GitHub Actions Output

Create:

```text
.github/workflows/ai-service-ci.yml
```

CI must run Maven tests, build the Docker image with `SERVICE_PORT=8089`, and validate `docker-compose.ai-service.yml`.

