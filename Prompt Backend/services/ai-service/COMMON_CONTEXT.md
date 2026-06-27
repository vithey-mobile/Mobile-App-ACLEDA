# AI Service — Common Context

## Service Role
AI-powered assistant for students: CV writing, job applications, interviews, student support, finance questions.

## Identity
| Item | Value |
|------|-------|
| Eureka name | `ai-service` |
| Port | 8089 |
| Database | `ai_db` |
| Package | `com.vithey.ai` |

## Entities
- `AiChatSession` — id, userId, topic (CV/JOB/INTERVIEW/STUDENT/FINANCE), createdAt
- `AiChatMessage` — id, sessionId, role (USER/ASSISTANT), content, createdAt

## External Provider
- OpenAI API (`https://api.openai.com/v1/chat/completions`)
- Gemini OpenAI-compatible endpoint (configurable)

## Env Vars
```
AI_PROVIDER=openai|gemini
AI_API_KEY=...
AI_BASE_URL=...
AI_MODEL=gpt-4o
```

## API Prefix
`/api/v1/ai/**`

## System Prompts (per topic)
- CV: help write and improve CV sections
- JOB: job search and application advice
- INTERVIEW: interview preparation tips
- STUDENT: general AUB student support
- FINANCE: tuition and payment guidance (no real account data)
