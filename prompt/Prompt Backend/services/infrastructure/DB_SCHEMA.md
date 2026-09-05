# Infrastructure — DB Schema

Infrastructure has no application database tables.

It provides the development database bootstrap script for domain services.

## `scripts/init-databases.sql`

```sql
CREATE DATABASE auth_db;
CREATE DATABASE user_db;
CREATE DATABASE file_db;
CREATE DATABASE content_db;
CREATE DATABASE career_db;
CREATE DATABASE finance_db;
CREATE DATABASE chat_db;
CREATE DATABASE notification_db;
CREATE DATABASE ai_db;
```

## Ownership rules

- Eureka Server has no PostgreSQL database.
- Config Server has no PostgreSQL database.
- Domain services own their own schemas and Flyway migrations.
- DevOps may run all databases inside one PostgreSQL container for local development.

