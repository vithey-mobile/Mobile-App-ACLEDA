# API Gateway — API Endpoints

Base URL: `http://localhost:8080`

The gateway exposes no domain business APIs. It proxies `/api/v1/**` to downstream services through Eureka.

## Gateway-owned endpoints

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/actuator/health` | Gateway health |
| GET | `/actuator/info` | Gateway metadata |
| GET | `/v3/api-docs/**` | OpenAPI aggregation if enabled |
| GET | `/swagger-ui/**` | Swagger UI if enabled |

## Public proxied paths

These bypass JWT validation:

```text
/api/v1/auth/register
/api/v1/auth/login
/api/v1/auth/refresh
/api/v1/auth/forgot-password
/api/v1/auth/reset-password
/actuator/**
/swagger-ui/**
/v3/api-docs/**
```

## Route table

| Order | Incoming path | Target |
| --- | --- | --- |
| 0 | `/api/v1/auth/**` | `lb://auth-service` |
| 0 | `/api/v1/students/verify` | `lb://auth-service` |
| 0 | `/api/v1/users/me/cv`, `/api/v1/users/me/cv/**` | `lb://career-service` |
| 0 | `/api/v1/users/*/follow`, `/api/v1/users/*/followers`, `/api/v1/users/*/following` | `lb://content-service` |
| 0 | `/api/v1/files/**` | `lb://file-service` |
| 0 | `/api/v1/posts/**` | `lb://content-service` |
| 0 | `/api/v1/job-applications/**` | `lb://career-service` |
| 0 | `/api/v1/fees/**`, `/api/v1/payments/**` | `lb://finance-service` |
| 0 | `/api/v1/conversations/**`, `/api/v1/messages/**`, `/api/v1/message-requests/**` | `lb://chat-service` |
| 0 | `/api/v1/notifications/**` | `lb://notification-service` |
| 0 | `/api/v1/ai/**` | `lb://ai-service` |
| 1 | `/api/v1/users/**` | `lb://user-profile-service` |

## Headers forwarded

- `X-User-Id`
- `X-User-Roles`
- `X-Request-ID`

