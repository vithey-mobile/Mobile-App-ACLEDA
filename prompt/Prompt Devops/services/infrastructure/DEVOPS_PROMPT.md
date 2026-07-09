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

**Containers (shared only):** `postgres`, `redis`, `rabbitmq`, `minio`, `eureka-server`, `config-server`

Creates network `vithey-network`. Business services are **not** in this file.

## Verification

```bash
cd backend/infrastructure
copy .env.example .env
docker compose up -d --build
curl http://localhost:8761/actuator/health
curl http://localhost:8888/actuator/health
docker network inspect vithey-network
```

## GitHub Actions

`.github/workflows/infrastructure-ci.yml` — build Eureka + Config images, validate `infrastructure/docker-compose.yml`.

Triggers: `backend/infrastructure/**`
