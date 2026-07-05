# Career Service — DevOps Prompt

Create independent Docker Compose and GitHub Actions CI for `career-service`.

## Service

| Item | Value |
| --- | --- |
| Source path | `vithey-backend/services/career-service` |
| Port | `8085` |
| Image | `ghcr.io/<owner>/vithey-career-service` |
| Database | `career_db` |

## Docker Compose Output

Create:

```text
vithey-backend/services/career-service/docker-compose.yml
vithey-backend/services/career-service/.env.example
```

Required containers:

- `career-service`
- `career-postgres`
- `career-rabbitmq`
- `career-eureka-server`
- `career-config-server`

Verification:

```bash
cd vithey-backend/services/career-service
docker compose up -d --build
curl http://localhost:8085/actuator/health
docker compose down -v
```

## GitHub Actions Output

Create:

```text
.github/workflows/career-service-ci.yml
```

CI must run Maven tests, build the Docker image with `SERVICE_PORT=8085`, and validate `services/career-service/docker-compose.yml`.

