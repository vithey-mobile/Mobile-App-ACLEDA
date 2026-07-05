# API Gateway — DevOps Prompt

Create independent Docker Compose and GitHub Actions CI for `api-gateway`.

## Service

| Item | Value |
| --- | --- |
| Source path | `vithey-backend/services/api-gateway` |
| Port | `8080` |
| Image | `ghcr.io/<owner>/vithey-api-gateway` |
| Database | none |

## Docker Compose Output

Create:

```text
vithey-backend/services/api-gateway/docker-compose.yml
vithey-backend/services/api-gateway/.env.example
```

Required containers:

- `api-gateway`
- `gateway-redis`
- `gateway-eureka-server`
- `gateway-config-server`

Do not add PostgreSQL or RabbitMQ.

Verification:

```bash
cd vithey-backend/infrastructure
docker compose up -d --build

cd ../services/api-gateway
copy .env.example .env
docker compose up -d --build
curl http://localhost:8080/actuator/health
docker compose down
```

## GitHub Actions Output

Create:

```text
.github/workflows/api-gateway-ci.yml
```

Triggers:

- `vithey-backend/services/api-gateway/**`
- `vithey-backend/infrastructure/config-repo/api-gateway.yml`
- `vithey-backend/services/api-gateway/docker-compose.yml`
- `.github/workflows/api-gateway-ci.yml`

CI must run Maven tests, build the Docker image with `SERVICE_PORT=8080`, and validate `services/api-gateway/docker-compose.yml`.

