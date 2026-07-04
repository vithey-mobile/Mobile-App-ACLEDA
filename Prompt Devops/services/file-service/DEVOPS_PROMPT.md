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
vithey-backend/docker-compose.file-service.yml
vithey-backend/services/file-service/.env.example
```

Required containers:

- `file-service`
- `file-postgres`
- `file-minio`
- `file-eureka-server`
- `file-config-server`

Create MinIO buckets: `avatars`, `cvs`, `posters`, `videos`.

Verification:

```bash
docker compose -f docker-compose.file-service.yml up -d --build
curl http://localhost:8083/actuator/health
docker compose -f docker-compose.file-service.yml down -v
```

## GitHub Actions Output

Create:

```text
.github/workflows/file-service-ci.yml
```

CI must run Maven tests, build the Docker image with `SERVICE_PORT=8083`, and validate `docker-compose.file-service.yml`.

