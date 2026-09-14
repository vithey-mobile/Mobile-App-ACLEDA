# GLM 5.3 Flash — Type + color tokens (all modules)

Extract **font size, font weight, and leftover surface colors** into one reusable theme layer (`VitheyType` / `VitheyWeight` + `textTheme`), then replace inline `TextStyle` blobs. **Same pixels as today.** Less code — no new text widgets. **Not** a GenZ restyle.

Brand stays teal `#03B4AC` (`AppColors.primary`). Do **not** invent purple / cream themes or normalize sizes (13 stays 13).

## Run order

| # | File | Mode | Scope |
|---|------|------|--------|
| 0 | [`00-tokens.md`](00-tokens.md) | **Alone first** | `VitheyType` / `VitheyWeight` + light/dark `textTheme` + kit/alerts |
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
| 11 | [`11-sweep.md`](11-sweep.md) | **Last alone** | Repo-wide leftover `fontSize` / `FontWeight` / surface hex |

Read [`DESIGN.md`](DESIGN.md) before any chat.

## How (GLM 5.3 Flash)

1. Open **1 chat** → paste everything below `---` in **00**. Finish it.
2. Open **10 chats** → paste **01…10** (one module each). Run **in parallel**.
3. Open **1 chat** → paste **11** after all 10 merge.

```powershell
cd "D:\project\Acleda Mobile App\prompt\Prompt Frontend\run-type-tokens"
.\open-terminals.ps1
```

## Hard rules (every prompt)

- Prefer `context.text.*` over inline `TextStyle(fontSize:, fontWeight:)`.
- **Same pixels** — do not snap sizes or restyle layouts.
- **Less code** — no `VitheyTitle` / `AppText` widgets; do not wrap every size in a new 5-line `TextStyle(VitheyType…)`.
- Colors: `AppColors` + `context.appColors` only. No new palette. Keep white/black on media overlays.
- Leave alone: PDF builders, fixtures hex, `GoogleMap`, generated files, business logic, routes.
- Do not edit another module’s folder (parallel safety).
- Do not touch `backend/`, `ai_core/`, or Prompt Al packs.

## Status (mark Done after each GLM chat)

| # | Prompt | Status |
|---|--------|--------|
| 0 | Tokens + theme + kit | Done 2026-09-06 |
| 1 | Auth | Done 2026-09-06 |
| 2 | Home | Done 2026-09-06 |
| 3 | Profile | Done 2026-09-06 |
| 4 | Jobs | Done 2026-09-06 |
| 5 | Finance | Done 2026-09-06 |
| 6 | Chat | Done 2026-09-06 |
| 7 | Chatbot | Done 2026-09-06 |
| 8 | Search | Done 2026-09-06 |
| 9 | Settings | Done 2026-09-06 |
| 10 | Map | Done 2026-09-06 |
| 11 | Sweep + completion | Done 2026-09-06 |

### Sweep result (Prompt 11)

Codemod (`vithey_app/tool/sweep_type_tokens.py`) converted the remaining inline
`TextStyle` blobs in `modules/**`, `core/widgets/**`, `core/alerts/**` to
`context.text.<role>?.copyWith(...)` — props carried verbatim, same pixels.
`dart analyze` clean repo-wide.

Remaining intentional exceptions:

- `copyWith(fontSize: …)` one-offs (9 / 11.5 / 12.5 / 15.5 / 17 / 24 / 26 / 28 …)
  — per DESIGN, no tokens for rare sizes.
- `jobs/ai_cv/templates/cv_pdf_builder.dart` + `cv_template_preview.dart` — PDF
  engine (`pw.FontWeight`) and template renderer with computed sizes (`_fs`).
- Reels / media fullscreen / call sheet / camera zones — white/black ink on
  photo-video overlays (kept as literals, incl. `w800` display titles).
- `chatbot` markdown `TextSpan` emphasis (bold/italic/link spans inherit size —
  forcing a role would change pixels).
- Kit param-driven styles: `VitheyTextLink` / `VitheySearchPill` `fontSize` /
  `fontWeight` params, `UserAvatar` `radius * 0.45`, `PackedSkillChipFlow`
  const `TextPainter` measurement style (tokenized via `VitheyType` /
  `VitheyWeight`).
- `in_app_message_banner.dart` bespoke banner surface `0xFF3A3A3C` / `0xFF111111`
  (distinct from `darkSurface` — kept for pixel fidelity).
- Emoji glyphs (`fontSize: 20 / 28 / 10`) converted to `bodyLarge.copyWith`;
  no token invented.

## Done means

- Light + dark `textTheme` wired from `VitheyType` / `VitheyWeight`
- Kit + all 10 modules use `context.text` for repeated type
- Near-zero leftover surface hex / `Colors.teal` (except documented overlays / PDF / fixtures)
- `dart analyze` clean on owned files
- UI looks unchanged
