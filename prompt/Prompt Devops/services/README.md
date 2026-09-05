# Per-Service DevOps Prompt Index

Use this folder for one backend service's Docker Compose and GitHub Actions CI.

## Read order

1. `_shared/READ_ORDER.md` → DevOps — one service
2. `Prompt Devops/v1/06-per-service-docker-compose-prompt.md`
3. Target `services/<service>/DEVOPS_PROMPT.md`
4. Matching `Prompt Backend/services/<service>/` if wiring env or ports

## Service prompts

| Service | Prompt |
| --- | --- |
| Infrastructure | `infrastructure/DEVOPS_PROMPT.md` |
| API Gateway | `api-gateway/DEVOPS_PROMPT.md` |
| Auth Service | `auth-service/DEVOPS_PROMPT.md` |
| User Profile Service | `user-profile-service/DEVOPS_PROMPT.md` |
| File Service | `file-service/DEVOPS_PROMPT.md` |
| Content Service | `content-service/DEVOPS_PROMPT.md` |
| Career Service | `career-service/DEVOPS_PROMPT.md` |
| Finance Service | `finance-service/DEVOPS_PROMPT.md` |
| Chat Service | `chat-service/DEVOPS_PROMPT.md` |
| Notification Service | `notification-service/DEVOPS_PROMPT.md` |
| AI Service | `ai-service/DEVOPS_PROMPT.md` |

## Output pattern

```text
backend/services/<service>/docker-compose.yml
backend/services/<service>/.env.example
.github/workflows/<service>-ci.yml
```

Compose rules and shared infra deps: `_shared/SERVICE_REGISTRY.md`.
