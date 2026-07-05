# File Service — DevOps Prompt

Create independent Docker Compose and GitHub Actions CI for `file-service`.

## Service

| Item | Value |
| --- | --- |
| Source path | `vithey-backend/services/file-service` |
| Port | `8083` |
| Image | `ghcr.io/<owner>/vithey-file-service` |
| Database | `file_db` |

## Docker Compose Output

Create:

```text
vithey-backend/services/file-service/docker-compose.yml
vithey-backend/services/file-service/.env.example
```

Required containers in service compose:

- `file-service`
- `file-postgres`

Uses shared infrastructure on external network `vithey-network`:

- `minio`
- `eureka-server`
- `config-server`

Verification:

```bash
cd vithey-backend/infrastructure
docker compose up -d --build

cd ../services/file-service
copy .env.example .env
docker compose up -d --build
curl http://localhost:8083/actuator/health
docker compose down
```

## GitHub Actions Output

Create:

```text
.github/workflows/file-service-ci.yml
```

CI must run Maven tests, build the Docker image with `SERVICE_PORT=8083`, and validate `services/file-service/docker-compose.yml`.
