# Vithey Backend

Production-style Spring Boot microservices monorepo.

## Folder structure

```text
backend/
├── infrastructure/
│   ├── eureka-server/
│   ├── config-server/
│   ├── config-repo/
│   ├── scripts/
│   ├── docker-compose.yml
│   └── .env.example
├── services/
│   ├── api-gateway/
│   │   ├── Dockerfile
│   │   ├── docker-compose.yml
│   │   ├── pom.xml
│   │   ├── .env.example
│   │   └── src/
│   ├── auth-service/
│   │   ├── Dockerfile
│   │   ├── docker-compose.yml
│   │   ├── pom.xml
│   │   ├── .env.example
│   │   └── src/
│   └── user-profile-service/
│   └── file-service/
│       ├── Dockerfile
│       ├── docker-compose.yml
│       ├── pom.xml
│       ├── .env.example
│       └── src/
└── pom.xml
```

## Local development

### 1. Start shared infrastructure

```powershell
cd infrastructure
copy .env.example .env
docker compose up -d --build
```

### 2. Start a service independently

```powershell
cd services/auth-service
copy .env.example .env
docker compose up -d --build
```

Repeat for `api-gateway` and `user-profile-service`.

### 3. Build without Docker

```powershell
mvn clean install
mvn -pl services/auth-service spring-boot:run
```

## Design rules

- Shared Eureka, Config Server, RabbitMQ, Redis, Postgres, and MinIO live only in `infrastructure/`
- Each business service is independently buildable, runnable, and deployable
- Each service compose file uses the external `vithey-network`
- Service-specific databases stay inside the service compose file when needed
