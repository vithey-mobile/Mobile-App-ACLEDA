# File Service — DevOps Prompt

Create independent Docker Compose and GitHub Actions CI for `file-service`.

**Compose rules:** `Prompt Devops/v1/06-per-service-docker-compose-prompt.md` · **Registry:** `_shared/SERVICE_REGISTRY.md`

## Service

| Item | Value |
| --- | --- |
| Source path | `backend/services/file-service` |
| Port | `8083` |
| Image | `ghcr.io/<owner>/vithey-file-service` |
| Database | `file_db` |

## Docker Compose Output

```text
backend/services/file-service/docker-compose.yml
backend/services/file-service/.env.example
```

**Service compose containers only:** `file-service`, `file-postgres`  
**Shared infra:** `minio`, `eureka-server`, `config-server`

## Verification

```bash
cd backend/infrastructure && docker compose up -d --build
cd ../services/file-service && copy .env.example .env
docker compose up -d --build
curl http://localhost:8083/actuator/health
```

## GitHub Actions

`.github/workflows/file-service-ci.yml` — Maven test, Docker build `SERVICE_PORT=8083`.
