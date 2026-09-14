# API Gateway — DB Schema

The API Gateway has no PostgreSQL database and no Flyway migrations.

## Runtime storage

| Store | Purpose |
| --- | --- |
| Redis | Rate limiting token buckets |
| Config Server | JWT secret, CORS origins, route settings |
| Eureka | Service discovery |

## Forbidden persistence

Do not add:

- JPA entities
- PostgreSQL datasource
- Flyway migrations
- Domain tables

All business persistence belongs to downstream domain services.

