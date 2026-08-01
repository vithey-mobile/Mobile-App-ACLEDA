# Project Summary — Vithey App

## What is this app?

A complete digital platform for **AUB students** and general users combining:

- Social feed (video, poster, job posts)
- Job applications with CV upload
- Student finance (verified AUB students only)
- Private chat with message-request privacy
- AI assistant (CV, jobs, interviews, finance)
- Notifications and settings (light/dark theme)

## Core user journeys

1. **New user:** Splash → Onboarding (3 slides) → Register/Login → Home feed  
2. **Social:** Browse feed → Like / comment / follow → View post detail → Create post  
3. **Jobs:** See job post → Apply CV → Job poster reviews applicants  
4. **Student finance:** Verify AUB student → View payments & deadline alerts  
5. **Chat:** Send message request → Accept → Chat in real time  
6. **AI:** Ask questions about CV, jobs, interviews, or finance  

## Competition requirements (ACLEDA)

| Requirement | Vithey App |
|-------------|------------|
| Youth-focused mobile app | Yes |
| Min. 5 features | Feed, jobs, finance, chat, AI (+ notifications, profile) |
| Register / Login | Auth screen |
| Settings menu | Settings screen |
| Light + Dark mode | Settings + theme system |
| Flutter + GetX | See `COMMON_CONTEXT.md` |
| Spring Boot 3+ Java 21 | See `Prompt Backend/COMMON_CONTEXT.md` |

Official rules: https://www.acledabank.com.kh/sl/app-competition/

## Design principles

- Simple UX, clear navigation
- Student support and career development
- Secure communication (chat requests, JWT auth)
- Reusable UI components on frontend
- One microservice per domain on backend

## Repo structure (documentation)

```text
Prompt Frontend/README.md      ← frontend task entry point
Prompt Frontend/03-flutter-code-audit-and-refactor.md
                               ← existing-code audit/refactor prompt
Prompt Frontend/Screen prompt/ ← all screen specs + AI prompts
Prompt Frontend/               ← Flutter context + API contract
Prompt Backend/                ← Cursor prompts per microservice
Prompt Devops/                 ← Docker, GitHub Actions, GHCR
```

## Integration readiness

| Layer | Docs | Code |
|-------|------|------|
| Product screens | Complete in `Screen prompt/` | In progress in `vithey_app/` |
| Flutter prompts | `Screen prompt/` feature flows | `vithey_app/` — 42 routes, 16 modules |
| Backend prompts | `Prompt Backend/services/` | In progress in `backend/` |
| API contract | `api-intergration/integration-contract.md` | Aligned across prompts |
| DevOps | `Prompt Devops/v1/` | In progress |

### Flutter module status (`vithey_app/`)

| Module | Routes | UI status |
|--------|--------|-----------|
| Auth + startup | 9 | Complete (Google OAuth demo) |
| Home / media | 3 | Partial (create post media stubbed) |
| Profile | 5 | Partial (edit save, CV preview) |
| Job apply | 3 | Complete |
| Finance + verify | 3 | Complete |
| Chat | 3 | Complete (in-chat search stubbed) |
| Chatbot | 1 | Partial (new design in progress) |
| Search | 2 | Complete |
| Notifications | 1 | Partial (some deep links) |
| Settings | 7 | Complete (2FA placeholder) |

**Verdict:** Documentation is integration-ready. Continue build following [02-ai-implementation-guide.md](02-ai-implementation-guide.md) and module acceptance checklists in each `Screen prompt/<module>/README.md`.

## Team workflow

1. Read `api-intergration/integration-contract.md` and the screen file in `Screen prompt/`  
2. Give the coding agent the matching prompt in `Screen prompt/`,
   `Prompt Backend/services/`, or
   `03-flutter-code-audit-and-refactor.md`
3. Update **Status checklist** in that screen file when done  
4. Commit docs + code together  
