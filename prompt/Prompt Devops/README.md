# Prompt Devops — Vithey App

Docker Compose, Dockerfiles, and GitHub Actions (CI → GHCR) prompts.

## Start

1. `_shared/READ_ORDER.md`
2. `KICKOFF_PROMPT.md` + `COMMON_CONTEXT.md`
3. `v1/06-per-service-docker-compose-prompt.md` (current compose model)
4. `services/<name>/DEVOPS_PROMPT.md` for one service

## Operational docs (run the stack)

| File | Purpose |
| --- | --- |
| `DOCKER.md` | **Primary** — per-folder Docker guide |
| `DOCKER-VERIFY.md` | Verification and troubleshooting |
| `docs/ENV.md` | Environment variables |
| `RUN-SERVICES.md` | Pointer to `DOCKER.md` (legacy alias) |

## Scaffolding prompts (`v1/`)

| File | Purpose |
| --- | --- |
| `00-foundation-prompt.md` | Repo layout, Makefile, `.env.example` |
| `01-local-docker-compose-prompt.md` | **Legacy** all-in-one compose (deprecated) |
| `02-dockerfiles-prompt.md` | Multi-stage Dockerfiles |
| `03`–`05` | CI, GHCR, production template |
| `06-per-service-docker-compose-prompt.md` | **Current** per-service compose |
| `07-per-service-github-actions-ci-prompt.md` | Per-service CI |

## Output

Generates under `backend/` — see `_shared/REPO_PATHS.md`.

Documentation stays in `prompt/Prompt Devops/` (not in `backend/`).

## Master prompt

`MASTER_AI_PROMPT.md` — set `TASK:` to `v1/*.md` or `services/<name>/DEVOPS_PROMPT.md`.
