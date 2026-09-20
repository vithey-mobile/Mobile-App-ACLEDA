# Vithey Backend — Docker

Run the **full stack** (Postgres, Redis, RabbitMQ, MinIO, Eureka, Config Server, all microservices, API Gateway) with one compose file.

## Prerequisites

- Docker Desktop with Compose v2
- At least **8 GB RAM** allocated to Docker (12 GB+ recommended for full stack)
- Free ports: `8080–8089`, `8761`, `8888`, `5672`, `15672`, `15432`, `16379`, `19000–19001`

## Quick start (all services)

```powershell
cd "D:\project\Acleda Mobile App\backend"
docker compose up -d --build
```

Or:

```powershell
.\scripts\start-all.ps1
```

First build takes several minutes (Maven inside each Dockerfile).

### Useful commands

```powershell
docker compose ps
docker compose logs -f api-gateway
docker compose down

.\scripts\start-all.ps1 -Logs
.\scripts\start-all.ps1 -Down
.\scripts\start-all.ps1 -SkipBuild
.\scripts\start-all.ps1 -InfraOnly
```

## What starts

| Service | Host URL / port |
| --- | --- |
| API Gateway | http://localhost:8080 |
| Auth | http://localhost:8081 |
| User Profile | http://localhost:8082 |
| File | http://localhost:8083 |
| Content | http://localhost:8084 |
| Career | http://localhost:8085 |
| Finance | http://localhost:8086 |
| Chat | http://localhost:8087 |
| Notification | http://localhost:8088 |
| AI | http://localhost:8089 |
| Eureka | http://localhost:8761 |
| Config Server | http://localhost:8888 |
| PostgreSQL | localhost:15432 |
| Redis | localhost:16379 |
| RabbitMQ UI | http://localhost:15672 (guest/guest) |
| MinIO Console | http://localhost:19001 (minioadmin/minioadmin) |
| MinIO API | http://localhost:19000 |

## Verify

```powershell
Invoke-RestMethod http://localhost:8080/actuator/health
Invoke-RestMethod http://localhost:8761/actuator/health
docker compose ps
```

Open Eureka and confirm services are registered: `AUTH-SERVICE`, `API-GATEWAY`, etc.

## Infra only / one service

Shared infrastructure only:

```powershell
cd infrastructure
docker compose up -d --build
```

One business service (infra must already be up on `vithey-network`):

```powershell
cd services\auth-service
docker compose up -d --build
```

Or:

```powershell
.\scripts\docker-build-service.ps1 auth-service -Up
```

## Env files

Compose loads `*.env.example` files (no local `.env` copy required for local Docker). Override secrets by creating `.env` beside a service and pointing `env_file` at it if needed.

## Monitoring (optional)

```powershell
cd "..\monitoring"
copy .env.example .env
docker compose up -d
```

Grafana: http://localhost:3000 — see `monitoring/README.md`.

## Flutter emulator

```env
API_BASE_URL=http://10.0.2.2:8080/api/v1   # Android emulator
API_BASE_URL=http://localhost:8080/api/v1  # iOS simulator
```

## Troubleshooting

| Issue | Fix |
| --- | --- |
| Out of memory during build | Increase Docker RAM; build one image: `docker compose build auth-service` |
| Port already in use | Stop the other process or change the host port mapping in `docker-compose.yml` |
| Service unhealthy | `docker compose logs <service>` |
| Gateway UP but 503 on routes | Wait 1–2 min for Eureka registration |
| Postgres empty / missing DBs | `docker compose down -v` then `up` again (re-runs init script) |
| MinIO unhealthy | Image may lack `curl`; wait or restart: `docker compose restart minio` |
