# Notification Service — Upgrade for Facebook-Style UI

Upgrade **notification-service** so the Flutter Notification Center (`notification.png`) and push pipeline work end-to-end.

> **Frontend contract:** `Prompt Frontend/Screen prompt/notification/05.notification_api_backend.md`  
> **UI spec:** `01.notification_center.md`, `02.notification_types_routing.md`

## Quick info

| Item | Value |
|------|-------|
| Service | `notification-service` |
| Port | `8088` |
| Database | `notification_db` |
| Gateway prefix | `/api/v1/notifications/**` |
| Push | Firebase Admin SDK (FCM) |
| Events | RabbitMQ consumers |

## Goal

Deliver a backend that supports:

1. Paginated inbox with **server-side All / Unread** filter
2. Rich list rows: **actor**, **type badge** metadata, human **title/body**, **destination** for deep links
3. **Mark read**, **mark all read**, **delete one**
4. **Unread count** for Home bell badge
5. **FCM device registration** + push on new notifications
6. **Idempotent** event ingestion (`dedupe_key`)
7. All **9 Vithey notification categories** + existing extensions (mention, chat request, verification)

## Gap analysis (current vs required)

| Capability | Current `SERVICE_PROMPT.md` | Required for UI |
|------------|----------------------------|-----------------|
| List filter `is_read` | Missing | `GET /notifications?is_read=false` |
| Delete notification | Missing | `DELETE /notifications/{id}` |
| Actor on list row | Missing | `actor { id, full_name, avatar_url }` |
| Structured destination | `reference_id` only | `destination { post_id, conversation_id, … }` |
| Event subtype | Missing | `event` field e.g. `job.application.status_changed` |
| Dedupe on consume | Optional note | Unique `(user_id, dedupe_key)` |
| Types `POST_SHARE`, `AI`, `SYSTEM` | Missing | Add to enum |
| Chat type naming | `CHAT_MESSAGE` vs `CHAT` | Standardize **`CHAT`** in API |
| Payment type naming | `PAYMENT_ALERT` | Standardize **`PAYMENT`** |
| Job type naming | `JOB_APPLICATION`, `JOB_STATUS` | Standardize **`JOB`** + `event` disambiguation |
| FCM data payload | Minimal | Full router fields (see below) |
| Redis unread cache | Not documented | Optional `INCR`/`DECR` per user |

## Database upgrade — V2 migration

File: `db/migration/V2__notification_ui_upgrade.sql`

### Extend `notifications` table

| Column | Type | Purpose |
|--------|------|---------|
| `event` | `varchar(64)` | RabbitMQ event name e.g. `reaction.added` |
| `actor_id` | `UUID` | nullable — who triggered (null for system) |
| `actor_name` | `varchar(120)` | denormalized for list performance |
| `actor_avatar_url` | `text` | nullable signed URL or CDN path |
| `destination` | `jsonb` | structured deep-link payload |
| `dedupe_key` | `varchar(180)` | idempotency key |
| `read_at` | `timestamptz` | nullable — set when marked read |

### Indexes

```sql
CREATE UNIQUE INDEX ux_notifications_user_dedupe
  ON notifications (user_id, dedupe_key)
  WHERE dedupe_key IS NOT NULL;

CREATE INDEX ix_notifications_user_read_created
  ON notifications (user_id, is_read, created_at DESC);
```

### `destination` JSON shape (stored + returned)

```json
{
  "reference_type": "POST",
  "reference_id": "uuid",
  "post_id": "uuid",
  "comment_id": "uuid",
  "user_id": "uuid",
  "conversation_id": "uuid",
  "job_post_id": "uuid",
  "application_id": "uuid",
  "payment_id": "uuid",
  "ai_thread_id": "uuid",
  "route_name": "settings"
}
```

Only include keys relevant to the notification type.

## Notification types (canonical API enum)

```text
LIKE
COMMENT
MENTION
POST_SHARE
FOLLOW
CHAT
CHAT_REQUEST
JOB
PAYMENT
AI
SYSTEM
STUDENT_VERIFICATION
```

Map legacy internal names in repository layer only; **public API uses list above**.

## REST API — full contract

Base: `/api/v1/notifications` — all routes require JWT (`user_id` from token).

### 1. List inbox

