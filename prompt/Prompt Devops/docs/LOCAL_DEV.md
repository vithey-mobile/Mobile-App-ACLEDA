# Local Development

## 1. Shared Infrastructure

Start Eureka, Config Server, RabbitMQ, Redis, Postgres, and MinIO:

```powershell
cd "D:\project\Acleda Mobile App\backend\infrastructure"
copy .env.example .env
docker compose up -d --build
```

Verify:

```powershell
Invoke-RestMethod http://localhost:8761/actuator/health
Invoke-RestMethod http://localhost:8888/actuator/health
docker network inspect vithey-network
```

## 2. Auth Service

```powershell
cd "D:\project\Acleda Mobile App\backend\services\auth-service"
copy .env.example .env
docker compose up -d --build
Invoke-RestMethod http://localhost:8081/actuator/health
```

## 3. User Profile Service

```powershell
cd "D:\project\Acleda Mobile App\backend\services\user-profile-service"
copy .env.example .env
docker compose up -d --build
Invoke-RestMethod http://localhost:8082/actuator/health
```

## 4. API Gateway

```powershell
cd "D:\project\Acleda Mobile App\backend\services\api-gateway"
copy .env.example .env
docker compose up -d --build
Invoke-RestMethod http://localhost:8080/actuator/health
```

## 5. File Service

```powershell
cd "D:\project\Acleda Mobile App\backend\services\file-service"
copy .env.example .env
docker compose up -d --build
Invoke-RestMethod http://localhost:8083/actuator/health
```

## Start all services

```powershell
cd "D:\project\Acleda Mobile App\backend"
.\scripts\start-all.ps1
```

## Stop

Infrastructure:

```powershell
cd "D:\project\Acleda Mobile App\backend\infrastructure"
docker compose down
```

Service:

```powershell
cd "D:\project\Acleda Mobile App\backend\services\auth-service"
docker compose down
```

## Build without Docker

```powershell
cd "D:\project\Acleda Mobile App\backend"
mvn clean install
mvn -pl services/auth-service spring-boot:run
```

Non-Docker runs need the shared infrastructure containers running on localhost.
