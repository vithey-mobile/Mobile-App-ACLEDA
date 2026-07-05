# Environment Variables

## Auth Service

Defined in `services/auth-service/.env.example`.

| Variable | Purpose |
| --- | --- |
| `SERVER_PORT` | Auth service HTTP port, default `8081`. |
| `SPRING_PROFILES_ACTIVE` | Use `docker` for Docker Compose. |
| `CONFIG_SERVER_URL` | Config Server URL inside Compose. |
| `EUREKA_CLIENT_ENABLED` | Enables Eureka registration in Docker. |
| `EUREKA_URL` | Eureka service URL. |
| `AUTH_DB_URL` | PostgreSQL JDBC URL. |
| `AUTH_DB_USERNAME` | PostgreSQL username. |
| `AUTH_DB_PASSWORD` | PostgreSQL password. |
| `RABBITMQ_HOST` | RabbitMQ hostname. |
| `RABBITMQ_PORT` | RabbitMQ AMQP port. |
| `RABBITMQ_USERNAME` | RabbitMQ username. |
| `RABBITMQ_PASSWORD` | RabbitMQ password. |
| `VITHEY_JWT_SECRET` | Shared JWT signing secret for auth and gateway. |
| `VITHEY_ACCESS_TOKEN_TTL` | Access token TTL, default `15m`. |
| `VITHEY_REFRESH_TOKEN_TTL` | Refresh token TTL, default `7d`. |
| `VITHEY_EVENTS_EXCHANGE` | RabbitMQ topic exchange name. |
