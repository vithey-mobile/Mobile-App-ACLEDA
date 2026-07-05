# Notification Service — Kickoff Prompt

Build the **Notification Service** — in-app notifications and FCM push for likes, comments, chat, payments, jobs.

## Read First
1. `../../COMMON_CONTEXT.md` → 2. `COMMON_CONTEXT.md` → 3. `SERVICE_PROMPT.md`

## Port
**8088** | Database: **notification_db**

## Rules
- Consumes RabbitMQ events from all domain services.
- FCM for mobile push; store notification history in PostgreSQL.
