# Vithey App — DevOps Kickoff Prompt

You are building **DevOps infrastructure** for the Vithey App (Flutter frontend + Spring Boot microservices). Use the provided context files and work **one prompt at a time**.

## Read First
1. `COMMON_CONTEXT.md`
2. `Prompt Frontend/api-intergration/integration-contract.md` (API + ports context)
3. The specific prompt in `v1/` or `services/<service>/DEVOPS_PROMPT.md` you are about to execute

## Scope
| In Scope | Out of Scope (do NOT build) |
|----------|----------------------------|
| Local development with Docker Compose | Ubuntu VPS setup |
| Dockerfiles (multi-stage) for all services | Nginx reverse proxy |
| GitHub Actions CI (build + test) | Certbot / SSL |
| GitHub Actions → push images to **GHCR** | Prometheus |
| Per-service Docker Compose files | Service business logic changes |
| Per-service GitHub Actions CI workflows | Manual click-only CI steps |
| `.env` templates and secrets guidance | Grafana |
| Production-ready **container images** and compose templates | Loki / ELK logging stack |
| Health checks, Makefile, developer docs | Kubernetes (optional later) |

## Project Components to Containerize
| Component | Source Path (expected) | Image Name |
|-----------|------------------------|------------|
| API Gateway | `vithey-backend/services/api-gateway` | `ghcr.io/<owner>/vithey-api-gateway` |
| Auth Service | `vithey-backend/services/auth-service` | `ghcr.io/<owner>/vithey-auth-service` |
| User Profile | `vithey-backend/services/user-profile-service` | `ghcr.io/<owner>/vithey-user-profile-service` |
| File Service | `vithey-backend/services/file-service` | `ghcr.io/<owner>/vithey-file-service` |
| Content Service | `vithey-backend/services/content-service` | `ghcr.io/<owner>/vithey-content-service` |
| Career Service | `vithey-backend/services/career-service` | `ghcr.io/<owner>/vithey-career-service` |
| Finance Service | `vithey-backend/services/finance-service` | `ghcr.io/<owner>/vithey-finance-service` |
| Chat Service | `vithey-backend/services/chat-service` | `ghcr.io/<owner>/vithey-chat-service` |
| Notification Service | `vithey-backend/services/notification-service` | `ghcr.io/<owner>/vithey-notification-service` |
| AI Service | `vithey-backend/services/ai-service` | `ghcr.io/<owner>/vithey-ai-service` |
| Eureka Server | `vithey-backend/infrastructure/eureka-server` | `ghcr.io/<owner>/vithey-eureka-server` |
| Config Server | `vithey-backend/infrastructure/config-server` | `ghcr.io/<owner>/vithey-config-server` |

Infrastructure only (use official images locally): PostgreSQL, Redis, RabbitMQ, MinIO.

## Rules
- **DevOps only** — do not rewrite business logic in services.
- Use **Docker Compose v2** syntax (`docker compose`, not `docker-compose`).
- All Java services: **multi-stage Dockerfile** (Maven build → JRE 21 runtime).
- Images tagged: `latest`, `sha-<git-sha>`, and semver on release tags.
- Secrets never committed — use `.env.example` + GitHub Secrets.
- Local dev must work with **one command** after clone.
- Production prep = **publishable images + env config** — not server provisioning.

## Recommended Execution Order
1. `v1/00-foundation-prompt.md` — repo layout, `.gitignore`, env templates, Makefile
2. `v1/01-local-docker-compose-prompt.md` — full local stack
3. `v1/02-dockerfiles-prompt.md` — Dockerfile per service
4. `v1/03-github-actions-ci-prompt.md` — CI: test + build on PR/push
5. `v1/04-github-actions-ghcr-prompt.md` — build & push images to GHCR
6. `v1/05-production-ready-prompt.md` — prod compose template, release workflow, secrets map
7. `v1/06-per-service-docker-compose-prompt.md` — independent Compose file per service
8. `v1/07-per-service-github-actions-ci-prompt.md` — independent CI workflow per service
9. `services/<service>/DEVOPS_PROMPT.md` — run one service independently

## Working Style
- Complete one prompt fully before the next.
- Verify locally: `docker compose up -d` → gateway health `http://localhost:8080/actuator/health`
- GitHub Actions must use path filters so only changed services rebuild.
- Per-service CI must live in `.github/workflows/<service>-ci.yml`.
- Per-service Compose must live in the service folder at `vithey-backend/services/<service>/docker-compose.yml`.
- Shared infrastructure compose lives at `vithey-backend/infrastructure/docker-compose.yml`.
- Document every env var in `vithey-backend/docs/ENV.md` (created by DevOps prompts).

## Output Quality
- Runnable files, not placeholders.
- Comments in YAML only where non-obvious.
- README with copy-paste commands for Windows (PowerShell) and Linux/macOS.
