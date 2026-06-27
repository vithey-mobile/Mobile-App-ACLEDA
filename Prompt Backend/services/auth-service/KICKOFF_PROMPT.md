# Auth Service — Kickoff Prompt

Build the **Auth Service** for Vithey App — registration, login, JWT, RBAC, and student verification.

## Read First
1. `../../COMMON_CONTEXT.md`
2. `COMMON_CONTEXT.md`
3. `SERVICE_PROMPT.md`

## Port
**8081** | Database: **auth_db**

## Rules
- Owns user credentials and refresh tokens only — profile data lives in User-Profile Service.
- Publishes `user.registered` and `student.verified` events to RabbitMQ.
