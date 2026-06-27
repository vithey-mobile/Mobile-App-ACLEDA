# Vithey App — Documentation Index

Clean, per-page documentation for the ACLEDA AUB App Competition project.  
**App name:** Vithey App · **Package:** `aub_connect_app` · **Audience:** AUB students + youth users

## How to update docs

1. **One screen = one file** in `docs/screens/` (use the template in `docs/screens/_SCREEN-TEMPLATE.md`).
2. Edit only the screen you changed — do not paste everything into one file.
3. When UI, API, or logic changes, update these fields in that screen file:
   - Purpose, UI Elements, Logic, Navigation, API endpoints, Flutter module, Backend service, Status checklist.
4. After adding a new screen, add a row to the table below and a link in `01-navigation-and-flow.md`.
5. Cursor prompts live in `Prompt Frontend/`, `Prompt Backend/`, `Prompt Devops/` — keep docs and prompts in sync.

## Quick links

| # | Screen | Doc file | Frontend prompt | Backend service |
|---|--------|----------|-----------------|-----------------|
| 1 | Splash | [01-splash-screen.md](screens/01-splash-screen.md) | `Prompt Frontend/v1/01-splash-prompt.md` | — |
| 2 | Onboarding | [02-onboarding-screen.md](screens/02-onboarding-screen.md) | `v1/02-onboarding-prompt.md` | — |
| 3 | Auth | [03-auth-screen.md](screens/03-auth-screen.md) | `v1/03-auth-prompt.md` | `auth-service` |
| 4 | Home | [04-home-screen.md](screens/04-home-screen.md) | `v1/04-home-prompt.md` | `content-service` |
| 5 | Create Post | [05-create-post-screen.md](screens/05-create-post-screen.md) | `v1/05-create-post-prompt.md` | `content-service`, `file-service` |
| 6 | Post Detail | [06-post-detail-screen.md](screens/06-post-detail-screen.md) | `v1/06-post-detail-prompt.md` | `content-service` |
| 7 | Apply CV | [07-apply-cv-screen.md](screens/07-apply-cv-screen.md) | `v1/07-apply-cv-prompt.md` | `career-service`, `file-service` |
| 8 | Preview CV | [08-preview-cv-screen.md](screens/08-preview-cv-screen.md) | `v1/08-preview-cv-prompt.md` | `career-service`, `file-service` |
| 9 | Profile | [09-profile-screen.md](screens/09-profile-screen.md) | `v1/09-profile-prompt.md` | `user-profile-service` |
| 10 | Finance | [10-finance-screen.md](screens/10-finance-screen.md) | `v1/10-finance-prompt.md` | `finance-service` |
| 11 | Student Verification | [11-student-verification-screen.md](screens/11-student-verification-screen.md) | `v1/11-student-verification-prompt.md` | `auth-service` |
| 12 | Chat | [12-chat-screen.md](screens/12-chat-screen.md) | `v1/12-chat-prompt.md` | `chat-service` |
| 13 | Chat Detail | [13-chat-detail-screen.md](screens/13-chat-detail-screen.md) | `v1/13-chat-detail-prompt.md` | `chat-service` |
| 14 | AI Chatbot | [14-ai-chatbot-screen.md](screens/14-ai-chatbot-screen.md) | `v1/14-chatbot-prompt.md` | `ai-service` |
| 15 | Notification | [15-notification-screen.md](screens/15-notification-screen.md) | `v1/15-notification-prompt.md` | `notification-service` |
| 16 | Settings | [16-settings-screen.md](screens/16-settings-screen.md) | `v1/16-settings-prompt.md` | `user-profile-service` |
| 17 | Applicant CV Preview | [17-applicant-cv-preview-screen.md](screens/17-applicant-cv-preview-screen.md) | `v1/17-applicant-cv-preview-prompt.md` | `career-service` |

## Project-wide docs

| Doc | Description |
|-----|-------------|
| [00-project-summary.md](00-project-summary.md) | What the app does, features, competition rules |
| [01-navigation-and-flow.md](01-navigation-and-flow.md) | Screen flow diagram and routing |
| [reference/frontend.md](reference/frontend.md) | Flutter stack, packages, folder structure |
| [reference/backend.md](reference/backend.md) | Microservices map and layers |
| [reference/api-overview.md](reference/api-overview.md) | API base URL, auth, endpoint index |
| [screens/_SCREEN-TEMPLATE.md](screens/_SCREEN-TEMPLATE.md) | Copy this when adding a new screen |

## Archive

The original GitBook export (4418 lines) is kept at [`archive/Project-Overview-raw.txt`](../archive/Project-Overview-raw.txt) for reference only. **Do not edit the archive** — update files in `docs/` instead.
