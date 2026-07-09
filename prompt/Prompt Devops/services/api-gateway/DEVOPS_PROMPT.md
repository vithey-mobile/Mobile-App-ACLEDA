# API Gateway — DevOps Prompt

Create independent Docker Compose and GitHub Actions CI for `api-gateway`.

**Compose rules:** `Prompt Devops/v1/06-per-service-docker-compose-prompt.md` · **Registry:** `_shared/SERVICE_REGISTRY.md`

## Service

| Item | Value |
| --- | --- |
| Source path | `backend/services/api-gateway` |
| Port | `8080` |
| Image | `ghcr.io/<owner>/vithey-api-gateway` |
| Database | none |

## Docker Compose Output

```text
backend/services/api-gateway/docker-compose.yml
backend/services/api-gateway/.env.example
```

**Service compose containers only:**

- `api-gateway`

**Shared infra:** `redis`, `eureka-server`, `config-server` — no Postgres or RabbitMQ in this compose.

Start **after** domain services register in Eureka.

## Verification

```bash
cd backend/infrastructure && docker compose up -d --build
cd ../services/api-gateway && copy .env.example .env
docker compose up -d --build
curl http://localhost:8080/actuator/health
docker compose down
```

## GitHub Actions Output

```text
.github/workflows/api-gateway-ci.yml
```

Triggers: `backend/services/api-gateway/**`, `backend/infrastructure/config-repo/api-gateway.yml`

CI: Maven test, Docker build `SERVICE_PORT=8080`, validate compose file.
