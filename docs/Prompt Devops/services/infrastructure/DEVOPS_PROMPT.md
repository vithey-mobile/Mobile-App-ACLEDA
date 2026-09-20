# Infrastructure — DevOps Prompt

Create shared infrastructure Docker Compose and GitHub Actions CI.

**Registry:** `_shared/SERVICE_REGISTRY.md` · **Paths:** `_shared/REPO_PATHS.md`

## Modules

| Module | Path | Port | Image |
| --- | --- | --- | --- |
| Eureka Server | `backend/infrastructure/eureka-server` | `8761` | `ghcr.io/<owner>/vithey-eureka-server` |
| Config Server | `backend/infrastructure/config-server` | `8888` | `ghcr.io/<owner>/vithey-config-server` |
| Config Repo | `backend/infrastructure/config-repo` | — | — |

## Docker Compose Output

```text
backend/infrastructure/docker-compose.yml
backend/infrastructure/.env.example
```

**Containers (shared only):** `postgres`, `redis`, `rabbitmq`, `minio` (`quay.io/minio/minio:latest`), `eureka-server`, `config-server`

Creates network `vithey-network`. Business services are **not** in this file.

Host ports: Postgres **15432**, Redis **16379**, MinIO API **19000** / console **19001**.

Preferred full-stack start (infra + services + ai_core):

```powershell
cd backend
.\scripts\start-all.ps1
# or infra only:
.\scripts\start-all.ps1 -InfraOnly
```

## Verification

```powershell
cd backend\infrastructure
copy .env.example .env
docker compose up -d --build
curl http://localhost:8761/actuator/health
curl http://localhost:8888/actuator/health
docker network inspect vithey-network
```

## GitHub Actions

`.github/workflows/infrastructure-ci.yml` — build Eureka + Config images, validate `infrastructure/docker-compose.yml`.

Triggers: `backend/infrastructure/**`
