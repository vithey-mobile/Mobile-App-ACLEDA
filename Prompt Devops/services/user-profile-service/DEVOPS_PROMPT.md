# User Profile Service — DevOps Prompt

Create independent Docker Compose and GitHub Actions CI for `user-profile-service`.

## Service

| Item | Value |
| --- | --- |
| Source path | `vithey-backend/services/user-profile-service` |
| Port | `8082` |
| Image | `ghcr.io/<owner>/vithey-user-profile-service` |
| Database | `user_db` |

## Docker Compose Output

Create:

```text
vithey-backend/docker-compose.user-profile-service.yml
vithey-backend/services/user-profile-service/.env.example
```

Required containers:

- `user-profile-service`
- `user-profile-postgres`
- `user-profile-rabbitmq`
- `user-profile-eureka-server`
- `user-profile-config-server`

Verification:

```bash
docker compose -f docker-compose.user-profile-service.yml up -d --build
curl http://localhost:8082/actuator/health
docker compose -f docker-compose.user-profile-service.yml down -v
```

## GitHub Actions Output

Create:

```text
.github/workflows/user-profile-service-ci.yml
```

CI must run Maven tests, build the Docker image with `SERVICE_PORT=8082`, and validate `docker-compose.user-profile-service.yml`.