```http
GET /notifications?page=1&limit=20&is_read=
```

| Query | Rule |
|-------|------|
| `page` | 1-based, default `1` |
| `limit` | default `20`, max `50` |
| `is_read` | omit = all; `true` = read only; `false` = **unread only** (required for Unread chip) |

**Response `200`:**

```json
{
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "type": "LIKE",
      "event": "reaction.added",
      "title": "New like",
      "body": "Kimheang liked your post.",
      "is_read": false,
      "created_at": "2026-07-09T14:30:00Z",
      "read_at": null,
      "actor": {
        "id": "uuid",
        "full_name": "Kimheang",
        "avatar_url": "https://cdn.example/avatars/kimheang.jpg"
      },
      "destination": {
        "reference_type": "POST",
        "reference_id": "post-uuid",
        "post_id": "post-uuid"
      },
      "dedupe_key": "reaction.added:reaction-uuid"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 42,
    "unread_total": 7
  }
}
```

**Sorting:** `created_at DESC` (newest first). Unread items naturally appear in **New** section on client when `created_at` within 24h.

**Field aliases:** Accept `notification_id` as alias for `id` in responses for backward compatibility.

### 2. Unread count (Home bell badge)

```http
GET /notifications/unread-count
```

```json
{
  "data": { "count": 7 }
}
```

Optional Redis key: `notification:unread:{userId}` — invalidate on read/delete/read-all.

### 3. Mark one read

```http
PATCH /notifications/{id}/read
```

- Owner-only (`user_id` match)
- Sets `is_read=true`, `read_at=now()`
- Decrements Redis unread if used
- `404` if not found or not owned
- Idempotent: second call returns `200`

### 4. Mark all read

```http
PATCH /notifications/read-all
```

```json
{ "data": { "updated_count": 12 } }
```

### 5. Delete one (UI action sheet)

```http
DELETE /notifications/{id}
```

- Owner-only
- Hard-delete row (or soft-delete with `deleted_at` if audit required)
- `204 No Content` on success
- Does **not** delete related post, message, job application, or payment
- Decrements unread if row was unread

### 6. Register FCM device

```http
POST /notifications/devices
```

```json
{ "fcm_token": "...", "platform": "ANDROID" }
```

Platform: `ANDROID` | `IOS`. Upsert on `fcm_token`, bind to current user.

### 7. Unregister FCM device

```http
DELETE /notifications/devices/{token}
```

`204` — call on logout.

## Event → notification mapping (RabbitMQ)

| Event | Publisher | Recipient | type | event | dedupe_key pattern |
|-------|-----------|-----------|------|-------|-------------------|
| `reaction.added` | content-service | Post author | `LIKE` | `reaction.added` | `reaction.added:{reactionId}` |
| `comment.added` | content-service | Post author | `COMMENT` | `comment.added` | `comment.added:{commentId}` |
| `mention.created` | content-service | Mentioned user | `MENTION` | `mention.created` | `mention.created:{mentionId}` |
| `post.shared` | content-service | Original author | `POST_SHARE` | `post.shared` | `post.shared:{shareId}` |
| `follow.created` | user-profile-service | Followed user | `FOLLOW` | `follow.created` | `follow.created:{followId}` |
| `chat.message.sent` | chat-service | Recipient | `CHAT` | `chat.message.sent` | `chat.message.sent:{messageId}` |
| `chat.request.received` | chat-service | Recipient | `CHAT_REQUEST` | `chat.request.received` | `chat.request.received:{requestId}` |
| `job.application.submitted` | career-service | Job owner | `JOB` | `job.application.submitted` | `job.application.submitted:{applicationId}` |
| `job.application.status_changed` | career-service | Applicant | `JOB` | `job.application.status_changed` | `job.application.status_changed:{applicationId}:{status}` |
| `payment.due` | finance-service | Student | `PAYMENT` | `payment.due` | `payment.due:{paymentId}` |
| `payment.overdue` | finance-service | Student | `PAYMENT` | `payment.overdue` | `payment.overdue:{paymentId}` |
| `ai.response.ready` | ai-service | Requesting user | `AI` | `ai.response.ready` | `ai.response.ready:{threadId}` |
| `system.announcement` | notification-service | Target users | `SYSTEM` | `system.announcement` | `system.announcement:{campaignId}:{userId}` |
| `student.verification.updated` | user-profile-service | Student | `STUDENT_VERIFICATION` | `student.verification.updated` | per event id |

