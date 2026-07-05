# Infrastructure

Shared platform components for the Vithey backend. Start this stack first before any business service.

```text
backend/
├── infrastructure/
│   ├── eureka-server/       # Spring Boot service discovery
│   ├── config-server/       # Spring Cloud Config Server
│   ├── config-repo/         # Central configuration files
│   ├── scripts/             # Shared DB bootstrap scripts
│   ├── docker-compose.yml   # Shared infrastructure only
│   ├── .env.example
│   └── README.md
├── services/
│   ├── api-gateway/
│   ├── auth-service/
│   └── user-profile-service/
└── pom.xml
```

## Shared stack

Creates the external Docker network `vithey-network` and starts:

- Eureka Server on `http://localhost:8761`
- Config Server on `http://localhost:8888`
- PostgreSQL on `localhost:5432`
- Redis on `localhost:6379`
- RabbitMQ on `localhost:5672`, UI on `http://localhost:15672`
- MinIO on `http://localhost:9000`, console on `http://localhost:9001`

## Run

```powershell
cd "D:\project\Acleda Mobile App\backend\infrastructure"
copy .env.example .env
docker compose up -d --build
```

## Verify

```powershell
Invoke-RestMethod http://localhost:8761/actuator/health
Invoke-RestMethod http://localhost:8888/actuator/health
docker network inspect vithey-network
docker compose ps
```

## Stop

```powershell
docker compose down
```

Remove shared data:

```powershell
docker compose down -v
```

## Run a business service

After infrastructure is healthy, run each service from its own folder:

```powershell
cd "D:\project\Acleda Mobile App\backend\services\auth-service"
copy .env.example .env
docker compose up -d --build
```

Each service compose file joins the external `vithey-network` and talks to shared `eureka-server`, `config-server`, and `rabbitmq` by service name.

## Run everything (recommended)

```powershell
cd "D:\project\Acleda Mobile App\backend"
copy .env.example .env
docker compose up -d --build
```

Or use the helper script:

```powershell
.\scripts\start-all.ps1
```

See `../DOCKER.md` for full stack docs, URLs, and troubleshooting.
