# Vithey App — DevOps Common Context

## Objective
Provide Docker-based local development and GitHub Actions CI/CD that builds and publishes container images to **GitHub Container Registry (GHCR)**. Prepare the project for future production deployment without provisioning servers, reverse proxies, SSL, or observability stacks in this phase.

## App Stack
| Layer | Technology |
|-------|------------|
| Mobile | Flutter (`aub_connect_app`) — built locally, not containerized in v1 |
| Backend | Spring Boot 3 + Java 21 microservices |
| Gateway | Spring Cloud Gateway :8080 |
| Discovery | Eureka :8761 |
| Config | Spring Cloud Config :8888 |
| Data | PostgreSQL 16, Redis 7, RabbitMQ 3, MinIO |

## Explicitly Excluded (v1 DevOps)
Do **not** create prompts, configs, or workflows for:
- Ubuntu VPS provisioning
- Nginx / Traefik / Caddy reverse proxy
- Certbot / Let's Encrypt SSL
- Prometheus / Grafana metrics
- Loki / ELK centralized logging
- Kubernetes manifests (defer to later phase)

Production readiness in v1 means: **versioned images on GHCR + documented env vars + `docker-compose.prod.yml` template** that any future host can run.

## Target Repo Layout
```text
vithey-platform/                    # or monorepo root
├── .github/
│   └── workflows/
│       ├── ci.yml                  # test + maven build
│       ├── docker-publish.yml      # push to GHCR
│       ├── release.yml             # tag-based release images
│       ├── auth-service-ci.yml      # per-service CI
│       ├── content-service-ci.yml
│       └── ... one <service>-ci.yml per backend service
├── docker/
│   ├── postgres/init-databases.sql
│   └── minio/create-buckets.sh
├── docs/
│   ├── ENV.md
│   ├── LOCAL_DEV.md
│   └── DEPLOYMENT.md               # future host instructions (generic)
├── vithey-backend/
│   ├── docker-compose.yml          # local full stack
│   ├── docker-compose.infra.yml    # postgres, redis, rabbitmq, minio only
│   ├── docker-compose.apps.yml     # microservices only
│   ├── docker-compose.prod.yml     # image-based prod template
│   ├── docker-compose.auth-service.yml
│   ├── docker-compose.content-service.yml
│   ├── docker-compose.ai-service.yml
│   ├── ... one docker-compose.<service>.yml per backend service
│   ├── .env.example
│   ├── Makefile
│   └── services/
│       └── <service>/Dockerfile
├── aub_connect_app/                # Flutter (local dev)
└── README.md
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
```bash
# Start infrastructure only
docker compose -f docker-compose.infra.yml up -d

# Start full stack
docker compose up -d --build

# Start one service independently
docker compose -f docker-compose.auth-service.yml up -d --build

# View logs
docker compose logs -f api-gateway

# Stop and remove
docker compose down -v

# Health check
curl http://localhost:8080/actuator/health
```

## Service Ports (local)
| Service | Port |
|---------|------|
| API Gateway | 8080 |
| Auth | 8081 |
| User Profile | 8082 |
| File | 8083 |
| Content | 8084 |
| Career | 8085 |
| Finance | 8086 |
| Chat | 8087 |
| Notification | 8088 |
| AI | 8089 |
| Eureka | 8761 |
| Config | 8888 |
| PostgreSQL | 5432 |
| Redis | 6379 |
| RabbitMQ | 5672 / UI 15672 |
| MinIO | 9000 / Console 9001 |

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
- `docs/LOCAL_DEV.md` — step-by-step local setup
- `docs/ENV.md` — all environment variables
- `docs/DEPLOYMENT.md` — how to pull GHCR images and run `docker-compose.prod.yml` on any Docker host (no VPS-specific steps)

## Standardization Rule
- One Dockerfile pattern for all Java microservices.
- One reusable GitHub Actions workflow with matrix for services.
- One independent Docker Compose file per service: `docker-compose.<service>.yml`.
- One independent GitHub Actions workflow per service: `.github/workflows/<service>-ci.yml`.
- Local and prod use the same images — only env vars differ.
- Goal: developer runs `make up` locally; CI publishes images ready for future production host.
