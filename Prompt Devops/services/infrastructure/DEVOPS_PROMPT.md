# Infrastructure — DevOps Prompt

Create independent Docker Compose and GitHub Actions CI for the infrastructure modules.

## Modules

| Module | Path | Port | Image |
| --- | --- | --- | --- |
| Eureka Server | `vithey-backend/eureka-server` | `8761` | `ghcr.io/<owner>/vithey-eureka-server` |
| Config Server | `vithey-backend/config-server` | `8888` | `ghcr.io/<owner>/vithey-config-server` |

## Docker Compose Output

Create:

```text
vithey-backend/docker-compose.infrastructure.yml
```

Required containers:

- `postgres`
- `redis`
- `rabbitmq`
- `minio`
- `eureka-server`
- `config-server`

This file is the independent infrastructure base that other service-specific Compose files may mirror or depend on.

Verification:

```bash
docker compose -f docker-compose.infrastructure.yml up -d --build
curl http://localhost:8761/actuator/health
curl http://localhost:8888/actuator/health
docker compose -f docker-compose.infrastructure.yml down -v
```

## GitHub Actions Output

Create:

```text
.github/workflows/infrastructure-ci.yml
```

Triggers:

- `vithey-backend/eureka-server/**`
- `vithey-backend/config-server/**`
- `vithey-backend/config-repo/**`
- `vithey-backend/docker-compose.infrastructure.yml`
- `.github/workflows/infrastructure-ci.yml`

CI must test/package Eureka and Config Server, build both Docker images, and validate `docker-compose.infrastructure.yml`.

