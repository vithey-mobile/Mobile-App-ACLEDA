# Prompt AI — Vithey App

Single place for **all Vithey AI product requirements** and **GLM UI run packs**.

| File | Purpose |
|------|---------|
| [`AI_REQUIREMENTS_AND_TASKS.md`](AI_REQUIREMENTS_AND_TASKS.md) | **Product checklist** — 5 AI blocks + requirements + tasks |
| [`run-glm-flash/`](run-glm-flash/) | **GLM 5.3 Flash** — Flutter UI screens, **mock-first**, parallel after Prompt 00 |

## The 5 AI blocks

1. Auto Create CV  
2. Personalized Feed (profile → posts for this user)  
3. Chatbot Q&A (jobs / media / more)  
4. Skill Score tracking  
5. **Job Apply Match Score** (certify fit for this job)  

## GLM UI pack (frontend mock)

```text
prompt/Prompt Al/run-glm-flash/
  README.md
  COMMON_CONTEXT.md
  00-shared-mock-layer.md    ← run first
  01-auto-cv-screens.md      ← parallel
  02-job-match-screens.md
  03-skill-score-screens.md
  04-smart-feed-screens.md
  05-chatbot-ai-screens.md
  open-terminals.ps1
```

Rules: no real API; no editing `backend/` or `ai_core/` in those chats. Use fixtures + `AiRepository` mocks. Align CV draft shape with `ai_core` StandardCV for later wiring.

Detail APIs stay in Backend (`prompt/Prompt Backend/services/ai-service/`). Screen chrome stays Vithey kit (`Prompt Frontend/run-shadcn-standard/`).
