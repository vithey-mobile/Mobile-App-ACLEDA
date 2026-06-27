# Career Service — Kickoff Prompt

You are building the **Career Service** for Vithey App: job applications, CV file
references, application-status tracking, and applicant review for job posters.

## Read First (in this order, then stop and build)

1. `../../COMMON_CONTEXT.md` — global platform rules (stack, layout, envelopes, codes).
2. `COMMON_CONTEXT.md` — this service's identity, entities, events, clients, authorization, boundaries.
3. `SERVICE_PROMPT.md` — the authoritative API contract and build checklist.

> Precedence on conflict: `SERVICE_PROMPT.md` > service `COMMON_CONTEXT.md` > root `COMMON_CONTEXT.md`.

## Fixed Facts

- **Port:** 8085 · **Database:** `career_db` · **Package:** `com.vithey.career`

## Non-Negotiable Rules

- Job posts are created in **Content Service**; this service handles applications against `postId`.
- CV files are uploaded via **File Service**; store only the `cvFileId` reference.
- One application per user per job post (`409` on duplicate).
- Status updates are restricted to the post owner (verify via Content Service).
- Publishes `job.application.submitted` / `job.application.status_changed`; never calls Notification directly.
- Follow the standard response envelope and HTTP status codes from root `COMMON_CONTEXT.md`.

## Definition of Done

A runnable Spring Boot service on port 8085 implementing every endpoint in
`SERVICE_PROMPT.md`, with the required modules, tests, and docs.
