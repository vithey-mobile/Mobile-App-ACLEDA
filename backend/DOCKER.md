# Vithey Backend — Docker (per-service folders)

Each microservice has its **own** `Dockerfile` + `docker-compose.yml` in its folder.  
There is **no** all-in-one services compose file — build and run **one service at a time**.

## Layout

```
backend/
  docker-compose.yml              # infrastructure only (include)
  infrastructure/docker-compose.yml
  services/auth-service/
    Dockerfile
    docker-compose.yml            # build/run auth only
    .env.example
  services/career-service/
    Dockerfile
    docker-compose.yml            # build/run career only
  ...
```

Maven still uses the monorepo root as **build context** (`context: ../..`), but you always run Docker **from the service folder**.

## Step 1 — Start infrastructure (once)

```powershell
cd backend/infrastructure
docker compose up -d
```

Starts: Postgres, Redis, RabbitMQ, MinIO, Eureka, Config Server.

## Step 2 — Build & run one service

From the **service folder**:

```powershell
cd backend/services/auth-service
docker compose up -d --build
```

Other examples:

```powershell
cd backend/services/career-service
docker compose up -d --build

cd backend/services/api-gateway
docker compose up -d --build
```

## Helper script (from `backend/`)

```powershell
# Build only
.\scripts\docker-build-service.ps1 career-service

# Build + start
.\scripts\docker-build-service.ps1 career-service -Up

# Stop
.\scripts\docker-build-service.ps1 career-service -Down
```

Available names: `auth-service`, `user-profile-service`, `file-service`, `content-service`, `career-service`, `finance-service`, `chat-service`, `notification-service`, `ai-service`, `api-gateway`, `eureka-server`, `config-server`.

## Recommended startup order

1. `infrastructure/` — data stores + Eureka + Config  
2. Domain services (any order): `auth-service`, `user-profile-service`, …  
3. `api-gateway` last (needs Redis + Eureka + services registered)

## Build without starting

```powershell
cd backend/services/file-service
docker compose build
```

## Health check

```powershell
cd backend
.\scripts\check-service-health.ps1
```

## Stop

```powershell
# One service (from its folder)
docker compose down

# Infrastructure
cd backend/infrastructure
docker compose down
```

## Notes

- Network `vithey-network` is created by infrastructure compose (or the helper script).
- Spring profile: `docker` via each `services/*/.env.example`.
- First build per service downloads Maven deps (~5–10 min each).
- Config repo is embedded in the `config-server` image.

See `TESTING.md` and `infrastructure/.env.example`.
