# GLM 5.3 Flash — GenZ complete UI (all modules)

Unify **every** Vithey screen to one smart GenZ visual system: rounder icons, softer cards, kit-only controls, light + dark. **No half-styled leftovers.**

Brand stays teal `#03B4AC` (`AppColors.primary`). Do **not** invent purple / cream / newspaper themes.

## Run order

| # | File | Mode | Scope |
|---|------|------|--------|
| 0 | [`00-tokens-kit.md`](00-tokens-kit.md) | **Alone first** | Theme tokens + kit radius / icon chrome |
| 1 | [`01-auth.md`](01-auth.md) | Parallel after 0 | `modules/auth/**` |
| 2 | [`02-home.md`](02-home.md) | Parallel after 0 | `modules/home/**` |
| 3 | [`03-profile.md`](03-profile.md) | Parallel after 0 | `modules/profile/**` |
| 4 | [`04-jobs.md`](04-jobs.md) | Parallel after 0 | `modules/jobs/**` |
| 5 | [`05-finance.md`](05-finance.md) | Parallel after 0 | `modules/finance/**` |
| 6 | [`06-chat.md`](06-chat.md) | Parallel after 0 | `modules/chat/**` |
| 7 | [`07-chatbot.md`](07-chatbot.md) | Parallel after 0 | `modules/chatbot/**` |
| 8 | [`08-search.md`](08-search.md) | Parallel after 0 | `modules/search/**` |
| 9 | [`09-settings.md`](09-settings.md) | Parallel after 0 | `modules/settings/**` |
| 10 | [`10-map.md`](10-map.md) | Parallel after 0 | `modules/map/**` |
| 11 | [`11-sweep-completion.md`](11-sweep-completion.md) | **Last alone** | Repo-wide leftover style kill |

Read [`DESIGN_SYSTEM.md`](DESIGN_SYSTEM.md) before any chat.

## How (GLM 5.3 Flash)

1. Open **1 chat** → paste everything below `---` in **00**. Finish it.
2. Open **10 chats** → paste **01…10** (one module each). Run **in parallel**.
3. Open **1 chat** → paste **11** after all 10 merge.

```powershell
cd "D:\project\Acleda Mobile App\prompt\Prompt Frontend\run-genz-complete"
.\open-terminals.ps1
```

## Hard rules (every prompt)

- Kit only: import from `package:aub_connect_app/core/widgets/widgets.dart` (or specific vithey widgets). **No** `shadcn_flutter` in `modules/`.
- Tokens only: `context.appColors.*`, `AppColors.primary`, `VitheyRadii` / `VitheyIconChrome` from Prompt 00.
- Tap targets ≥ 48. Icon hit boxes circular/squircle with **larger radius** (see DESIGN_SYSTEM).
- Light + dark both work — no hardcoded `Colors.white` / `Colors.black` on surfaces.
- Do not change business logic, routes, or mock→API switches unless required for layout.
- Do not edit another module’s folder (parallel safety).
- Do not touch `backend/`, `ai_core/`, or Prompt Al packs.

## Status (mark Done after each GLM chat)

| # | Prompt | Status |
|---|--------|--------|
| 0 | Tokens + kit | Done (2026-09-05) |
| 1 | Auth | Done (2026-09-05) |
| 2 | Home | Done (2026-09-05) |
| 3 | Profile | Done (2026-09-05) |
| 4 | Jobs / Apply / AI CV | Done (2026-09-05) |
| 5 | Finance | Done (2026-09-05) |
| 6 | Chat | Done (2026-09-05) |
| 7 | Chatbot | Done (2026-09-05) |
| 8 | Search | Done (2026-09-05) |
| 9 | Settings | Done (2026-09-05) |
| 10 | Map | Done (2026-09-05) |
| 11 | Sweep + completion | Done (2026-09-05) |

## Done means

- All 10 modules visually consistent (GenZ smart screens)
- Icons use shared chrome (rounder)
- Prompt 11 finds near-zero raw Material CTAs / random radii / `Colors.teal`
- `dart analyze` clean on owned files
