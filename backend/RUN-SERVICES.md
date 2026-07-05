# Run Vithey — Independent Docker (one compose per service)

Each service has its own `docker-compose.yml` → **1 app container + 1 Postgres** (gateway has no Postgres).

## Step 0 — Once only (create network)

```powershell
docker network create vithey-network
```

(Skip if infrastructure already created it.)

## Step 1 — Shared infrastructure (required first)

```powershell
cd "D:\project\Acleda Mobile App\backend\infrastructure"
copy .env.example .env
docker compose up -d --build
```

Starts: eureka, config-server, redis, rabbitmq, minio, shared postgres.

## Step 2 — Run each service independently

Run only the services you need. Same pattern for all:

```powershell
cd "D:\project\Acleda Mobile App\backend\services\<service-name>"
copy .env.example .env
docker compose up -d --build
```

### Commands (in recommended order)

```powershell
# 1 Auth
cd "D:\project\Acleda Mobile App\backend\services\auth-service"
copy .env.example .env
docker compose up -d --build

# 2 User profile
cd "D:\project\Acleda Mobile App\backend\services\user-profile-service"
copy .env.example .env
docker compose up -d --build

# 3 File
cd "D:\project\Acleda Mobile App\backend\services\file-service"
copy .env.example .env
docker compose up -d --build

# 4 Content
cd "D:\project\Acleda Mobile App\backend\services\content-service"
copy .env.example .env
docker compose up -d --build

# 5 Career
cd "D:\project\Acleda Mobile App\backend\services\career-service"
copy .env.example .env
docker compose up -d --build

# 6 Finance
cd "D:\project\Acleda Mobile App\backend\services\finance-service"
copy .env.example .env
docker compose up -d --build

# 7 Chat
cd "D:\project\Acleda Mobile App\backend\services\chat-service"
copy .env.example .env
docker compose up -d --build

# 8 Notification
cd "D:\project\Acleda Mobile App\backend\services\notification-service"
copy .env.example .env
docker compose up -d --build

# 9 API Gateway (last — after other services register in Eureka)
cd "D:\project\Acleda Mobile App\backend\services\api-gateway"
copy .env.example .env
docker compose up -d --build

# 10 AI / Chatbot (Java ai-service — needs GDCE general on gdce-network)
cd "D:\GDCE-chatbot\chatbot_review\services_version2\general"
docker network create gdce-network
docker compose up -d --build

cd "D:\project\Acleda Mobile App\backend\services\ai-service"
copy .env.example .env
docker compose up -d --build
```

## Containers per service

| Service | App container | DB container | App port |
| --- | --- | --- | --- |
| infrastructure | vithey-eureka-server, vithey-config-server, … | vithey-postgres (shared) | 8761, 8888 |
| auth-service | vithey-auth-service | vithey-auth-postgres | 8081 |
| user-profile-service | vithey-user-profile-service | vithey-profile-postgres | 8082 |
| file-service | vithey-file-service | vithey-file-postgres | 8083 |
| content-service | vithey-content-service | vithey-content-postgres | 8084 |
| career-service | vithey-career-service | vithey-career-postgres | 8085 |
| finance-service | vithey-finance-service | vithey-finance-postgres | 8086 |
| chat-service | vithey-chat-service | vithey-chat-postgres | 8087 |
| notification-service | vithey-notification-service | vithey-notification-postgres | 8088 |
| api-gateway | vithey-api-gateway | — | 8080 |
| ai-service | vithey-ai-service | vithey-ai-postgres | 8089 |

## Stop one service

```powershell
cd "D:\project\Acleda Mobile App\backend\services\<service-name>"
docker compose down
```

## Stop infrastructure

```powershell
cd "D:\project\Acleda Mobile App\backend\infrastructure"
docker compose down
```

## Python AI (Java ai-service on port 8089)

```powershell
cd "D:\project\Acleda Mobile App\backend\services\ai-service"
copy .env.example .env
docker compose up -d --build
```

See `services/ai-service/INTEGRATION-GENERAL.md`.

## Verify full stack

```powershell
cd "D:\project\Acleda Mobile App\backend"
.\scripts\verify-docker.ps1
```

See `DOCKER-VERIFY.md` for troubleshooting.

- All services join external network **`vithey-network`**
- If port **8080** is busy (ERPNext), change api-gateway compose to `"18080:8080"`
- Do **not** use `backend/docker-compose.yml` if you want independent per-service control
