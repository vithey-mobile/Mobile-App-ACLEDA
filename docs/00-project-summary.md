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

1. **New user:** Splash → Onboarding (2 slides) → Register/Login → Home feed  
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
| Flutter + GetX | See [reference/frontend.md](reference/frontend.md) |
| Spring Boot 3+ Java 21 | See [reference/backend.md](reference/backend.md) |

Official rules: https://www.acledabank.com.kh/sl/app-competition/

## Design principles

- Simple UX, clear navigation
- Student support and career development
- Secure communication (chat requests, JWT auth)
- Reusable UI components on frontend
- One microservice per domain on backend

## Repo structure (documentation)

```text
docs/                    ← you are here (per-screen specs)
Prompt Frontend/         ← Cursor prompts for Flutter
Prompt Backend/          ← Cursor prompts per microservice
Prompt Devops/           ← Docker, GitHub Actions, GHCR
archive/                 ← raw GitBook export (read-only)
```

## Team workflow

1. Read screen doc in `docs/screens/`  
2. Run matching prompt in `Prompt Frontend/v1/` or `Prompt Backend/services/`  
3. Update screen doc **Status** checklist when done  
4. Commit docs + code together  
