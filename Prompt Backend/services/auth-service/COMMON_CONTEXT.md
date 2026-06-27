# Auth Service — Common Context

> Service-specific context. **Extends** the root `../../COMMON_CONTEXT.md` —
> all global rules (tech stack, package layout, response envelope, HTTP codes,
> token TTLs, security, DB rules) still apply. This file only adds or overrides
> what is specific to the auth-service. On any conflict, the **more specific**
> file wins: `SERVICE_PROMPT.md` > this file > root `COMMON_CONTEXT.md`.

## Service Role

Authentication, authorization tokens, RBAC roles, and AUB student verification.
Owns user **credentials** and **refresh tokens** only — never profile data.

## Identity

| Item         | Value                     |
| ------------ | ------------------------- |
| Eureka name  | `auth-service`            |
| Port         | 8081                      |
| Database     | `auth_db` (PostgreSQL 16) |
| Base package | `com.vithey.auth`         |

## Entities

Use UUID primary keys and `created_at` / `updated_at` on every entity (root DB rules).

### `User`

| Field                     | Type        | Notes                       |
| ------------------------- | ----------- | --------------------------- |
| `id`                      | UUID        | PK                          |
| `email`                   | String      | unique, not null            |
| `phone`                   | String      | unique, nullable            |
| `passwordHash`            | String      | BCrypt, not null            |
| `role`                    | enum `Role` | one of the RBAC roles below |
| `isActive`                | boolean     | default `true`              |
| `isEmailVerified`         | boolean     | default `false`             |
| `isStudentVerified`       | boolean     | default `false`             |
| `createdAt` / `updatedAt` | timestamp   |                             |

### `RefreshToken`

| Field       | Type      | Notes                  |
| ----------- | --------- | ---------------------- |
| `id`        | UUID      | PK                     |
| `userId`    | UUID      | FK → `User.id`         |
| `token`     | String    | unique, hashed at rest |
| `expiresAt` | timestamp | 7-day TTL (root)       |
| `revoked`   | boolean   | default `false`        |

### `StudentVerification`

| Field             | Type      | Notes                                 |
| ----------------- | --------- | ------------------------------------- |
| `id`              | UUID      | PK                                    |
| `userId`          | UUID      | FK → `User.id`                        |
| `studentId`       | String    | e.g. `AUB2024001`                     |
| `universityEmail` | String    | must match AUB domain                 |
| `status`          | enum      | `PENDING` \| `VERIFIED` \| `REJECTED` |
| `verifiedAt`      | timestamp | nullable until verified               |

## Roles (RBAC)

`USER`, `STUDENT`, `COMPANY`, `ADMIN` (see root for descriptions).
A successful student verification promotes `USER` → `STUDENT`.

## Events Published

Publish to RabbitMQ using the root `<domain>.<action>` naming.

| Event              | Payload                             | Consumers                  |
| ------------------ | ----------------------------------- | -------------------------- |
| `user.registered`  | `{ userId, email, fullName, role }` | User-Profile, Notification |
| `student.verified` | `{ userId, studentId }`             | Finance, Notification      |

## Dependencies

Eureka, Config Server, PostgreSQL (`auth_db`), RabbitMQ.

## Does NOT Own (hard boundaries — do not implement here)

- User profile (bio, avatar, social links, settings) → **User-Profile Service**
- Payment / fee data → **Finance Service**
- Notification delivery → **Notification Service** (auth only publishes events)
