# 00 - DevOps Foundation Prompt

Build the **DevOps foundation** for Vithey App — folder structure, ignore files, env templates, Makefile, and documentation scaffolding.

## Goal
Create the repo-level DevOps skeleton so Docker Compose and GitHub Actions can be added in later prompts.

## Depends On
- Backend services exist or will exist under `vithey-backend/`
- Read `../COMMON_CONTEXT.md`

## Must Create

### Root / Backend DevOps Files
```text
vithey-backend/
├── .dockerignore
├── .env.example
├── Makefile
├── docker/
│   ├── postgres/init-databases.sql
│   └── minio/create-buckets.sh
└── docs/
    ├── ENV.md
    ├── LOCAL_DEV.md
    └── DEPLOYMENT.md
```

### `.env.example`
Include all variables from COMMON_CONTEXT with safe defaults for local:
```env
COMPOSE_PROJECT_NAME=vithey
POSTGRES_USER=vithey
POSTGRES_PASSWORD=vithey
JWT_SECRET=change-me-in-production-min-32-chars
EUREKA_URL=http://eureka-server:8761/eureka/
CONFIG_SERVER_URL=http://config-server:8888
RABBITMQ_USER=vithey
RABBITMQ_PASS=vithey
MINIO_ROOT_USER=vithey
MINIO_ROOT_PASSWORD=vithey123
AI_PROVIDER=openai
AI_API_KEY=
GHCR_OWNER=Kimheang-code-IT
```

### `docker/postgres/init-databases.sql`
Create: `auth_db`, `user_db`, `content_db`, `career_db`, `finance_db`, `chat_db`, `notification_db`, `ai_db`.

### `docker/minio/create-buckets.sh`
Create buckets: `avatars`, `cvs`, `posters`, `videos`.

### `Makefile` Targets
| Target | Action |
|--------|--------|
| `make up` | `docker compose up -d --build` |
| `make down` | `docker compose down` |
| `make down-v` | `docker compose down -v` |
| `make logs` | `docker compose logs -f` |
| `make infra` | Start infra only |
| `make health` | Curl gateway health |
| `make ps` | `docker compose ps` |

### `docs/ENV.md`
Table of every env var: name, required, default, used by which service.

### `docs/LOCAL_DEV.md`
Prerequisites (Docker Desktop, Java 21 optional for IDE), clone, copy `.env`, `make up`, verify URLs.

### `docs/DEPLOYMENT.md`
Generic future deployment (no VPS/Nginx):
1. Pull images from GHCR
2. Copy `.env.prod.example` → `.env`
3. Run `docker compose -f docker-compose.prod.yml up -d`
4. Point mobile app to gateway URL

### `.dockerignore` (shared template)
```
target/
.git/
.idea/
*.md
.env
.env.*
```

## Rules
- No Docker Compose yet — that is prompt 01.
- No GitHub Actions yet — prompts 03–04.
- Windows-compatible Makefile or provide `Makefile` + `scripts/dev.ps1` equivalent.

## Output
Complete foundation files ready for Compose and CI prompts.
