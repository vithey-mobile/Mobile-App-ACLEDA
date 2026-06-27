# Backend Reference — Microservices

## Architecture

```text
Mobile App → API Gateway :8080 → Microservices (Eureka)
                ↓
    PostgreSQL (per service) | Redis | RabbitMQ | MinIO
```

## Services

| Service | Port | Database | Responsibility |
|---------|------|----------|----------------|
| API Gateway | 8080 | — | JWT, routing, rate limit |
| Auth | 8081 | auth_db | Login, register, verify student |
| User Profile | 8082 | user_db | Profile, settings |
| File | 8083 | MinIO | Upload/download files |
| Content | 8084 | content_db | Posts, comments, follows |
| Career | 8085 | career_db | Job applications, CV refs |
| Finance | 8086 | finance_db | Payments, alerts |
| Chat | 8087 | chat_db | Messages, requests |
| Notification | 8088 | notification_db | In-app + FCM push |
| AI | 8089 | ai_db | AI chat |

## Layer pattern (each service)

```text
controller → service → repository → entity
         ↘ dto (request/response)
```

## Tech stack

- Java 21, Spring Boot 3+, Maven
- Spring Data JPA + PostgreSQL
- Spring Security + JWT
- springdoc-openapi (Swagger)
- RabbitMQ events between services

## RBAC roles

`USER`, `STUDENT`, `COMPANY`, `ADMIN`

## Cursor prompts

See `Prompt Backend/KICKOFF_PROMPT.md` and `Prompt Backend/services/*/`.

## DevOps

See `Prompt Devops/` for Docker Compose and GitHub Actions → GHCR.
