# Auth Service Architecture

## Responsibility

Auth Service owns account credentials, roles, JWT issuing, refresh token rotation, password reset tokens, email verification tokens, and AUB student verification.

It does not own public profiles, avatars, posts, chat, notifications, finance data, or uploaded files.

## Layers

- `controller`: HTTP mappings and validation.
- `service`: auth flows, token rotation, password reset, and student verification rules.
- `repository`: JPA persistence only.
- `entity`: auth-owned database tables.
- `security`: JWT issuing/parsing and gateway header authentication.
- `event`: RabbitMQ publishers and payloads.

## Database

Database: `auth_db`

Tables:

- `users`
- `refresh_tokens`
- `password_reset_tokens`
- `email_verification_tokens`
- `student_verifications`

Flyway migration: `src/main/resources/db/migration/V1__init_auth_schema.sql`

## Events

Published to topic exchange `vithey.events`:

- `user.registered`
- `student.verified`

RabbitMQ publish failures are logged so local development can run without RabbitMQ. Production deployments should run RabbitMQ and monitor publisher failures.
