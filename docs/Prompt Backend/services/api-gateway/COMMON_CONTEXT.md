# API Gateway — Common Context

## Service Role
Single API entry point. Routes requests to microservices via Eureka. Enforces JWT, rate limits, and CORS.

## Identity
| Item | Value |
|------|-------|
| Eureka name | `api-gateway` |
| Port | 8080 |
| Database | None |
| Package | `com.vithey.gateway` |

## Public Routes (no JWT)
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/refresh`
- `POST /api/v1/auth/forgot-password`
- `POST /api/v1/auth/reset-password`
- `GET /actuator/health`
- `GET /swagger-ui/**` (optional aggregate or per-service direct)

## Protected Routes
All other `/api/v1/**` require valid JWT.

## Headers Forwarded to Downstream
- `Authorization`
- `X-Request-ID` (generate if missing)
- `X-User-Id` (from JWT `sub`)
- `X-User-Roles` (from JWT claims)

## Rate Limiting
- 100 requests/minute per user (or per IP if anonymous)
- Return `429` with `Retry-After` header

## Dependencies
- Eureka (service discovery)
- Config Server (routes, JWT secret)
- Auth Service (optional JWKS endpoint for token validation)

## Clients
- Flutter Mobile App (`aub_connect_app`)
- Admin Panel (future)
- External API consumers
