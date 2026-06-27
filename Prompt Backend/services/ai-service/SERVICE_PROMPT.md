# AI Service — Service Prompt

Authoritative API contract and build checklist for the Vithey AI microservice.
Read `KICKOFF_PROMPT.md` and both `COMMON_CONTEXT.md` files first.

## Conventions (avoid drift)

- **JSON fields:** `snake_case`. **Java fields:** `camelCase`. Map via MapStruct/Jackson.
- **All responses** use the root envelope (`{ "data": ... }` / `{ "error": ... }`).
- **All IDs** are UUID strings. Lists are paginated per root pagination rules.
- **Current user** comes from the JWT (`sub`), never from the request body.

## API Endpoints (all require JWT)

| Method | Path                                | Description                                       | Success |
| ------ | ----------------------------------- | ------------------------------------------------- | ------- |
| POST   | `/api/v1/ai/chat`                   | Send a message, get an AI reply                   | 200     |
| GET    | `/api/v1/ai/sessions`               | List the current user's chat sessions (paginated) | 200     |
| GET    | `/api/v1/ai/sessions/{id}/messages` | Session message history (paginated)               | 200     |
| DELETE | `/api/v1/ai/sessions/{id}`          | Clear / delete a session                          | 204     |
| POST   | `/api/v1/ai/cv/suggest`             | CV section improvement suggestion                 | 200     |

## Request / Response Shapes

### Chat — request

```json
{
  "message": "How to write a good CV?",
  "topic": "CV",
  "session_id": "uuid-or-null-for-new"
}
```

`topic` ∈ {`CV`, `JOB`, `INTERVIEW`, `STUDENT`, `FINANCE`}. When `session_id` is
null, create a new session with this `topic`; otherwise the existing session's
topic is authoritative.

### Chat — response

```json
{
  "data": {
    "session_id": "uuid",
    "reply": "A good CV should include...",
    "topic": "CV",
    "message_id": "uuid"
  }
}
```

### CV suggest — request

```json
{ "section": "experiences", "original_text": "I did coding", "cv_id": "uuid" }
```

### CV suggest — response

```json
{
  "data": {
    "suggested_text": "Developed mobile applications using Flutter...",
    "interaction_id": "uuid"
  }
}
```

## Implementation

### `AiProvider` interface

```java
public interface AiProvider {
    String chat(List<ChatMessage> messages, String model);
}
```

Implementations: `OpenAiProvider`, `GeminiProvider` — selected via `AI_PROVIDER`
env by `AiProviderFactory`.

### `AiChatService` flow

1. Resolve or create the session (validate ownership against JWT `sub`).
2. Build the message list: system prompt (by topic) + last 10 messages from DB + new user message.
3. Call the provider via `RestClient`.
4. Persist both the user and assistant `AiChatMessage` rows.
5. Return the reply.

### System prompts

Load `.md` files from `src/main/resources/prompts/` via a `PromptLoader`:
`cv-system.md`, `job-system.md`, `interview-system.md`, `student-system.md`, `finance-system.md`.

### Context window

- Load the last 10 messages from the session for context.
- Truncate older messages if the token limit would be exceeded.

## Security

- Sanitize user input before sending it to the provider.
- Never send real payment amounts, passwords, or secrets to the LLM.
- Rate limit: 30 requests/hour per user (Redis counter) → `429` when exceeded.

## Error Behavior (use root envelope + codes)

| Case                                    | Code               | HTTP |
| --------------------------------------- | ------------------ | ---- |
| Session not owned by caller / not found | `NOT_FOUND`        | 404  |
| Invalid topic or validation failure     | `VALIDATION_ERROR` | 400  |
| Rate limit exceeded                     | `RATE_LIMITED`     | 429  |
| Upstream AI provider failure            | `UPSTREAM_ERROR`   | 502  |

## Required Modules

- Controllers: `AiChatController`, `CvSuggestionController`
- Services: `AiChatService`, `CvSuggestionService`, `AiProviderFactory`
- Providers: `OpenAiProvider`, `GeminiProvider`
- Repositories: `AiChatSessionRepository`, `AiChatMessageRepository`
- Support: `PromptLoader` (loads `.md` prompts), `GlobalExceptionHandler`
- Migration: `V1__init_ai_schema.sql`

## Testing

- Chat flow test with a **mocked** `AiProvider` (no real API calls).
- Session ownership / not-found (404) test.
- Rate-limit (429) test.
- `PromptLoader` loads each topic prompt test.

## Docs

`README.md` (run, env vars, port), `API.md` (endpoint summary), `ARCHITECTURE.md` (boundaries, DB, provider abstraction).

## Output

Complete, runnable ai-service on port 8089.
