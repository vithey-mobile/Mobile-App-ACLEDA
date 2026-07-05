# Per-Service DevOps Prompt Index

Use this folder when you want one backend service to run independently with its own Docker Compose file and GitHub Actions CI workflow.

## Read order

1. `Prompt Devops/COMMON_CONTEXT.md`
2. `Prompt Devops/v1/06-per-service-docker-compose-prompt.md`
3. `Prompt Devops/v1/07-per-service-github-actions-ci-prompt.md`
4. The target service prompt below
5. The matching backend service docs in `Prompt Backend/services/<service>/`

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

Each service prompt creates:

```text
vithey-backend/services/<service>/docker-compose.yml
vithey-backend/services/<service>/.env.example
.github/workflows/<service>-ci.yml
```

Each service must remain compatible with the full-stack DevOps prompts in `Prompt Devops/v1/`.

