# AI Service — Common Context

> Service-specific context. **Extends** the root `../../COMMON_CONTEXT.md` — all
> global rules (tech stack, package layout, response envelope, HTTP codes, auth,
> DB rules) still apply. This file only adds or overrides what is specific to the
> ai-service. On conflict, the **more specific** file wins:
> `SERVICE_PROMPT.md` > this file > root `COMMON_CONTEXT.md`.

## Service Role

AI-powered assistant for students: CV writing, job applications, interview prep,
general student support, and finance Q&A. Owns chat sessions and AI interactions
only — never real payment, profile, or account data.

## Identity

| Item         | Value                   |
| ------------ | ----------------------- |
| Eureka name  | `ai-service`            |
| Port         | 8089                    |
| Database     | `ai_db` (PostgreSQL 16) |
| Cache        | Redis (rate limiting)   |
| Base package | `com.vithey.ai`         |

## Entities

Use UUID primary keys and `created_at` / `updated_at` on every entity (root DB rules).

### `AiChatSession`

| Field       | Type      | Notes                                                  |
| ----------- | --------- | ------------------------------------------------------ |
| `id`        | UUID      | PK                                                     |
| `userId`    | UUID      | owner (from JWT `sub`)                                 |
| `topic`     | enum      | `CV` \| `JOB` \| `INTERVIEW` \| `STUDENT` \| `FINANCE` |
| `createdAt` | timestamp |                                                        |

### `AiChatMessage`

| Field       | Type      | Notes                   |
| ----------- | --------- | ----------------------- |
| `id`        | UUID      | PK                      |
| `sessionId` | UUID      | FK → `AiChatSession.id` |
| `role`      | enum      | `USER` \| `ASSISTANT`   |
| `content`   | Text      | message body            |
| `createdAt` | timestamp |                         |

## External Provider

Pluggable via `AI_PROVIDER`; both use the OpenAI chat-completions wire format.

- OpenAI API — `https://api.openai.com/v1/chat/completions`
- Gemini OpenAI-compatible endpoint (configurable base URL)

## Env Vars

```
AI_PROVIDER=openai|gemini
AI_API_KEY=...
AI_BASE_URL=...        # provider base URL
AI_MODEL=gpt-4o
```

> Secrets come from env / Config Server only — never hard-coded (root security rules).

## API Prefix (owned by this service)

`/api/v1/ai/**`

## System Prompts (per topic)

One `.md` file per topic under `src/main/resources/prompts/`:

| Topic       | Purpose                                                 |
| ----------- | ------------------------------------------------------- |
| `CV`        | Help write and improve CV sections                      |
| `JOB`       | Job search and application advice                       |
| `INTERVIEW` | Interview preparation tips                              |
| `STUDENT`   | General AUB student support                             |
| `FINANCE`   | Tuition and payment guidance — **no real account data** |

## Does NOT Own

- Real finance / payment data → **Finance Service** (AI gives generic guidance only)
- User profile / CV storage → **User-Profile / File Service**
