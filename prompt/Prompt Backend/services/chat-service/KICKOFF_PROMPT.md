# Chat Service — Kickoff Prompt

You are building the **Chat Service** for Vithey App — private messaging with real-time STOMP, Redis presence/typing, read receipts, media attachments, block, and report.

## Read first

Follow `_shared/READ_ORDER.md` → Backend — one service.

In this folder, read in order:

1. `../../COMMON_CONTEXT.md`
2. `ARCHITECTURE.md` — **start here for system design**
3. `COMMON_CONTEXT.md`
4. `API_ENDPOINTS.md`
5. `FOLDER_STRUCTURE.md`
6. `SERVICE_LOGIC.md`
7. `DB_SCHEMA.md`
8. `SERVICE_PROMPT.md`

**Precedence:** `SERVICE_PROMPT.md` > service `COMMON_CONTEXT.md` > root `COMMON_CONTEXT.md`.

## Identity

Port, DB, package: see service `COMMON_CONTEXT.md`. Registry: `_shared/SERVICE_REGISTRY.md`.

## Rules

- User-to-user chat only — not the AI chatbot (`ai-service`).
- Owns conversations and messages; not profiles, MinIO blobs, or FCM delivery.
- Use **file-service** for uploads; store `file_id` on messages only.
- Publish `chat.message.sent` to RabbitMQ; **notification-service** sends Firebase push.
- Redis is **required** for presence, typing, and recent message cache (not optional).

## Stack summary

```text
Spring Boot + STOMP WebSocket + REST
PostgreSQL (history) + Redis (real-time cache) + RabbitMQ (events)
OpenFeign → file-service (MinIO refs)
Gateway exposes /api/v1/conversations/** and /ws
```

## Definition of done

### Phase v1 (minimum)

- [ ] Runnable Spring Boot on port **8087**, registered in Eureka
- [ ] All REST endpoints in `SERVICE_PROMPT.md`
- [ ] STOMP: connect, `/app/chat.send`, `/user/queue/messages` with `MESSAGE` + `READ_RECEIPT`
- [ ] RabbitMQ `chat.message.sent` and `chat.request.received`
- [ ] Flyway `V1` schema applied
- [ ] Integration tests per root `COMMON_CONTEXT.md`

### Phase v1.1 (real-time)

- [ ] Redis presence + `/app/chat.heartbeat` + `PRESENCE` frames
- [ ] Redis typing + `/app/chat.typing` + `TYPING` frames
- [ ] Redis recent message cache
- [ ] `GET /conversations` returns `is_online`, `unread_count`, `last_message`

### Phase v1.2 (media + idempotency)

- [ ] Flyway `V2` — `message_type`, `file_id`, `reply_to_message_id`, `client_message_id`
- [ ] Feign validation against file-service
- [ ] Batch read `POST /conversations/{id}/messages/read`

### Production

- [ ] API Gateway `/ws/**` → `lb:ws://chat-service`
- [ ] Config Server secrets for Redis, DB, RabbitMQ
- [ ] (Optional) Kafka mirror for `chat.events`

## Flutter contract mirror

Keep backend aligned with `Prompt Frontend/Screen prompt/chat/05.chat_api_realtime.md`.
