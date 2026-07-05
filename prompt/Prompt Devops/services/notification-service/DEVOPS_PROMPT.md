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
vithey-backend/services/notification-service/docker-compose.yml
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
cd vithey-backend/services/notification-service
docker compose up -d --build
curl http://localhost:8088/actuator/health
docker compose down -v
```

## GitHub Actions Output

Create:

```text
.github/workflows/notification-service-ci.yml
```

CI must run Maven tests, build the Docker image with `SERVICE_PORT=8088`, and validate `services/notification-service/docker-compose.yml`.

