# API Gateway — Service Prompt

Build the Spring Cloud Gateway for Vithey App.

## Goal
Route all `/api/v1/**` traffic to the correct microservice with JWT authentication, rate limiting, and CORS.

## Stack
- Java 21, Spring Boot 3+, Maven
- spring-cloud-starter-gateway
- spring-cloud-starter-netflix-eureka-client
- spring-cloud-starter-config
- spring-boot-starter-actuator
- spring-boot-starter-data-redis-reactive (rate limit bucket)
- jjwt or spring-security-oauth2-resource-server (JWT validation)

## Required Files
```text
api-gateway/
├── pom.xml
├── README.md
└── src/main/java/com/vithey/gateway/
    ├── ApiGatewayApplication.java
    ├── config/
    │   ├── GatewayConfig.java
    │   ├── CorsConfig.java
    │   └── RateLimitConfig.java
    ├── filter/
    │   ├── JwtAuthenticationFilter.java
    │   ├── RequestIdFilter.java
    │   └── RateLimitFilter.java
    └── exception/
        └── GatewayExceptionHandler.java
```

## Route Definitions
| Path | Target (Eureka) | StripPrefix |
|------|-----------------|-------------|
| `/api/v1/auth/**` | `lb://auth-service` | 0 |
| `/api/v1/users/**` | `lb://user-profile-service` | 0 |
| `/api/v1/files/**` | `lb://file-service` | 0 |
| `/api/v1/posts/**` | `lb://content-service` | 0 |
| `/api/v1/comments/**` | `lb://content-service` | 0 |
| `/api/v1/reactions/**` | `lb://content-service` | 0 |
| `/api/v1/follows/**` | `lb://content-service` | 0 |
| `/api/v1/jobs/**` | `lb://career-service` | 0 |
| `/api/v1/job-applications/**` | `lb://career-service` | 0 |
| `/api/v1/fees/**` | `lb://finance-service` | 0 |
| `/api/v1/payments/**` | `lb://finance-service` | 0 |
| `/api/v1/students/verify` | `lb://auth-service` | 0 |
| `/api/v1/conversations/**` | `lb://chat-service` | 0 |
| `/api/v1/messages/**` | `lb://chat-service` | 0 |
| `/api/v1/notifications/**` | `lb://notification-service` | 0 |
| `/api/v1/ai/**` | `lb://ai-service` | 0 |

## JWT Filter Logic
1. Skip public auth paths.
2. Extract `Authorization: Bearer <token>`.
3. Validate signature + expiry using shared secret from config.
4. On failure → `401` with standard error envelope.
5. On success → add `X-User-Id`, `X-User-Roles` headers.

## CORS
- Allow origins: `*` (dev) or configurable list (prod)
- Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS
- Headers: Authorization, Content-Type, X-Request-ID

## Rate Limit
- Redis-backed token bucket per `X-User-Id` or client IP
- 100 req/min default

## Health
- `GET /actuator/health` — include Eureka registry status

## Testing
- WebTestClient tests for public route passthrough
- JWT filter unit tests (valid, expired, missing token)
- Rate limit returns 429 after threshold

## Output
Complete runnable gateway registering with Eureka on port 8080.
