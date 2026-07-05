# API Gateway

Spring Cloud Gateway entry point for Vithey backend APIs.

It owns routing, JWT validation, CORS, request IDs, and Redis-backed rate limiting. It does not own domain business logic or a database.

## Run With Docker

```powershell
cd "D:\project\Acleda Mobile App\backend\services\api-gateway"
copy .env.example .env
docker compose up -d --build
```

Requires shared infrastructure:

```powershell
cd "D:\project\Acleda Mobile App\backend\infrastructure"
docker compose up -d --build
```

## Verify

```powershell
Invoke-RestMethod http://localhost:8080/actuator/health
docker compose -f docker-compose.api-gateway.yml ps
```

Protected routes without a bearer token should return `401`:

```powershell
Invoke-WebRequest http://localhost:8080/api/v1/users/me
```

## Build Without Docker

Start infrastructure first, then run:

```powershell
cd "D:\project\Acleda Mobile App\backend"
mvn -pl services/api-gateway -am spring-boot:run
```

Default port: `8080`
