# Infrastructure — Complete Design (Eureka + Config Server)

> Read `SERVICE_BLUEPRINT.md` and `COMMON_CONTEXT.md` first.  
> **Scope:** Spring Cloud infrastructure only — no business APIs.

## Goal

Runnable Eureka Server + Config Server + `config-repo/` so all microservices discover each other and load centralized configuration.

## Monorepo output

```text
vithey-backend/
├── pom.xml
├── config-repo/
│   ├── application.yml
│   ├── eureka-server.yml
│   ├── config-server.yml
│   ├── api-gateway.yml
│   ├── auth-service.yml
│   ├── user-profile-service.yml
│   ├── file-service.yml
│   ├── content-service.yml
│   ├── career-service.yml
│   ├── finance-service.yml
│   ├── chat-service.yml
│   ├── notification-service.yml
│   └── ai-service.yml
├── scripts/
│   └── init-databases.sql
├── eureka-server/
└── config-server/
```

## Maven — parent `pom.xml`

Modules: `eureka-server`, `config-server` (services added later as separate modules).

Spring Cloud BOM `2023.0.3`, Java 21, Boot `3.3.5`.

## Eureka Server (`eureka-server/`)

| Item | Value |
|------|-------|
| Port | 8761 |
| Package | `com.vithey.eureka` |
| Main | `EurekaServerApplication` with `@EnableEurekaServer` |

**Dependencies:** `spring-cloud-starter-netflix-eureka-server`, `spring-boot-starter-actuator`

**`application.yml`:**
```yaml
server:
  port: 8761
eureka:
  client:
    register-with-eureka: false
    fetch-registry: false
  server:
    enable-self-preservation: false   # dev only
management:
  endpoints:
    web:
      exposure:
        include: health,info
```

**Health:** `GET http://localhost:8761/actuator/health`  
**Dashboard:** `http://localhost:8761`

## Config Server (`config-server/`)

| Item | Value |
|------|-------|
| Port | 8888 |
| Package | `com.vithey.config` |
| Main | `ConfigServerApplication` with `@EnableConfigServer` |

**Dependencies:** `spring-cloud-config-server`, `spring-cloud-starter-netflix-eureka-client`

**`application.yml`:**
```yaml
server:
  port: 8888
spring:
  application:
    name: config-server
  profiles:
    active: native
  cloud:
    config:
      server:
        native:
          search-locations: file:./config-repo,classpath:/config-repo
eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/
```

## config-repo — shared `application.yml`

```yaml
spring:
  jpa:
    hibernate:
      ddl-auto: validate
    open-in-view: false
  jackson:
    property-naming-strategy: SNAKE_CASE
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
vithey:
  jwt:
    secret: ${JWT_SECRET:change-me-in-production-min-32-chars}
    access-ttl-seconds: 900
    refresh-ttl-days: 7
  rabbitmq:
    exchange: vithey.events
```

## config-repo — per-service template (`auth-service.yml` example)

```yaml
server:
  port: 8081
spring:
  application:
    name: auth-service
  datasource:
    url: jdbc:postgresql://localhost:5432/auth_db
    username: vithey
    password: vithey
  rabbitmq:
    host: localhost
    port: 5672
    username: guest
    password: guest
```

Repeat for each service with correct port + database from port registry in `COMMON_CONTEXT.md`.

**file-service.yml** add:
```yaml
vithey:
  minio:
    endpoint: http://localhost:9000
    access-key: minioadmin
    secret-key: minioadmin
    buckets: avatars,cvs,posters,videos
```

**ai-service.yml** (optional — Python ai-service reads env vars directly; keep for documentation):
```yaml
vithey:
  ai:
    provider: ${AI_PROVIDER:mock}
    api-key: ${AI_API_KEY:}
    base-url: ${AI_BASE_URL:https://api.openai.com/v1}
    model: ${AI_MODEL:gpt-4o-mini}
```

**notification-service.yml** add:
```yaml
vithey:
  firebase:
    credentials-path: ${FIREBASE_CREDENTIALS_PATH:}
```

## `scripts/init-databases.sql`

```sql
CREATE DATABASE auth_db;
CREATE DATABASE user_db;
CREATE DATABASE content_db;
CREATE DATABASE career_db;
CREATE DATABASE finance_db;
CREATE DATABASE chat_db;
CREATE DATABASE notification_db;
CREATE DATABASE ai_db;
-- file-service uses MinIO; optional file_metadata in auth_db or separate if needed
```

## Docker Compose (infra only)

Postgres 16, Redis 7, RabbitMQ 3-management, MinIO, eureka-server, config-server — see `Prompt Devops/v1/01-local-docker-compose-prompt.md`.

## Logic flow

```text
1. Start Postgres → run init-databases.sql
2. Start Eureka (8761)
3. Start Config Server (8888) → reads config-repo/
4. Domain services start → bootstrap.yml → fetch config → register Eureka
5. API Gateway starts last → routes lb://service-name via Eureka
```

## Testing

- Eureka dashboard lists registered services after a test client starts
- `curl http://localhost:8888/auth-service/default` returns merged config

## Output

Complete infrastructure — no placeholders. No business REST APIs in this module.
