# AI Service — Service Logic

## Ownership

Owns AI chat sessions, AI messages, AI provider calls, topic prompts, and CV text suggestions.

Does not own CV files, applications, payments, or user profile records.

## Chat flow

1. Check per-user rate limit in Redis: 30 requests/hour by default.
2. Resolve existing session or create a new `AiChatSession`.
3. Validate session ownership.
4. Load system prompt for topic.
5. Load last 10 messages for context.
6. Call selected `AiProvider`.
7. Persist user message and assistant reply.
8. Return assistant reply in standard envelope.

## Provider abstraction

```java
public interface AiProvider {
  String chat(List<ChatMessage> messages, String model);
}
```

Provider selected by `vithey.ai.provider`: `openai` or `gemini`.

## Safety rules

- Sanitize user input before sending to LLM.
- Do not send passwords, JWTs, or full payment account details.
- Finance topic can provide guidance but must not claim real payment operations.
- Mock provider in tests; never call real external AI in CI.

## Errors

| Case | Code | HTTP |
| --- | --- | --- |
| Session not owned | `NOT_FOUND` | 404 |
| Invalid topic | `VALIDATION_ERROR` | 400 |
| Rate limit exceeded | `RATE_LIMITED` | 429 |
| Provider failure | `UPSTREAM_ERROR` | 502 |

