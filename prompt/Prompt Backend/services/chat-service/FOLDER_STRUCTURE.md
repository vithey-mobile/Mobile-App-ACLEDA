# Chat Service — Folder Structure

Target output:

```text
backend/services/chat-service/
├── pom.xml
├── README.md
├── API.md                    # generated from springdoc or hand-maintained summary
├── ARCHITECTURE.md           # copy from prompt or symlink in docs
└── src/
    ├── main/
    │   ├── java/com/vithey/chat/
    │   │   ├── ChatServiceApplication.java
    │   │   ├── config/
    │   │   │   ├── WebSocketConfig.java
    │   │   │   ├── SecurityConfig.java
    │   │   │   ├── RabbitMqConfig.java
    │   │   │   ├── RedisConfig.java
    │   │   │   ├── FeignConfig.java
    │   │   │   └── JacksonConfig.java
    │   │   ├── controller/
    │   │   │   ├── ConversationController.java
    │   │   │   ├── MessageController.java
    │   │   │   ├── MessageRequestController.java
    │   │   │   └── ReportController.java
    │   │   ├── websocket/
    │   │   │   ├── ChatStompController.java
    │   │   │   ├── ChatEventListener.java
    │   │   │   └── StompUserPrincipalResolver.java
    │   │   ├── service/
    │   │   │   ├── ConversationService.java
    │   │   │   ├── MessageService.java
    │   │   │   ├── PresenceService.java
    │   │   │   ├── TypingService.java
    │   │   │   ├── MessageCacheService.java
    │   │   │   ├── BlockService.java
    │   │   │   └── ReportService.java
    │   │   ├── client/
    │   │   │   └── FileServiceClient.java
    │   │   ├── repository/
    │   │   ├── entity/
    │   │   ├── dto/request/
    │   │   ├── dto/response/
    │   │   ├── event/publisher/
    │   │   └── exception/GlobalExceptionHandler.java
    │   └── resources/
    │       ├── bootstrap.yml
    │       ├── application.yml
    │       └── db/migration/
    │           ├── V1__init_chat_schema.sql
    │           └── V2__message_media_and_reply.sql
    └── test/java/com/vithey/chat/
        ├── controller/
        ├── service/
        ├── websocket/
        └── integration/ChatStompIntegrationTest.java
```

## Required dependencies

| Dependency | Purpose |
|------------|---------|
| `spring-boot-starter-web` | REST |
| `spring-boot-starter-websocket` | STOMP |
| `spring-boot-starter-data-jpa` | PostgreSQL |
| `spring-boot-starter-data-redis` | Presence, typing, cache |
| `spring-boot-starter-amqp` | RabbitMQ events |
| `spring-cloud-starter-openfeign` | file-service client |
| `spring-cloud-starter-netflix-eureka-client` | Discovery |
| `spring-cloud-starter-config` | Central config |
| `postgresql`, `flyway-core` | DB |
| `spring-boot-starter-security` | JWT / gateway headers |
| `springdoc-openapi-starter-webmvc-ui` | API docs |
| `mapstruct`, `lombok` | DTO mapping |

**Do not add:** `firebase-admin`, `minio` — those belong to notification-service and file-service.

## Config properties (Config Server / application.yml)

```yaml
spring:
  datasource:
    url: jdbc:postgresql://chat-postgres:5432/chat_db
  data:
    redis:
      host: redis
      port: 6379
  rabbitmq:
    host: rabbitmq

vithey:
  chat:
    presence-ttl-seconds: 90
    typing-ttl-seconds: 5
    recent-messages-limit: 50
```

## Optional (production scale)

- `spring-kafka` — publish to `chat.events` topic alongside RabbitMQ
- Redis Sentinel / Cluster client config