### Ingestion flow

```text
1. Consume event from RabbitMQ
2. Resolve recipient user_id
3. Skip if recipient == actor (self-like, self-comment on own post)
4. Build title, body, actor snapshot, destination from event payload
5. INSERT … ON CONFLICT (user_id, dedupe_key) DO NOTHING
6. If inserted: push FCM to recipient device_tokens
7. Optional: INCR Redis unread:{userId}
```

### Title/body templates (server-side)

| type + event | body template |
|--------------|---------------|
| LIKE | `{actorName} liked your post.` |
| COMMENT | `{actorName} commented on your post.` |
| MENTION | `{actorName} mentioned you in a comment.` |
| POST_SHARE | `{actorName} shared your post.` |
| FOLLOW | `{actorName} started following you.` |
| CHAT | `{actorName} sent you a message.` |
| CHAT_REQUEST | `{actorName} sent you a message request.` |
| JOB submitted | `{applicantName} applied for {jobTitle}.` |
| JOB status | `Your application for {jobTitle} was {status}.` |
| PAYMENT due | `Payment of {amount} is due on {date}.` |
| PAYMENT overdue | `Your payment of {amount} is overdue.` |
| AI | `Vithey AI finished your request.` |
| SYSTEM | Use campaign `title` + `body` from event |

**Privacy rules:**

- Never include CV file URLs, payment card data, or full chat message body in `body` or FCM
- Chat push body: *You have a new message* or `{actorName} sent you a message.`

## FCM push payload (v2)

Data map (all string values — FCM requirement):

```json
{
  "notification_id": "uuid",
  "type": "CHAT",
  "event": "chat.message.sent",
  "title": "New message",
  "body": "Kimheang sent you a message.",
  "actor_id": "uuid",
  "actor_name": "Kimheang",
  "reference_type": "CONVERSATION",
  "reference_id": "conversation-uuid",
  "conversation_id": "conversation-uuid",
  "post_id": "",
  "job_post_id": "",
  "application_id": "",
  "payment_id": "",
  "ai_thread_id": "",
  "dedupe_key": "chat.message.sent:msg-uuid"
}
```

Optional notification tray (Android/iOS):

```java
.setNotification(Notification.builder()
    .setTitle(title)
    .setBody(body)
    .build())
```

Android channel by type group:

| Channel | Types |
|---------|-------|
| `chat` | CHAT, CHAT_REQUEST |
| `social` | LIKE, COMMENT, MENTION, POST_SHARE, FOLLOW |
| `jobs` | JOB |
| `payments` | PAYMENT |
| `ai` | AI |
| `system` | SYSTEM, STUDENT_VERIFICATION |

### Chat vs STOMP boundary

| Concern | Owner |
|---------|-------|
| Live thread messages | chat-service WebSocket STOMP |
| Inbox row + background push | notification-service |
| Skip FCM when | Recipient has active `conversationId` in presence (optional v2; document stub) |

chat-service **must not** call Firebase directly — only publish `chat.message.sent`.

## Java implementation checklist

### DTO `NotificationResponse.java`

```java
public record NotificationResponse(
    UUID id,
    String type,
    String event,
    String title,
    String body,
    boolean isRead,
    Instant createdAt,
    Instant readAt,
    ActorDto actor,
    DestinationDto destination,
    String dedupeKey
) {}
```

### Controller additions

```java
@GetMapping
Page<NotificationResponse> list(
    @RequestParam(defaultValue = "1") int page,
    @RequestParam(defaultValue = "20") int limit,
    @RequestParam(required = false) Boolean isRead);

@DeleteMapping("/{id}")
ResponseEntity<Void> delete(@PathVariable UUID id);
```

### Service rules

| Rule | Implementation |
|------|----------------|
| Owner scope | Every query filters `user_id = currentUserId` |
| Pagination | Spring `Pageable`, max limit 50 |
| Delete | `404` if not owner |
| Device upsert | `ON CONFLICT (fcm_token) DO UPDATE SET user_id, platform, updated_at` |
| FCM failure | Log error; notification row still persisted |

