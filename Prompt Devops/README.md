# Prompt Devops — Vithey App

Docker Compose, Dockerfiles, and GitHub Actions (CI → GHCR) prompts.

## Start

1. Read `KICKOFF_PROMPT.md`
2. Read `COMMON_CONTEXT.md`
3. Run `v1/` prompts in order: `00` → `07`
4. For one-service setup, read `services/README.md` and the target `services/<service>/DEVOPS_PROMPT.md`

## Prompts

| File | Purpose |
|------|---------|
| `v1/00-foundation-prompt.md` | Repo layout, Makefile, `.env.example` |
| `v1/01-local-docker-compose-prompt.md` | Local Postgres, Redis, RabbitMQ, MinIO, services |
| `v1/02-dockerfiles-prompt.md` | Multi-stage Dockerfiles per service |
| `v1/03-github-actions-ci-prompt.md` | Maven build + test on PR |
| `v1/04-github-actions-ghcr-prompt.md` | Push images to GHCR |
| `v1/05-production-ready-prompt.md` | Prod compose, health checks |
| `v1/06-per-service-docker-compose-prompt.md` | Independent Docker Compose per service |
| `v1/07-per-service-github-actions-ci-prompt.md` | Independent GitHub Actions CI per service |
| `services/README.md` | Per-service DevOps prompt index |

## Output

Generates under `vithey-backend/`:
- `docker-compose.yml` (+ infra/apps/prod variants)
- `docker-compose.<service>.yml` for independent service runs
- `services/*/Dockerfile`
- `.github/workflows/ci.yml`, `docker-publish.yml`, and `<service>-ci.yml`
- `docs/ENV.md`, `LOCAL_DEV.md`, `DEPLOYMENT.md` (created during build)

## When to run

**Before backend services** — Phase 0 in `Prompt Frontend/02-ai-implementation-guide.md`.

## Master prompt

Use `MASTER_AI_PROMPT.md` at repo root — set `TASK:` to any `v1/*.md` file or `Prompt Devops/services/<service>/DEVOPS_PROMPT.md`.
