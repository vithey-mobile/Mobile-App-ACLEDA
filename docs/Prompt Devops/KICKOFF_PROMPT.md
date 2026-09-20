# Vithey App — DevOps Kickoff Prompt

You are building **DevOps infrastructure** for Vithey App. Work **one prompt at a time**.

## Read first

1. `_shared/READ_ORDER.md`
2. `COMMON_CONTEXT.md`
3. `v1/06-per-service-docker-compose-prompt.md` (current compose model)
4. The `TASK:` prompt (`v1/*.md` or `services/<name>/DEVOPS_PROMPT.md`)

## Scope

| In scope | Out of scope |
| --- | --- |
| Per-folder Docker Compose | VPS, Nginx, SSL |
| Dockerfiles + GHCR CI | Kubernetes (later) |
| Monitoring stack (`monitoring/`) | OpenTelemetry (for now) |
| `.env.example`, health checks | |
| `backend/scripts/start-all.ps1` | Business logic changes |

## Components

Paths and images: `_shared/SERVICE_REGISTRY.md` and `_shared/REPO_PATHS.md`.

Infrastructure uses official images locally: PostgreSQL, Redis, RabbitMQ, MinIO.

## Rules

- Docker Compose v2 (`docker compose`)
- Multi-stage Dockerfile: Maven → JRE 21
- Secrets in `.env.example` + GitHub Secrets only
- Per-service compose at `backend/services/<name>/docker-compose.yml`
- Shared infra at `backend/infrastructure/docker-compose.yml`
- Env vars documented in `prompt/Prompt Devops/docs/ENV.md`

## Execution order

1. `v1/00-foundation-prompt.md`
2. `v1/02-dockerfiles-prompt.md`
3. `v1/03` → `v1/05` (CI, GHCR, prod template)
4. `v1/06-per-service-docker-compose-prompt.md`
5. `v1/07-per-service-github-actions-ci-prompt.md`
6. `v1/08-monitoring-observability-prompt.md`
7. `services/<name>/DEVOPS_PROMPT.md`

Skip `v1/01` (deprecated all-in-one compose).

## Verify

```powershell
cd backend
.\scripts\start-all.ps1
curl http://localhost:8080/actuator/health
```

Operational docs: `DOCKER.md`
