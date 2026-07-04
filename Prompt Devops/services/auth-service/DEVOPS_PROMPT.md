# Auth Service — DevOps Prompt

Create independent Docker Compose and GitHub Actions CI for `auth-service`.

## Service

| Item | Value |
| --- | --- |
| Source path | `vithey-backend/services/auth-service` |
| Port | `8081` |
| Image | `ghcr.io/<owner>/vithey-auth-service` |
| Database | `auth_db` |

## Docker Compose Output

Create:

```text
vithey-backend/docker-compose.auth-service.yml
vithey-backend/services/auth-service/.env.example
```

Required containers:

- `auth-service`
- `auth-postgres`
- `auth-rabbitmq`
- `auth-eureka-server`
- `auth-config-server`

Verification:

```bash
docker compose -f docker-compose.auth-service.yml up -d --build
curl http://localhost:8081/actuator/health
docker compose -f docker-compose.auth-service.yml down -v
```

## GitHub Actions Output

Create:

```text
.github/workflows/auth-service-ci.yml
```

Triggers:

- `vithey-backend/services/auth-service/**`
- `vithey-backend/config-repo/auth-service.yml`
- `vithey-backend/docker-compose.auth-service.yml`
- `.github/workflows/auth-service-ci.yml`

CI must run Maven tests, build the Docker image with `SERVICE_PORT=8081`, and validate `docker-compose.auth-service.yml`.

