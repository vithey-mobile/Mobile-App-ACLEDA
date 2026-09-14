# Vithey App — DevOps Common Context

## Objective
**Development:** Docker Compose for local full-stack runs.  
**Production:** Kubernetes (GKE / OpenShift / other) pulling the same images.  
**CI/CD:** GitHub Actions builds and publishes images to **GitHub Container Registry (GHCR)**.  
Local monitoring uses Docker Compose (Prometheus, Grafana, Loki); cluster monitoring is part of the production K8s phase.

Shareable plan: `DEVOPS_REQUIREMENTS_PROPOSAL.md`.

## App Stack
| Layer | Technology |
|-------|------------|
| Mobile | Flutter (`aub_connect_app`) — built locally, not containerized in v1 |
| Backend | Spring Boot 3 + Java 21 microservices |
| Gateway | Spring Cloud Gateway :8080 |
| Discovery | Eureka :8761 |
| Config | Spring Cloud Config :8888 |
| Data | PostgreSQL 16, Redis 7, RabbitMQ 3, MinIO |

## Environment split
| Env | Runtime | Notes |
|-----|---------|--------|
| Development | Docker Compose | `backend/docker-compose.yml` — one command for all services |
| Production | Kubernetes | Manifests/Helm; Ingress+TLS → api-gateway only |
| Images | Same GHCR tags | `ghcr.io/<owner>/vithey-<service>:sha-*` |

## Explicitly Excluded (early DevOps phases)
Do **not** treat Docker Compose as the production runtime.  
Defer until the K8s phase is scheduled:
- Full OpenTelemetry collectors (optional)
- Bank SOC / network policies (unless provided)

## Observability (v2 — `v1/08-monitoring-observability-prompt.md`)

**In scope** — Docker Compose only:

| Tool | Path | Purpose |
| --- | --- | --- |
| Prometheus | `monitoring/prometheus/` | Scrape `/actuator/prometheus` from all microservices |
| Grafana | `monitoring/grafana/` | Dashboards + log UI |
| Loki | `monitoring/loki/` | Centralized log storage |
| Promtail | `monitoring/promtail/` | Ship Docker container logs |
| Node Exporter | `monitoring/docker-compose.yml` | Host metrics |
| cAdvisor | `monitoring/docker-compose.yml` | Container metrics |

Output folder: `monitoring/` at repo root. Joins external network `vithey-network`.

Production readiness in v1 still means: **versioned images on GHCR + documented env vars + `docker-compose.prod.yml` template** that any future host can run.

## Target Repo Layout

See `_shared/REPO_PATHS.md` for canonical paths.

```text
monorepo/
├── .github/workflows/           # ci.yml, <service>-ci.yml, docker-publish.yml
├── backend/
│   ├── infrastructure/docker-compose.yml
│   ├── scripts/start-all.ps1
│   └── services/<name>/
│       ├── Dockerfile
│       ├── docker-compose.yml
│       └── .env.example
├── vithey_app/                  # Flutter
├── monitoring/                  # Prometheus, Grafana, Loki (see v1/08)
└── prompt/                      # all markdown docs
```

## Docker Image Registry
| Setting | Value |
|---------|-------|
| Registry | `ghcr.io` |
| Owner | GitHub org or username (e.g. `Kimheang-code-IT`) |
| Image prefix | `ghcr.io/<owner>/vithey-<service-name>` |
| Visibility | Private recommended for competition |

### Tag Strategy
| Tag | When |
|-----|------|
| `latest` | Default branch push (main) |
| `sha-abc1234` | Every successful build |
| `v1.0.0` | Git tag `v*` release |
| `pr-42` | Optional PR preview builds |

## Standard Dockerfile Pattern (Java services)
```dockerfile
# syntax=docker/dockerfile:1
FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn -q -DskipTests package

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
RUN addgroup -S vithey && adduser -S vithey -G vithey
USER vithey
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget -qO- http://localhost:${SERVER_PORT:-8080}/actuator/health || exit 1
ENTRYPOINT ["java", "-jar", "app.jar"]
```

## Environment Profiles
| Profile | Use |
|---------|-----|
| `dev` | Local Docker Compose, H2 optional, debug logging |
| `docker` | All services in Compose network |
| `prod` | External DB URLs, secrets from env, minimal logging |

## Required Environment Variables (summary)
See `docs/ENV.md` for full list. Key groups:
- **Database:** `SPRING_DATASOURCE_URL`, `SPRING_DATASOURCE_USERNAME`, `SPRING_DATASOURCE_PASSWORD`
- **JWT:** `JWT_SECRET` (shared auth + gateway)
- **Eureka:** `EUREKA_CLIENT_SERVICE_URL`
- **RabbitMQ:** `SPRING_RABBITMQ_HOST`, `SPRING_RABBITMQ_USERNAME`, `SPRING_RABBITMQ_PASSWORD`
- **Redis:** `SPRING_DATA_REDIS_HOST`
- **MinIO:** `MINIO_ENDPOINT`, `MINIO_ACCESS_KEY`, `MINIO_SECRET_KEY`
- **AI:** `AI_API_KEY`, `AI_PROVIDER`, `AI_MODEL`
- **FCM:** `FIREBASE_CREDENTIALS_JSON` (base64 in CI)

## GitHub Actions Requirements
### Secrets (repository settings)
| Secret | Purpose |
|--------|---------|
| `GITHUB_TOKEN` | Auto-provided — used for GHCR push |
| `JWT_SECRET` | CI integration tests |
| `AI_API_KEY` | Optional AI service tests |

### Workflow Triggers
- `ci.yml` — on PR and push to `main`, `Prompt`, `develop`
- `docker-publish.yml` — on push to `main` + manual `workflow_dispatch`
- `release.yml` — on push tag `v*.*.*`

### CI Jobs
1. **backend-ci** — Maven test all changed services (matrix or sequential)
2. **docker-build** — build images, push to GHCR with proper tags
3. **compose-validate** — `docker compose config` lint

### Per-Service CI Jobs
Each backend service also has a dedicated workflow:

```text
.github/workflows/<service>-ci.yml
```

Each per-service workflow runs only when its service folder, service Compose file, service config, or workflow file changes.

## Local Development Commands

See `Prompt Devops/DOCKER.md` for current per-folder commands.

```powershell
cd backend
.\scripts\start-all.ps1
curl http://localhost:8080/actuator/health
```

## Service Ports (local)

See `_shared/SERVICE_REGISTRY.md` (do not copy port table here).

## Network
- Compose network name: `vithey-network`
- All services use service name as hostname (e.g. `http://auth-service:8081`)

## Health & Startup Order
1. postgres, redis, rabbitmq, minio
2. eureka-server, config-server
3. domain services (auth first)
4. api-gateway last

Use `depends_on` + `healthcheck` + Spring `spring.cloud.discovery.wait` where needed.

## Security Rules
- Never commit `.env`, credentials, or `firebase-*.json`
- `.dockerignore` on every service — exclude `target/`, `.git`, `*.md`
- Non-root user in production images
- Scan images with `docker scout` or Trivy in CI (optional step)

## Documentation Deliverables

In `prompt/Prompt Devops/` only (not in `backend/`):

- `docs/LOCAL_DEV.md`, `docs/ENV.md`, `DOCKER.md`, `DOCKER-VERIFY.md`

## Standardization Rule

- One Dockerfile pattern for all Java microservices
- One compose file per service folder: `backend/services/<name>/docker-compose.yml`
- Shared infra only in `backend/infrastructure/docker-compose.yml`
- One CI workflow per service: `.github/workflows/<service>-ci.yml`
- Local and prod use the same images — only env vars differ
