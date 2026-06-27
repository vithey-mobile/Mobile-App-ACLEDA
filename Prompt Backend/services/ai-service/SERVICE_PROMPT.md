# AI Service — Service Prompt

Build the AI microservice.

## API Endpoints
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/api/v1/ai/chat` | JWT | Send message, get AI reply |
| GET | `/api/v1/ai/sessions` | JWT | List user's chat sessions |
| GET | `/api/v1/ai/sessions/{id}/messages` | JWT | Session message history |
| DELETE | `/api/v1/ai/sessions/{id}` | JWT | Clear session |
| POST | `/api/v1/ai/cv/suggest` | JWT | CV section improvement suggestion |

## Chat Request
```json
{
  "message": "How to write a good CV?",
  "topic": "CV",
  "session_id": "uuid-or-null-for-new"
}
```

## Chat Response
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

## CV Suggest Request
```json
{
  "section": "experiences",
  "original_text": "I did coding",
  "cv_id": "uuid"
}
```

## CV Suggest Response
```json
{
  "data": {
    "suggested_text": "Developed mobile applications using Flutter...",
    "interaction_id": "uuid"
  }
}
```

## Implementation

### AiProvider Interface
```java
public interface AiProvider {
    String chat(List<ChatMessage> messages, String model);
}
```
Implementations: `OpenAiProvider`, `GeminiProvider` — switch via `AI_PROVIDER` env.

### DirectAiService
- Build message list: system prompt (by topic) + history from DB + user message
- Call provider REST API via `RestClient`
- Save user + assistant messages to `AiChatMessage`
- Return reply

### System Prompts
Store in `src/main/resources/prompts/`:
- `cv-system.md`, `job-system.md`, `interview-system.md`, `student-system.md`, `finance-system.md`

### Context Window
- Load last 10 messages from session for context
- Truncate if token limit exceeded

## Security
- Sanitize user input before sending to AI
- Do not send real payment amounts or passwords to AI
- Rate limit: 30 requests/hour per user (Redis)

## Required Modules
- `AiChatController`, `CvSuggestionController`
- `AiChatService`, `CvSuggestionService`, `AiProviderFactory`
- `OpenAiProvider`, `GeminiProvider`
- `AiChatSessionRepository`, `AiChatMessageRepository`
- `PromptLoader` — load `.md` prompt files
- Flyway, OpenAPI, tests with mocked AI provider

## Output
Runnable ai-service on port 8089.
