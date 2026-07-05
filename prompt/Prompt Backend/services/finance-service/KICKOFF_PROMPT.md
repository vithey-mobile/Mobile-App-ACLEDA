# Finance Service — Kickoff Prompt

You are building the **Finance Service** for Vithey App: tuition payments, fee
history, payment status, and deadline alerts for verified AUB students.

## Read First (in this order, then stop and build)

1. `../../COMMON_CONTEXT.md` — global platform rules (stack, layout, envelopes, codes).
2. `COMMON_CONTEXT.md` — this service's identity, entities, events, access control, boundaries.
3. `SERVICE_PROMPT.md` — the authoritative API contract and build checklist.

> Precedence on conflict: `SERVICE_PROMPT.md` > service `COMMON_CONTEXT.md` > root `COMMON_CONTEXT.md`.

## Fixed Facts

- **Port:** 8086 · **Database:** `finance_db` · **Package:** `com.vithey.finance`
- **Money:** raw integer amounts + ISO currency code; no formatting in the API.

## Non-Negotiable Rules

- Only `STUDENT`-role / `isStudentVerified` users may access finance endpoints (else `403`).
- A student reads only their own records (scope by `studentId` from the JWT).
- Consumes `student.verified` to link/seed records; publishes `payment.due` / `payment.overdue`.
- Follow the standard response envelope and HTTP status codes from root `COMMON_CONTEXT.md`.

## Definition of Done

A runnable Spring Boot service on port 8086 implementing every endpoint in
`SERVICE_PROMPT.md` plus the daily alert scheduler, with the required modules, tests, and docs.