### Event listeners to add/extend

| Listener | Events |
|----------|--------|
| `ContentEventListener` | reaction, comment, mention, post.shared |
| `ChatEventListener` | chat.message.sent, chat.request.received |
| `CareerEventListener` | job.application.* |
| `FinanceEventListener` | payment.due, payment.overdue |
| `AiEventListener` | ai.response.ready |
| `SystemNotificationPublisher` | admin broadcast jobs |

## Gateway registration

Add/verify in `api-gateway`:

```yaml
- id: notification-service
  uri: lb://notification-service
  predicates:
    - Path=/api/v1/notifications/**
```

## Publisher contracts (other services must emit)

### Example: `reaction.added`

```json
{
  "event": "reaction.added",
  "reaction_id": "uuid",
  "post_id": "uuid",
  "post_author_id": "uuid",
  "actor": {
    "id": "uuid",
    "full_name": "Kimheang",
    "avatar_url": "https://..."
  },
  "created_at": "2026-07-09T14:30:00Z"
}
```

### Example: `job.application.status_changed`

```json
{
  "event": "job.application.status_changed",
  "application_id": "uuid",
  "job_post_id": "uuid",
  "job_title": "Web Developer",
  "applicant_id": "uuid",
  "status": "ACCEPTED",
  "created_at": "2026-07-09T14:30:00Z"
}
```

destination for applicant:

```json
{
  "reference_type": "JOB_APPLICATION",
  "reference_id": "application-uuid",
  "job_post_id": "uuid",
  "application_id": "uuid"
}
```

## UI row mapping reference (`notification.png`)

| Reference row pattern | type | Notes |
|----------------------|------|-------|
| Sarah liked your photo | `LIKE` | actor avatar + heart badge |
| Mike commented… | `COMMENT` | speech bubble badge |
| Tech Network invited you to event | `SYSTEM` | no actor or org actor |
| Friend request Confirm/Delete | **Out of scope v1** | Vithey uses chat request flow instead |
| Group "12 new posts" | **Aggregation v2** | Optional `GROUP_SUMMARY` — not v1 |
| Birthday reminder | `SYSTEM` | `event=system.birthday` optional later |

Vithey v1 implements **9 core types** from frontend README — not Facebook friend-request inline buttons.

## Error envelope

| HTTP | code | When |
|------|------|------|
| 400 | `VALIDATION_ERROR` | Invalid page/limit/platform |
| 401 | `UNAUTHORIZED` | Missing/invalid JWT |
| 403 | `FORBIDDEN` | Admin-only routes |
| 404 | `NOT_FOUND` | Notification not owned/found |
| 409 | `DUPLICATE` | Idempotent read (treat as 200) |
| 500 | `INTERNAL_ERROR` | Unexpected |

## Testing checklist

- [ ] `GET /notifications?is_read=false` returns only unread rows
- [ ] Pagination `meta.total` and `meta.unread_total` correct
- [ ] `PATCH /{id}/read` idempotent
- [ ] `DELETE /{id}` removes one row; unrelated domain data untouched
- [ ] Duplicate event with same `dedupe_key` does not duplicate row
- [ ] Self-like does not create notification
- [ ] JOB status notification never contains CV URL
- [ ] CHAT FCM omits full message text
- [ ] Device register upserts token on second login
- [ ] unread-count matches DB after read/delete/read-all

## Integration contract update

Add to `Prompt Frontend/api-intergration/integration-contract.md` after implementation:

```markdown
### Notifications (v2)
- List: GET /notifications?page&limit&is_read=
- Response includes: actor, destination, event, dedupe_key
- Delete: DELETE /notifications/{id}
- FCM data: see notification-service UPGRADE_FOR_UI.md
```

## Dependencies

- `Prompt Frontend/Screen prompt/notification/README.md`
- `Prompt Backend/services/content-service/SERVICE_LOGIC.md` (event publishers)
- `Prompt Backend/services/chat-service/SERVICE_LOGIC.md`
- `Prompt Backend/services/career-service/` (job events)
- `Prompt Backend/services/api-gateway/API_ENDPOINTS.md`

## Output

Upgrade **notification-service** to V2 schema + API + event consumers + FCM v2 so the Flutter Notification Center can ship without mock-only data.
