# Vithey Backend — Domain Events

> Canonical event contracts for RabbitMQ. Exchange: `vithey.events` (config: `vithey.events.exchange`).

All events use JSON payloads with **snake_case** keys. Publishers must not break existing fields; add optional fields only.

## Exchange

| Setting | Value |
|---------|-------|
| Exchange | `vithey.events` |
| Type | topic |
| Durable | true |

## Events

### `job.application.submitted`

**Publisher:** career-service  
**Consumers:** notification-service (optional)

```json
{
  "application_id": "uuid",
  "job_post_id": "uuid",
  "applicant_id": "uuid",
  "cv_file_id": "uuid",
  "status": "PENDING",
  "applied_at": "2026-07-07T09:14:00Z"
}
```

### `job.application.status_changed`

**Publisher:** career-service  
**Consumers:** notification-service

```json
{
  "application_id": "uuid",
  "job_post_id": "uuid",
  "applicant_id": "uuid",
  "previous_status": "PENDING",
  "status": "REVIEWED",
  "changed_by": "uuid",
  "changed_at": "2026-07-08T08:10:00Z"
}
```

### `profile.updated`

**Publisher:** user-profile-service  
**Consumers:** (future search index)

```json
{
  "user_id": "uuid",
  "updated_at": "2026-07-07T10:00:00Z"
}
```

### `post.created`

**Publisher:** content-service  
**Consumers:** notification-service (followers, optional)

```json
{
  "post_id": "uuid",
  "author_id": "uuid",
  "type": "JOB",
  "created_at": "2026-07-07T10:00:00Z"
}
```

### `chat.message.sent`

**Publisher:** chat-service  
**Consumers:** notification-service, push pipeline

```json
{
  "message_id": "uuid",
  "conversation_id": "uuid",
  "sender_id": "uuid",
  "created_at": "2026-07-07T10:00:00Z"
}
```

## Routing keys

Use routing key = event name (e.g. `job.application.submitted`) unless service-specific binding requires a prefix.

## Versioning

- Breaking changes require a new event name suffix (e.g. `job.application.submitted.v2`).
- Consumers must ignore unknown JSON fields.
