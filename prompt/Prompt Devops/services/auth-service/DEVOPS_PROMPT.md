# Auth Service — DevOps Prompt

Create independent Docker Compose and GitHub Actions CI for `auth-service`.

**Compose rules:** `Prompt Devops/v1/06-per-service-docker-compose-prompt.md` · **Registry:** `_shared/SERVICE_REGISTRY.md`

## Service

| Item | Value |
| --- | --- |
| Source path | `backend/services/auth-service` |
| Port | `8081` |
| Image | `ghcr.io/<owner>/vithey-auth-service` |
| Database | `auth_db` |

## Docker Compose Output

```text
backend/services/auth-service/docker-compose.yml
backend/services/auth-service/.env.example
```

**Service compose containers only:**

- `auth-service`
- `auth-postgres`

**Shared infra** (already on `vithey-network` from `backend/infrastructure/`): `rabbitmq`, `eureka-server`, `config-server`

## Verification

```bash
cd backend/infrastructure && docker compose up -d --build
cd ../services/auth-service && copy .env.example .env
docker compose up -d --build
curl http://localhost:8081/actuator/health
docker compose down
```

## GitHub Actions Output

```text
.github/workflows/auth-service-ci.yml
```

Triggers: `backend/services/auth-service/**`, `backend/infrastructure/config-repo/auth-service.yml`

CI: Maven test, Docker build `SERVICE_PORT=8081`, validate compose file.
