# AI / Chatbot — Service Logic (Python — your implementation)

> Integration rules for Java platform. Business logic is yours in Python.

## Ownership

| Owns (Python) | Does not own (Java) |
| --- | --- |
| AI chat sessions & messages | User auth (auth-service) |
| LLM / RAG / chatbot replies | User profiles (user-profile-service) |
| CV text suggestions | Real CV files (file/career-service) |
| Rate limiting (optional) | API routing (api-gateway) |

## Request flow

1. Flutter → Gateway `POST /api/v1/ai/chat`
2. Gateway validates JWT, sets `X-User-Id`
3. Python `ai-service` resolves user from headers
4. Your chatbot logic runs (orchestrator, LLM, etc.)
5. Python returns Vithey envelope JSON

## Safety (recommended)

- Sanitize user input before LLM
- Do not send passwords or payment credentials to LLM
- Finance topic: guidance only, no real account data

## Errors (Vithey standard)

| Case | Code | HTTP |
| --- | --- | --- |
| Missing auth | `UNAUTHORIZED` | 401 |
| Session not owned | `NOT_FOUND` | 404 |
| Invalid topic | `VALIDATION_ERROR` | 400 |
| Rate limit | `RATE_LIMITED` | 429 |
| LLM/upstream fail | `UPSTREAM_ERROR` | 502 |
