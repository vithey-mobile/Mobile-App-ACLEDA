# Content Service — DevOps Prompt

Create independent Docker Compose and GitHub Actions CI for `content-service`.

## Service

| Item | Value |
| --- | --- |
| Source path | `vithey-backend/services/content-service` |
| Port | `8084` |
| Image | `ghcr.io/<owner>/vithey-content-service` |
| Database | `content_db` |

## Docker Compose Output

Create:

```text
vithey-backend/services/content-service/docker-compose.yml
vithey-backend/services/content-service/.env.example
```

Required containers:

- `content-service`
- `content-postgres`
- `content-rabbitmq`
- `content-eureka-server`
- `content-config-server`

Verification:

```bash
cd vithey-backend/services/content-service
docker compose up -d --build
curl http://localhost:8084/actuator/health
docker compose down -v
```

## GitHub Actions Output

Create:

```text
.github/workflows/content-service-ci.yml
```

CI must run Maven tests, build the Docker image with `SERVICE_PORT=8084`, and validate `services/content-service/docker-compose.yml`.

