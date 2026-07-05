# API Gateway — Service Logic

## Ownership

The gateway owns routing, JWT validation, CORS, request IDs, user header forwarding, and rate limiting.

It does not own registration, profiles, posts, chat, files, AI, finance, or notifications.

## Request flow

1. Generate or preserve `X-Request-ID`.
2. If path is public, proxy directly to downstream service.
3. For protected paths, require `Authorization: Bearer <access_token>`.
4. Validate JWT signature and expiry using Config Server secret.
5. Extract user id and roles from claims.
6. Forward `X-User-Id`, `X-User-Roles`, and `X-Request-ID`.
7. Apply Redis token bucket rate limit.
8. Route with `lb://service-name` through Eureka.

## Important routing rules

- Route `/api/v1/users/me/cv` to `career-service` before generic `/api/v1/users/**`.
- Route `/api/v1/users/{id}/follow`, followers, and following to `content-service` before generic `/api/v1/users/**`.
- Keep full `/api/v1` path when forwarding; do not strip prefix.

## Error envelope

Gateway errors must match backend contract:

```json
{ "error": { "code": "UNAUTHORIZED", "message": "Missing or invalid token", "details": [] } }
```

## Rate limit

- Default: 100 requests/minute.
- Key: `X-User-Id` if authenticated, otherwise client IP for public paths.
- Exceeding limit returns `429 RATE_LIMITED`.

## Tests

- Public auth route passes without JWT.
- Protected route without JWT returns `401`.
- Valid JWT forwards user headers.
- Route precedence sends `/users/me/cv` to career and `/users/{id}/follow` to content.

