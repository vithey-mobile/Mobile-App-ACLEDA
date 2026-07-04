# Notification Service — DevOps Prompt

Create independent Docker Compose and GitHub Actions CI for `notification-service`.

## Service

| Item | Value |
| --- | --- |
| Source path | `vithey-backend/services/notification-service` |
| Port | `8088` |
| Image | `ghcr.io/<owner>/vithey-notification-service` |
| Database | `notification_db` |

## Docker Compose Output

Create:

```text
vithey-backend/docker-compose.notification-service.yml
vithey-backend/services/notification-service/.env.example
```

Required containers:

- `notification-service`
- `notification-postgres`
- `notification-rabbitmq`
- `notification-eureka-server`
- `notification-config-server`

Firebase credentials must be optional in local dev. Use env vars only, never commit JSON credentials.

Verification:

```bash
docker compose -f docker-compose.notification-service.yml up -d --build
curl http://localhost:8088/actuator/health
docker compose -f docker-compose.notification-service.yml down -v
```

## GitHub Actions Output

Create:

```text
.github/workflows/notification-service-ci.yml
```

CI must run Maven tests, build the Docker image with `SERVICE_PORT=8088`, and validate `docker-compose.notification-service.yml`.

