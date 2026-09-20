# GLM 5.3 Flash — Vithey AI UI screens (mock-first)

Copy-paste prompts to implement **all 5 AI product blocks** in Flutter UI, using **mock data only** (no real LLM / no live `ai-service` / no `ai_core` HTTP).

Product source of truth: [`../AI_REQUIREMENTS_AND_TASKS.md`](../AI_REQUIREMENTS_AND_TASKS.md)  
Contract references (read only): `prompt/Prompt Backend/services/ai-service/`, `ai_core/README.md`

## Run order

| # | File | Mode | Owns (only) |
|---|------|------|-------------|
| 0 | [`00-shared-mock-layer.md`](00-shared-mock-layer.md) | **First, alone** | flags, models, fixtures, `AiRepository` / thin data hooks |
| 1 | [`01-auto-cv-screens.md`](01-auto-cv-screens.md) | Parallel after 0 | Apply AI CV + Profile “Generate with AI” |
| 2 | [`02-job-match-screens.md`](02-job-match-screens.md) | Parallel after 0 | Apply Review match card + poster applicant AI score |
| 3 | [`03-skill-score-screens.md`](03-skill-score-screens.md) | Parallel after 0 | Profile skill / career readiness UI |
| 4 | [`04-smart-feed-screens.md`](04-smart-feed-screens.md) | Parallel after 0 | Home “For You” ranked mock feed |
| 5 | [`05-chatbot-ai-screens.md`](05-chatbot-ai-screens.md) | Parallel after 0 | Chatbot topics, CTAs, improve-match / improve-skills deep links |

## How (GLM 5.3 Flash)

1. Open **1 chat** → paste everything below `---` in **00**. Wait until it finishes.
2. Open **5 new chats** → paste **01…05** (one each). Run them **in parallel**.
3. Do **not** edit backend, `ai_core`, or gateway in these chats.

Or print paths in Windows Terminal:

```powershell
cd "D:\project\Acleda Mobile App\prompt\Prompt Al\run-glm-flash"
.\open-terminals.ps1
```

## Hard rules (every prompt)

- `USE_MOCK_AI=true` / mock repository paths only — **no real API calls**.
- Reuse Vithey kit: `CustomButton`, `VitheyField`, `VitheyCard`, `StatusBadge` — do not import `shadcn_flutter` from modules.
- Stay inside the 10 modules: `auth home profile jobs finance chat chatbot search settings map`.
- Never invent companies/degrees beyond fixtures (AI-CV-07).
- Match existing GetX + route patterns (`AppRoutes`, bindings).

## Already partially done (do not rewrite from scratch)

- Apply Job → **Create CV with AI** route `/apply-cv/ai-create` under `vithey_app/lib/modules/jobs/ai_cv/`
- `AiCvDraft`, `AiCvFixtures`, `CvRepository.saveDraftAsCv`, `AiRepository.generateCvDraft`

Prompt **01** must **complete / polish** that flow (Profile entry, regenerate section, empty-profile message) — not delete it.

## After all merge

- Hot restart Flutter with `.env` mocks on.
- Smoke: Apply AI CV → Review match score → Submit; Profile skill score; Home For You; Chatbot “Improve skills / match”.
