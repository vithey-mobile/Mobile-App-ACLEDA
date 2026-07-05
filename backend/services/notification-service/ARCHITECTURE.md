# Notification Service Architecture

## Responsibilities

- Persist in-app notifications per user
- Expose unread counts and read-state APIs
- Register device tokens for FCM push
- Consume domain events from RabbitMQ and fan out notifications

## Event consumers

| Queue | Event | Recipient |
| --- | --- | --- |
| `notification.comment.added` | `comment.added` | Post author |
| `notification.reaction.added` | `reaction.added` | Post author |
| `notification.follow.created` | `follow.created` | Followed user |
| `notification.mention.created` | `mention.created` | Mentioned user |
| `notification.chat.request` | `chat.request.received` | Recipient |
| `notification.chat.message` | `chat.message.sent` | Recipient |
| `notification.payment.due` | `payment.due` | Student |
| `notification.payment.overdue` | `payment.overdue` | Student |
| `notification.job.submitted` | `job.application.submitted` | Job poster |
| `notification.job.status` | `job.application.status_changed` | Applicant |

## Dependencies

- PostgreSQL (`notification_db`)
- RabbitMQ (`vithey.events` topic exchange)
- Eureka + Config Server
- content-service (Feign) for post author lookup on comment/reaction events
- Firebase Admin SDK (optional, for push)

## Data model

- `notifications` — user inbox rows with type, title, body, reference metadata
- `device_tokens` — FCM tokens per user and platform
