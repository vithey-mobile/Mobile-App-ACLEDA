# Finance Service — DevOps Prompt

Create independent Docker Compose and GitHub Actions CI for `finance-service`.

## Service

| Item | Value |
| --- | --- |
| Source path | `vithey-backend/services/finance-service` |
| Port | `8086` |
| Image | `ghcr.io/<owner>/vithey-finance-service` |
| Database | `finance_db` |

## Docker Compose Output

Create:

```text
vithey-backend/services/finance-service/docker-compose.yml
vithey-backend/services/finance-service/.env.example
```

Required containers:

- `finance-service`
- `finance-postgres`
- `finance-rabbitmq`
- `finance-eureka-server`
- `finance-config-server`

Verification:

```bash
cd vithey-backend/services/finance-service
docker compose up -d --build
curl http://localhost:8086/actuator/health
docker compose down -v
```

## GitHub Actions Output

Create:

```text
.github/workflows/finance-service-ci.yml
```

CI must run Maven tests, build the Docker image with `SERVICE_PORT=8086`, and validate `services/finance-service/docker-compose.yml`.

