# User Profile Service Architecture

## Responsibility

Owns public profile data, avatar references, user search, language/theme settings, notification preferences, and privacy settings.

Does not own credentials, JWT issuance, file storage, follows, CV, posts, or chat messages.

## Dependencies

- PostgreSQL `user_db`
- RabbitMQ for `user.registered`
- Eureka for service discovery
- Config Server for shared configuration
- `file-service` for avatar file validation

## Startup order

1. PostgreSQL and RabbitMQ
2. Eureka Server
3. Config Server
4. User Profile Service

## Security

JWT is validated locally for direct calls and trusted gateway headers (`X-User-Id`, `X-User-Email`, `X-User-Roles`) when routed through API Gateway.
