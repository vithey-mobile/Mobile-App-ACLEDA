# Repository Paths

Canonical output paths for generated code. Use **`backend/`** everywhere (not `vithey-backend/`).

| Output | Path | Stack |
| --- | --- | --- |
| Flutter app | `vithey_app/` | Flutter, GetX, Dio — `pubspec.yaml` name: `aub_connect_app` |
| Java backend | `backend/` | Java 21, Spring Boot 3.3.5, Maven multi-module |
| Python AI | `ai_core/` | FastAPI — owns `/api/v1/ai/**` on port **8100** |
| Shared infra | `backend/infrastructure/` | Eureka, Config, Postgres, Redis, RabbitMQ, MinIO |
| Microservice | `backend/services/<name>/` | One Spring Boot app per folder |
| Docker scripts | `backend/scripts/` | `start-all.ps1` (preferred), `docker-up*.ps1`, `verify-docker.ps1`, `smoke-api.ps1` |
| Monitoring | `monitoring/` | Prometheus, Grafana, Loki, Promtail |
| CI workflows | `.github/workflows/` | Per-service and monorepo CI |

## Docker compose layout (current)

```text
backend/
├── docker-compose.yml                 # full stack (infra + Java services + ai_core)
├── docker-compose.demo.yml            # Profile M overlay (lean caps / demo)
├── .env                               # Compose vars (MINIO_PUBLIC_ENDPOINT written by start-all.ps1)
├── infrastructure/docker-compose.yml  # infra-only / incremental
├── scripts/start-all.ps1              # preferred one-command start
└── services/<name>/
    ├── Dockerfile
    ├── docker-compose.yml             # single-service incremental run
    └── .env.example
```

**Preferred local start** (from `backend/`):

```powershell
.\scripts\start-all.ps1
```

That script detects LAN IPv4, sets `MINIO_PUBLIC_ENDPOINT`, syncs `vithey_app/.env` API/WS URLs, then `docker compose up -d --build`.

Operational docs: `docs/Prompt Devops/DOCKER.md`.

## Prompt docs

All markdown prompts live under **`docs/`** (not `prompt/`):

- `docs/_shared/` — registry, paths, read order
- `docs/Prompt Backend/` — service build prompts
- `docs/Prompt Devops/` — Docker and CI prompts
- `docs/Prompt Frontend/` — UI and API contract
- `docs/Prompt Al/` — AI screen prompts

Do **not** create `README.md`, `API.md`, or nested `docs/` inside `backend/` beyond what already exists (`DOCKER.md`, `DEMO.md`, `TESTING.md`).
