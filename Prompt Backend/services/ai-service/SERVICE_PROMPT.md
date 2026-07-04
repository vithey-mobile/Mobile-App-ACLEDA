# AI Service — Complete API Design

> Read `SERVICE_BLUEPRINT.md`, `COMMON_CONTEXT.md`.  
> **Scope:** Backend REST API only — AI chat sessions, CV suggestions.

## Identity

| Item | Value |
|------|-------|
| Path | `vithey-backend/services/ai-service/` |
| Port | 8089 |
| Eureka | `ai-service` |
| Database | `ai_db` |
| Package | `com.vithey.ai` |

## Spring Cloud + tools

Eureka, Config, **Redis** (rate limit), JPA, Flyway, RestClient to OpenAI/Gemini.

## Folder structure

```text
services/ai-service/
└── src/main/java/com/vithey/ai/
    ├── AiServiceApplication.java
    ├── config/RedisConfig.java, SecurityConfig.java, OpenApiConfig.java, AiProviderConfig.java
    ├── controller/AiChatController.java, CvSuggestionController.java
    ├── service/AiChatService.java, CvSuggestionService.java, AiRateLimitService.java
    ├── provider/AiProvider.java, OpenAiProvider.java, GeminiProvider.java, AiProviderFactory.java
    ├── repository/AiChatSessionRepository.java, AiChatMessageRepository.java
    ├── entity/AiChatSession.java, AiChatMessage.java
    ├── dto/request/ChatRequest.java, CvSuggestRequest.java
    ├── dto/response/ChatResponse.java, CvSuggestResponse.java, SessionResponse.java
    ├── support/PromptLoader.java
    └── exception/GlobalExceptionHandler.java
└── resources/prompts/
    ├── cv-system.md
    ├── job-system.md
    ├── interview-system.md
    ├── student-system.md
    └── finance-system.md
```

## Database

**AiChatSession:** `id`, `user_id`, `topic` CV|JOB|INTERVIEW|STUDENT|FINANCE, `created_at`, `updated_at`

**AiChatMessage:** `id`, `session_id`, `role` USER|ASSISTANT, `content`, `created_at`

## Complete API (all JWT)

| Method | Path | Request | HTTP |
|--------|------|---------|------|
| POST | `/api/v1/ai/chat` | ChatRequest | 200 |
| GET | `/api/v1/ai/sessions` | paginated | 200 |
| GET | `/api/v1/ai/sessions/{id}/messages` | paginated | 200 |
| DELETE | `/api/v1/ai/sessions/{id}` | — | 204 |
| POST | `/api/v1/ai/cv/suggest` | CvSuggestRequest | 200 |

**Chat request:**
```json
{
  "message": "How to write a good CV?",
  "topic": "CV",
  "session_id": null
}
```

**Chat response:**
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

**CV suggest request:**
```json
{ "section": "experiences", "original_text": "I did coding", "cv_id": "uuid" }
```

**CV suggest response:**
```json
{
  "data": {
    "suggested_text": "Developed mobile applications using Flutter...",
    "interaction_id": "uuid"
  }
}
```

## Business logic — AiChatService

1. Rate limit check (30 req/hour/user via Redis) → 429
2. Resolve or create session (validate `user_id` == JWT sub)
3. Load system prompt from `prompts/{topic}-system.md`
4. Load last 10 messages from DB for context
5. Call `AiProvider.chat()` via RestClient
6. Persist user + assistant messages
7. Return reply

## AiProvider

```java
public interface AiProvider {
  String chat(List<ChatMessage> messages, String model);
}
```

Selected by `vithey.ai.provider` = `openai` | `gemini`.

## Security

- Sanitize input before LLM
- Never send passwords, full payment details to provider
- Session ownership enforced on all session endpoints

## Errors

| Case | HTTP |
|------|------|
| Session not found / not owned | 404 |
| Invalid topic | 400 |
| Rate limit | 429 |
| Provider failure | 502 |

## Testing

Mock AiProvider; no real API calls in CI; rate limit test; session ownership test.

## Output

Runnable ai-service on **8089**.
