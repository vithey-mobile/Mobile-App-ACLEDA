# API Gateway — Complete API Design

> Read `SERVICE_BLUEPRINT.md`, `COMMON_CONTEXT.md`, and `integration-contract.md`.  
> **Scope:** Routing + JWT + CORS + rate limit only. No domain business logic.

## Monorepo

`vithey-backend/services/api-gateway/` · Port **8080** · Eureka: `api-gateway`

## Spring Cloud stack

| Dependency | Purpose |
|------------|---------|
| `spring-cloud-starter-gateway` | Reactive gateway |
| `spring-cloud-starter-netflix-eureka-client` | `lb://service-name` routing |
| `spring-cloud-starter-config` | JWT secret, CORS origins |
| `spring-boot-starter-data-redis-reactive` | Rate limiting |
| `spring-boot-starter-actuator` | Health |
| `jjwt-api` + `jjwt-impl` + `jjwt-jackson` | JWT validation |

**No JPA, no PostgreSQL, no RabbitMQ.**

## Folder structure

```text
services/api-gateway/
├── pom.xml
├── README.md
└── src/main/java/com/vithey/gateway/
    ├── ApiGatewayApplication.java          # @EnableDiscoveryClient
    ├── config/
    │   ├── GatewayRouteConfig.java         # ordered routes (Java DSL or yaml)
    │   ├── CorsConfig.java
    │   ├── RedisRateLimiterConfig.java
    │   └── OpenApiConfig.java              # optional gateway swagger
    ├── filter/
    │   ├── JwtAuthenticationGlobalFilter.java
    │   ├── RequestIdGlobalFilter.java
    │   └── UserHeaderForwardFilter.java    # X-User-Id, X-User-Roles
    ├── security/
    │   └── JwtValidator.java
    ├── exception/
    │   └── GatewayErrorHandler.java        # standard error envelope
    └── util/
        └── PublicPathMatcher.java
└── src/main/resources/
    ├── bootstrap.yml
    └── application.yml
```

## Public paths (no JWT)

```
/api/v1/auth/register
/api/v1/auth/login
/api/v1/auth/refresh
/api/v1/auth/forgot-password
/api/v1/auth/reset-password
/actuator/**
/swagger-ui/**
/v3/api-docs/**
```

## Route definitions (order matters)

| Order | Path | Target |
|-------|------|--------|
| 0 | `/api/v1/auth/**` | `lb://auth-service` |
| 0 | `/api/v1/users/me/cv`, `/api/v1/users/me/cv/**` | `lb://career-service` |
| 0 | `/api/v1/users/*/follow`, `*/followers`, `*/following` | `lb://content-service` |
| 0 | `/api/v1/files/**` | `lb://file-service` |
| 0 | `/api/v1/posts/**`, `/comments/**`, `/reactions/**`, `/follows/**` | `lb://content-service` |
| 0 | `/api/v1/jobs/**`, `/job-applications/**` | `lb://career-service` |
| 0 | `/api/v1/fees/**`, `/payments/**` | `lb://finance-service` |
| 0 | `/api/v1/students/verify` | `lb://auth-service` |
| 0 | `/api/v1/conversations/**`, `/messages/**`, `/message-requests/**` | `lb://chat-service` |
| 0 | `/api/v1/notifications/**` | `lb://notification-service` |
| 0 | `/api/v1/ai/**` | `lb://ai-service` |
| 1 | `/api/v1/users/**` | `lb://user-profile-service` |

Strip prefix: **0** (full path forwarded).

## JWT filter logic

1. If public path → pass through
2. Extract `Authorization: Bearer <token>`
3. Validate signature + expiry (`vithey.jwt.secret` from config)
4. On failure → `401` + `{ "error": { "code": "UNAUTHORIZED", ... } }`
5. On success → set headers `X-User-Id`, `X-User-Roles`, `X-Request-ID`

## Rate limit

Redis token bucket: **100 req/min** per `X-User-Id` or client IP → `429 RATE_LIMITED`.

## CORS

Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS  
Headers: Authorization, Content-Type, X-Request-ID  
Origins: `*` (dev) / configurable list (prod)

## Gateway API surface

The gateway exposes **no business APIs** — only proxies `/api/v1/**` to services.

| Endpoint | Description |
|----------|-------------|
| `GET /actuator/health` | Gateway + discovery health |

## Testing

- WebTestClient: public `/auth/login` proxied without token
- Protected route without token → 401
- Valid JWT → 200 from downstream (mock or wiremock)
- Rate limit → 429 after threshold

## Output

Runnable gateway on 8080, registered in Eureka, all routes working via `lb://`.
