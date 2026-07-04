# Vithey App — Backend Common Context

## Objective
Build a production-quality **Spring Boot microservice** platform for Vithey App. Each service is independently deployable, owns its database, exposes REST APIs documented with OpenAPI, and integrates via HTTP + message events.

## App Identity
| Item | Value |
|------|-------|
| App name | **Vithey App** |
| Backend repo | `vithey-backend` |
| Base package | `com.vithey.<service>` |
| API version | `v1` |
| Competition | [ACLEDA Bank App Competition 2026](https://www.acledabank.com.kh/sl/app-competition/) |
| Full spec | `Project Overview.txt` |

## Microservices Map
| Service | Database | Key Responsibility |
|---------|----------|-------------------|
| API Gateway | — | Routing, JWT, rate limit, CORS |
| Auth Service | `auth_db` | Register, login, refresh, RBAC, student verification |
| User/Profile Service | `user_db` | Profile, avatar, bio, social links, settings |
| Content Service | `content_db` | Posts, comments, reactions, mentions, follows |
| Career Service | `career_db` | Job posts, CV refs, applications, applicant review |
| Finance Service | `finance_db` | Payments, fees, alerts (verified students) |
| Chat Service | `chat_db` | Conversations, messages, requests, block/report |
| Notification Service | `notification_db` | In-app + FCM push notifications |
| AI Service | `ai_db` | CV/job/interview/finance AI chat |
| File Service | — (MinIO) | Upload/download media, CV, avatar |

## Infrastructure
| Component | Technology | Purpose |
|-----------|------------|---------|
| Service Discovery | Eureka | Register/find services |
| Config | Spring Cloud Config | Centralized `application.yml` |
| Cache / Pub-Sub | Redis | Chat presence, caching |
| Message Broker | RabbitMQ | Domain events |
| Object Storage | MinIO | Files (S3-compatible) |
| Push | Firebase Admin (FCM) | Mobile push |
| AI | OpenAI / Gemini REST | AI responses |

## Mandatory Tech Stack (per service)
- Java 21
- Spring Boot 3.3.5
- **Spring Cloud 2023.0.3** (Eureka, Config, Gateway, OpenFeign, LoadBalancer)
- Maven multi-module (`vithey-backend/pom.xml` parent)
- Spring Web
- Spring Data JPA
- PostgreSQL 16 (per-service DB)
- Spring Security + JWT (auth issues; gateway validates; services trust `X-User-Id`)
- springdoc-openapi-starter-webmvc-ui 2.6.0
- Lombok
- MapStruct 1.5.5
- spring-boot-starter-validation
- spring-boot-starter-actuator
- spring-boot-starter-amqp (services with events)
- Flyway migrations
- spring-boot-starter-test, Mockito, Testcontainers

**Full monorepo layout, parent POM, and package tree:** see `SERVICE_BLUEPRINT.md`.

## Gateway / Cloud
| Component | Module | Technology |
|-----------|--------|------------|
| API Gateway | `services/api-gateway` | Spring Cloud Gateway + Redis rate limit |
| Service Discovery | `eureka-server` | Netflix Eureka Server |
| Config | `config-server` + `config-repo/` | Spring Cloud Config (native) |
| Inter-service HTTP | all domain services | OpenFeign + Eureka + LoadBalancer |

## RBAC Roles
| Role | Description |
|------|-------------|
| `USER` | Registered general user |
| `STUDENT` | Verified AUB student (finance access) |
| `COMPANY` | Job poster / recruiter |
| `ADMIN` | Platform admin |

JWT claims must include: `sub` (userId), `email`, `roles[]`.

## Standard Service Package Layout
```text
src/main/java/com/vithey/<service>/
├── <Service>Application.java
├── config/
│   ├── SecurityConfig.java
│   ├── WebConfig.java
│   └── RabbitMqConfig.java          # if events used
├── controller/
├── service/
├── repository/
├── entity/
├── dto/
│   ├── request/
│   └── response/
├── mapper/
├── client/                          # outbound HTTP to other services
├── event/
│   ├── publisher/
│   └── listener/
├── security/
├── exception/
│   ├── GlobalExceptionHandler.java
│   └── ...
└── util/

src/main/resources/
├── application.yml
├── application-dev.yml
└── application-prod.yml

src/test/java/...
```

## Layer Rules
| Layer | Responsibility | Must NOT |
|-------|----------------|----------|
| `controller/` | HTTP mapping, validation, response codes | Business logic, direct DB |
| `service/` | Business rules, orchestration | HTTP request objects |
| `repository/` | JPA queries | Business logic |
| `entity/` | DB mapping | API exposure |
| `dto/` | API contracts | JPA annotations |
| `client/` | Outbound REST to other services | Domain rules |
| `config/` | Beans, security, messaging | Business logic |

## Standard API Response Envelope

### Success (single resource)
```json
{
  "data": { }
}
```

### Success (list with pagination)
```json
{
  "data": [ ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "total_pages": 8
  }
}
```

### Error
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      { "field": "email", "message": "Invalid email format" }
    ]
  }
}
```

## HTTP Status Codes
| Code | When |
|------|------|
| 200 | Success GET/PATCH |
| 201 | Created |
| 204 | No content (logout, delete) |
| 400 | Validation error |
| 401 | Missing/invalid token |
| 403 | Forbidden (role/permission) |
| 404 | Not found |
| 409 | Conflict (duplicate) |
| 422 | Business rule violation |
| 429 | Rate limited |
| 500 | Internal error |
| 502 | Upstream service failure |

## Authentication
- Public: `/auth/register`, `/auth/login`, `/auth/refresh`, `/actuator/health`, Swagger UI
- Protected: `Authorization: Bearer <access_token>`
- Access token TTL: 15 minutes; refresh token: 7 days
- Gateway validates JWT; downstream services may use `@PreAuthorize`

## Pagination Query Params
- `page` (default 1), `limit` (default 20, max 100)
- `sort` — e.g. `-created_at` (desc), `+full_name` (asc)
- `filter[field]=value` for exact match
- `search` for full-text where supported

## Inter-Service Communication
- Use **WebClient** or **OpenFeign** with Eureka service names.
- Pass `X-Request-ID` and `X-User-Id` headers from gateway.
- Timeout: connect 5s, read 30s.
- Retry: max 2 for idempotent GET only.

## RabbitMQ Event Naming
Format: `<domain>.<action>` — e.g. `post.created`, `comment.added`, `payment.due`, `chat.message.sent`, `job.application.submitted`

| Event | Publisher | Consumer(s) |
|-------|-----------|-------------|
| `user.registered` | Auth | User-Profile, Notification |
| `student.verified` | Auth | Finance, Notification |
| `post.created` | Content | Notification |
| `comment.added` | Content | Notification |
| `reaction.added` | Content | Notification |
| `follow.created` | Content | Notification |
| `job.application.submitted` | Career | Notification |
| `payment.due` | Finance | Notification |
| `chat.message.sent` | Chat | Notification |
| `chat.request.received` | Chat | Notification |

## OpenAPI Requirements
- Title: `Vithey <Service> API`
- Version: `1.0.0`
- Every endpoint: `summary`, `description`, `tags`, request/response examples
- Document security scheme: `bearerAuth`
- Swagger UI at `/swagger-ui.html`

## Security Standards
- BCrypt password hashing (Auth Service)
- No secrets in source code — use env vars / Config Server
- Input validation via `@Valid` + Jakarta Validation
- SQL injection prevention: JPA only, no string-concatenated SQL
- CORS configured at Gateway
- Rate limit at Gateway: 100 req/min per user

## Database Rules
- One PostgreSQL database per service
- Flyway or Liquibase migrations (prefer Flyway)
- UUID primary keys
- `created_at`, `updated_at` on all entities
- Soft delete via `deleted_at` where appropriate

## Docker / Local Dev
`docker-compose.yml` at monorepo root must include:
- PostgreSQL instances (or one PG with multiple DBs for dev)
- Redis, RabbitMQ, MinIO, Eureka, Config Server
- All microservices (profile `dev`)

## Testing Requirements (each service)
- Unit tests for service layer
- `@WebMvcTest` for controllers
- Testcontainers integration test for repository (at least one)
- Mock external clients (AI, FCM, MinIO, other services)

## Documentation (each service)
- `README.md` — run, env vars, port
- `API.md` — endpoint summary
- `ARCHITECTURE.md` — boundaries, DB, events, dependencies

## Service Port Registry
| Service | Port | Eureka Name |
|---------|------|-------------|
| API Gateway | 8080 | `api-gateway` |
| Auth | 8081 | `auth-service` |
| User/Profile | 8082 | `user-profile-service` |
| File | 8083 | `file-service` |
| Content | 8084 | `content-service` |
| Career | 8085 | `career-service` |
| Finance | 8086 | `finance-service` |
| Chat | 8087 | `chat-service` |
| Notification | 8088 | `notification-service` |
| AI | 8089 | `ai-service` |
| Eureka | 8761 | — |
| Config Server | 8888 | — |

## Gateway Route Prefixes

**Order matters** — specific `/users/...` paths before `/api/v1/users/**`. Full table: `Prompt Frontend/api-intergration/integration-contract.md`.

| Prefix | Target Service |
|--------|----------------|
| `/api/v1/auth/**` | auth-service |
| `/api/v1/users/me/cv`, `/api/v1/users/me/cv/**` | career-service |
| `/api/v1/users/*/follow`, `/api/v1/users/*/followers`, `/api/v1/users/*/following` | content-service |
| `/api/v1/users/**` (wildcard, lowest priority) | user-profile-service |
| `/api/v1/posts/**`, `/api/v1/comments/**`, `/api/v1/reactions/**`, `/api/v1/follows/**` | content-service |
| `/api/v1/jobs/**`, `/api/v1/job-applications/**` | career-service |
| `/api/v1/fees/**`, `/api/v1/payments/**` | finance-service |
| `/api/v1/students/verify` | auth-service |
| `/api/v1/conversations/**`, `/api/v1/messages/**`, `/api/v1/message-requests/**` | chat-service |
| `/api/v1/notifications/**` | notification-service |
| `/api/v1/ai/**` | ai-service |
| `/api/v1/files/**` | file-service |

## Standardization Rule
- Each service prompt is the single source of truth for that service's API.
- Do not merge domains (e.g. posts in user-service).
- Reuse patterns from root COMMON_CONTEXT; service COMMON_CONTEXT adds only service-specific rules.
- Goal: clean microservices where each team can build and deploy independently.
