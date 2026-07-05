# API Gateway Architecture

## Responsibility

API Gateway is the single HTTP entry point for Vithey backend clients. It owns routing, JWT validation, CORS, request IDs, user header forwarding, and rate limiting.

It does not own registration, profiles, posts, chat, files, finance, AI, notifications, or any database schema.

## Request Flow

1. Preserve or generate `X-Request-ID`.
2. Let public paths pass without JWT validation.
3. Require `Authorization: Bearer <token>` for protected `/api/v1/**` paths.
4. Validate JWT signature and expiry using `vithey.jwt.secret`.
5. Forward `X-User-Id`, `X-User-Roles`, `X-User-Email`, and `X-Request-ID`.
6. Apply Redis token-bucket rate limiting.
7. Route with `lb://service-name` through Eureka.

## Dependencies

- Eureka Server for service discovery.
- Config Server for centralized configuration.
- Redis for rate limiting.

## Route Priority

Specific routes are declared before broad routes. For example, `/api/v1/users/me/cv` routes to Career Service before `/api/v1/users/**` routes to User Profile Service.

No `/api/v1` prefix is stripped. Downstream services receive the full path.
