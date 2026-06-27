# Infrastructure — Service Prompt

Build Eureka Server, Config Server, config-repo, and root docker-compose for Vithey App.

## Goal
Provide service discovery and centralized configuration so all microservices can start and find each other in local development.

## Must Use
- Java 21, Spring Boot 3+, Maven
- spring-cloud-starter-netflix-eureka-server
- spring-cloud-config-server
- Docker Compose v2

## Modules to Create
```text
vithey-backend/
├── docker-compose.yml
├── docker-compose.infra.yml
├── config-repo/
├── eureka-server/
│   ├── pom.xml
│   └── src/main/java/com/vithey/eureka/EurekaServerApplication.java
└── config-server/
    ├── pom.xml
    └── src/main/java/com/vithey/config/ConfigServerApplication.java
```

## Eureka Server
- Port: 8761
- `register-with-eureka: false`, `fetch-registry: false` on server itself
- Health: `/actuator/health`

## Config Server
- Port: 8888
- Git or native file backend pointing to `config-repo/`
- Native profile for local: `spring.profiles.active=native`
- `spring.cloud.config.server.native.search-locations=classpath:/config-repo,file:./config-repo`

## config-repo Files
Create per-service YAML with:
- `server.port`
- `spring.datasource.url` (per-service DB)
- `spring.application.name` (Eureka name)
- RabbitMQ, Redis connection (where needed)
- JWT secret reference (auth + gateway)
- MinIO endpoint (file-service)
- AI API key placeholder (ai-service)
- FCM credentials path (notification-service)

## docker-compose.yml
```yaml
services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: vithey
      POSTGRES_PASSWORD: vithey
    ports: ["5432:5432"]
    volumes:
      - ./scripts/init-databases.sql:/docker-entrypoint-initdb.d/init.sql
  redis:
    image: redis:7-alpine
    ports: ["6379:6379"]
  rabbitmq:
    image: rabbitmq:3-management
    ports: ["5672:5672", "15672:15672"]
  minio:
    image: minio/minio
    command: server /data --console-address ":9001"
    ports: ["9000:9000", "9001:9001"]
  eureka-server:
    build: ./eureka-server
    ports: ["8761:8761"]
  config-server:
    build: ./config-server
    ports: ["8888:8888"]
    depends_on: [eureka-server]
```

## init-databases.sql
Create databases: `auth_db`, `user_db`, `content_db`, `career_db`, `finance_db`, `chat_db`, `notification_db`, `ai_db`.

## README.md (root)
- Prerequisites: Java 21, Maven, Docker
- Start infra: `docker compose up -d postgres redis rabbitmq minio eureka-server config-server`
- Verify Eureka dashboard: http://localhost:8761

## Output
Complete runnable infrastructure — no placeholders.
