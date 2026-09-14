# Vithey Backend — Docker Architecture & Startup Guide

This monorepo backend contains the Vithey Spring Boot 3.3.5 / Java 21 microservices platform.

---

## Service Architecture & Port Mapping

| Service Category | Service / Container Name | Port (Host:Container) | Function & Health URL |
| :--- | :--- | :--- | :--- |
| **Data & Infra** | `vithey-postgres` | `15432:5432` | PostgreSQL 16 (10 databases via `init-databases.sql`) |
| | `vithey-redis` | `16379:6379` | Redis 7 (caching, pub/sub, rate limiting) |
| | `vithey-rabbitmq` | `5672:5672`, `15672:15672` | RabbitMQ (Management UI: http://localhost:15672 guest/guest) |
| | `vithey-minio` | `19000:9000`, `19001:9001` | MinIO S3 Object Storage (Console: http://localhost:19001 minioadmin/minioadmin) |
| **Spring Cloud** | `vithey-eureka-server` | `8761:8761` | Service Discovery Dashboard: http://localhost:8761 |
| | `vithey-config-server` | `8888:8888` | Centralized Configuration: http://localhost:8888/actuator/health |
| | `vithey-api-gateway` | `8080:8080` | Public API Gateway: http://localhost:8080/actuator/health |
| **Microservices** | `vithey-auth-service` | `8081:8081` | Authentication, JWT, Student Verification: `:8081/actuator/health` |
| | `vithey-user-profile-service` | `8082:8082` | User profiles, bio, settings: `:8082/actuator/health` |
| | `vithey-file-service` | `8083:8083` | Media uploads, MinIO integration: `:8083/actuator/health` |
| | `vithey-content-service` | `8084:8084` | Posts, comments, reactions, feeds: `:8084/actuator/health` |
| | `vithey-career-service` | `8085:8085` | Job board, CV builder, applications: `:8085/actuator/health` |
| | `vithey-finance-service` | `8086:8086` | Fees, tuition, student payments: `:8086/actuator/health` |
| | `vithey-chat-service` | `8087:8087` | Chat, messaging, WebSocket: `:8087/actuator/health` |
| | `vithey-notification-service` | `8088:8088` | In-app & push notifications: `:8088/actuator/health` |
| | `vithey-ai-service` | `8089:8089` | AI assistant / Chatbot: `:8089/actuator/health` |
| | `vithey-map-service` | `8090:8090` | Google Places & Location APIs: `:8090/actuator/health` |

---

## Prerequisites

1. **Docker & Docker Compose** installed and running (`docker compose version` >= 2.20).
2. **Memory allocation**: If running all services simultaneously, allocate at least 8 GB RAM to Docker.
3. *Note: Local Java/Maven installation is optional; Docker builds compile Java 21 inside multi-stage containers.*

---

## Starting the Services

You have two flexible modes: **All-In-One (Full Stack)** or **Infrastructure + Selective Microservices**.

### Option A: Run Full Stack (All Services Together)

From the `backend/` directory:

#### Linux / macOS (Bash)
```bash
# Start all infrastructure + all 11 microservices + API Gateway:
./scripts/start-all.sh

# Or directly with Docker Compose:
docker compose up -d --build
```

#### Windows (PowerShell)
```powershell
.\scripts\start-all.ps1
```

> **First Run Note:** The initial build downloads Maven dependencies inside the containers. Subsequent starts are instantaneous with cached Docker layers.

---

### Option B: Run Infrastructure Only (Lightweight / Dev Mode)

If you only want data stores + Eureka + Config Server running in Docker while running/debugging specific microservices:

#### Linux / macOS (Bash)
```bash
# Start infra:
./scripts/start-all.sh --infra-only

# Or directly:
cd infrastructure && docker compose up -d --build
```

#### Windows (PowerShell)
```powershell
.\scripts\start-all.ps1 -InfraOnly
```

Then build and start only the services you need:

```bash
# Example: start auth-service
./scripts/docker-build-service.sh auth-service --up

# Example: start api-gateway
./scripts/docker-build-service.sh api-gateway --up
```

Or run directly from the service folder:
```bash
cd services/auth-service
docker compose up -d --build
```

---

## Verifying & Health Checks

Check the status of all services with the automated health check script:

#### Linux / macOS (Bash)
```bash
./scripts/check-service-health.sh
```

#### Windows (PowerShell)
```powershell
.\scripts\check-service-health.ps1
```

Or view Docker container status:
```bash
docker compose ps
```

To view logs:
```bash
# Tail logs across the whole stack:
./scripts/start-all.sh --logs
# or:
docker compose logs -f <service-name> (e.g. docker compose logs -f api-gateway)
```

---

## Stopping the Services

```bash
# Full stack:
./scripts/start-all.sh --down
# or:
docker compose down

# Infrastructure only:
cd infrastructure && docker compose down
```
