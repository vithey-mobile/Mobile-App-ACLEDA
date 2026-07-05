# Infrastructure — DevOps Prompt

Create shared infrastructure Docker Compose and GitHub Actions CI for platform services only.

## Modules

| Module | Path | Port | Image |
| --- | --- | --- | --- |
| Eureka Server | `vithey-backend/infrastructure/eureka-server` | `8761` | `ghcr.io/<owner>/vithey-eureka-server` |
| Config Server | `vithey-backend/infrastructure/config-server` | `8888` | `ghcr.io/<owner>/vithey-config-server` |
| Config Repo | `vithey-backend/infrastructure/config-repo` | — | — |

## Docker Compose Output

Create:

```text
vithey-backend/infrastructure/docker-compose.yml
vithey-backend/infrastructure/.env.example
```

Required containers:

- `postgres`
- `redis`
- `rabbitmq`
- `minio`
- `eureka-server`
- `config-server`

Network:

```yaml
networks:
  vithey-network:
    name: vithey-network
```

Business services must connect to this external network. Do not place business services in this compose file.

Verification:

```bash
cd vithey-backend/infrastructure
copy .env.example .env
docker compose up -d --build
curl http://localhost:8761/actuator/health
curl http://localhost:8888/actuator/health
docker network inspect vithey-network
docker compose down -v
```

## GitHub Actions Output

Create:

```text
.github/workflows/infrastructure-ci.yml
```

Triggers:

- `vithey-backend/infrastructure/eureka-server/**`
- `vithey-backend/infrastructure/config-server/**`
- `vithey-backend/infrastructure/config-repo/**`
- `vithey-backend/infrastructure/docker-compose.yml`
- `.github/workflows/infrastructure-ci.yml`

CI must test/package Eureka and Config Server, build both Docker images, and validate `infrastructure/docker-compose.yml`.
