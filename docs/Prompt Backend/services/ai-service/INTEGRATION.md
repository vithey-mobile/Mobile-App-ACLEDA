# AI / Chatbot — Platform Integration

> **Current stack (2026-09):** Vithey-facing AI is Python **`ai_core` :8100** (`ai_core/` at repo root).  
> Gateway routes `/api/v1/ai/**` → `http://ai-core:8100`.  
> Chat defaults to **stub** (`AI_CHAT_MODE=stub`). CV generate uses DeepSeek/OpenRouter when `DEEPSEEK_API_KEY` is set.  
> **No Java `ai-service`, no GDCE.** See `backend/DEMO.md` and `backend/DOCKER.md`.

## Architecture

```text
Vithey Flutter (chatbot / AI CV modules)
    │
    ▼
Java API Gateway :8080
    │  JWT validate → X-User-Id, X-User-Email, X-User-Roles
    │  Path=/api/v1/ai/**
    ▼
Python ai_core :8100  (Compose: ai-core)
    ├── stub chat (default)
    └── CV generate / suggest (LLM when keyed)
```

## Java / Compose side — already configured

| Component | Status |
| --- | --- |
| Gateway route `/api/v1/ai/**` | `config-repo/api-gateway.yml` + local `application.yml` → `http://ai-core:8100` |
| JWT + identity headers | `JwtAuthenticationGlobalFilter` |
| Compose service | `ai-core` in `backend/docker-compose.yml` |
| Start | `.\scripts\start-all.ps1` (includes ai_core) |

## Python side — `ai_core/`

| Requirement | Detail |
| --- | --- |
| Folder | `ai_core/` (repo root) |
| Port | **8100** |
| API | `/api/v1/ai/**` (chat, sessions, cv/generate, cv/suggest, …) |
| Auth | Vithey JWT / trusted gateway headers |
| Envelope | Prefer Vithey `{ data, meta, error }` snake_case where applicable |
| Health | `GET /health` → OK |
| Chat mode | `AI_CHAT_MODE=stub` by default |

Optional env: copy `ai_core/.env.example` → `ai_core/.env` and set `DEEPSEEK_API_KEY`.

## chat-service vs ai_core

| Service | Lang | Port | Use |
| --- | --- | --- | --- |
| `chat-service` | Java | 8087 | User-to-user messaging |
| `ai_core` | Python | 8100 | Vithey AI chatbot + CV |

## Verification

```powershell
# after start-all.ps1
Invoke-RestMethod http://localhost:8100/health
curl -X POST http://localhost:8080/api/v1/ai/chat `
  -H "Authorization: Bearer <vithey-jwt>" `
  -H "Content-Type: application/json" `
  -d '{"message":"Hello","topic":"CV"}'
```

Confirm **no** container named `vithey-ai-service`.

## Checklist

- [ ] `ai_core` healthy on `:8100`
- [ ] Gateway `/api/v1/ai/**` points at `http://ai-core:8100`
- [ ] Flutter `USE_MOCK_AI=false` when testing live AI
- [ ] `DEEPSEEK_API_KEY` set only if testing live CV generate
- [ ] Do not start or document Java `ai-service` :8089
