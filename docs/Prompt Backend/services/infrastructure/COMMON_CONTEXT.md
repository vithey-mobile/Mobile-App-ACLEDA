# Infrastructure — Common Context

## Service Role
Platform infrastructure: service discovery and centralized configuration. No domain database.

## Components
| Component | Port | Artifact |
|-----------|------|----------|
| Eureka Server | 8761 | `eureka-server` Maven module |
| Config Server | 8888 | `config-server` Maven module |

## Config Server Layout
```text
config-repo/
├── application.yml              # shared defaults
├── auth-service.yml
├── user-profile-service.yml
├── content-service.yml
├── career-service.yml
├── finance-service.yml
├── chat-service.yml
├── notification-service.yml
├── ai-service.yml
├── file-service.yml
└── api-gateway.yml
```

## Shared Config Keys (all services)
```yaml
eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/
spring:
  rabbitmq:
    host: localhost
    port: 5672
  data:
    redis:
      host: localhost
      port: 6379
```

## Docker Compose Services
- `postgres` — multiple databases: auth_db, user_db, content_db, career_db, finance_db, chat_db, notification_db, ai_db
- `redis`
- `rabbitmq` (management UI 15672)
- `minio` (9000 API, 9001 console)
- `eureka-server`
- `config-server`

## Dependencies
None — this is built first.

## Downstream Consumers
All 9 domain services + API Gateway register with Eureka and pull config from Config Server.
