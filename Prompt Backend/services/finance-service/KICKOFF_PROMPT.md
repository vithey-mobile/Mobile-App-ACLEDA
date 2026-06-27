# Finance Service — Kickoff Prompt

Build the **Finance Service** — tuition payments, fee history, status, and deadline alerts for verified AUB students.

## Read First
1. `../../COMMON_CONTEXT.md` → 2. `COMMON_CONTEXT.md` → 3. `SERVICE_PROMPT.md`

## Port
**8086** | Database: **finance_db**

## Rules
- Only users with `STUDENT` role / `isStudentVerified` can access finance endpoints.
- Publishes `payment.due` events for Notification Service.
