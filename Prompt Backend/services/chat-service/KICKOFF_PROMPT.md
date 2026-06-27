# Chat Service — Kickoff Prompt

You are building the **Chat Service** for Vithey App: private messaging, message
requests, read status, and block/report — over REST + WebSocket (STOMP).

## Read First (in this order, then stop and build)

1. `../../COMMON_CONTEXT.md` — global platform rules (stack, layout, envelopes, codes).
2. `COMMON_CONTEXT.md` — this service's identity, entities, events, real-time, boundaries.
3. `SERVICE_PROMPT.md` — the authoritative API contract and build checklist.

> Precedence on conflict: `SERVICE_PROMPT.md` > service `COMMON_CONTEXT.md` > root `COMMON_CONTEXT.md`.

## Fixed Facts

- **Port:** 8087 · **Database:** `chat_db` · **Cache:** Redis · **Package:** `com.vithey.chat`
- **WebSocket:** STOMP at `/ws/chat`; REST endpoints are the polling fallback.

## Non-Negotiable Rules

- Receiver must **accept a message request** before a full conversation opens (privacy gate).
- Blocked users cannot send messages; a user cannot message themselves.
- Publishes `chat.message.sent` and `chat.request.received` to RabbitMQ; never calls Notification directly.
- Follow the standard response envelope and HTTP status codes from root `COMMON_CONTEXT.md`.

## Definition of Done

A runnable Spring Boot service on port 8087 implementing every endpoint in
`SERVICE_PROMPT.md` plus the STOMP flow, with the required modules, tests, and docs.
