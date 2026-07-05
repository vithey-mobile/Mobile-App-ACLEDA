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
vithey-backend/services/user-profile-service/docker-compose.yml
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
cd vithey-backend/infrastructure
docker compose up -d --build

cd ../services/user-profile-service
copy .env.example .env
docker compose up -d --build
curl http://localhost:8082/actuator/health
docker compose down
```

## GitHub Actions Output

Create:

```text
.github/workflows/user-profile-service-ci.yml
```

CI must run Maven tests, build the Docker image with `SERVICE_PORT=8082`, and validate `services/user-profile-service/docker-compose.yml`.

