# Plan — Shadcn-style reusable UI for every screen

**Status: Phases 0–6 complete.** Kit enforced across the live 10 modules; custom dialogs use `VitheyDialog`; snackbar actions use `VitheyTextLink`. See [`COMPONENT_KIT.md`](COMPONENT_KIT.md).
  
**Goal:** one Vithey look (Shadcn + brand teal) so every screen composes **shared adapters**, not one-off Material / raw `shad.*` widgets.

## 1. What we already have

| Layer | Today |
|-------|--------|
| Package | `shadcn_flutter: ^0.0.52` in `pubspec.yaml` |
| Theme | `GetMaterialApp` + `shad.Theme` in `lib/app.dart` (slate + **Vithey primary** overlay) |
| Tokens | `AppColors.primary` `#03B4AC`, `context.appColors.*` (light/dark) |
| Adapters | `CustomButton`, `CustomTextField` → `VitheyField`, `VitheyCard`, `VitheySearchPill`, `VitheyFilterChips`, `ConfirmDialog`, `UserAvatar`, `AppAppBar`, `StatusBadge`, empty/error/loading |

**Problem:** the kit is incomplete and **not enforced**.

- Many screens still use `ElevatedButton` / `TextButton` / `TextFormField` / Material `AlertDialog`
- Other screens import `shadcn_flutter` directly (`shad.Button`, `shad.AlertDialog`, `shad.Switch`, `shad.TextField`)
- Same pattern is copied (block/report dialogs in chat, profile, jobs)
- `VitheyFilterChips` still uses Material `FilterChip`
- `ConfirmDialog` is custom Material, not `shad.AlertDialog`

That is why the app does not feel like one standard.

## 2. The standard (rules)

```text
Screen  →  core/widgets (Vithey* adapters)  →  shadcn_flutter
                ↓
         context.appColors + AppColors.primary
```

1. **Feature screens never import `shadcn_flutter`.** Only `lib/core/widgets/` may wrap `shad.*`.
2. **Feature screens never use** `ElevatedButton`, `TextButton`, `OutlinedButton`, `TextFormField`, Material `AlertDialog`, `SwitchListTile` as the primary control.
3. **If a widget is used on 2+ screens, it lives in `core/widgets/`.** Screen-only chrome stays in `modules/<feature>/widgets/`.
4. **Tokens only:** `context.appColors`, `AppColors.primary`, `Theme.of(context)`. No `Colors.teal`, no `0xFF00BFA5`, no random `Colors.white` on surfaces (use `cardSurface` / `bodyBackground`).
5. **Keep GetX.** Do not replace routing or state with Shadcn desktop patterns.
6. **Do not restyle Google Maps, `video_player`, PDF viewer, or Lottie.** Those stay native. Only the chrome around them (buttons, sheets, chips) uses the kit.
7. **Do not invent a second palette.** Shadcn slate + Vithey teal is the brand.

### Allowed raw Flutter

`Scaffold`, `ListView`, `Column`, `Row`, `Padding`, `SafeArea`, `Image`, `Hero`, `GoogleMap`, `VideoPlayer`, `CustomPaint` (wave), `RefreshIndicator`. Layout is not “a component.”

## 3. Kit to finish (reusable catalog)

Build / finish these **once**. Then every screen only composes them.

| Adapter | Wraps | Use on |
|---------|--------|--------|
| `CustomButton` | `shad.Button` primary/secondary/outline | Every submit / CTA |
| **Add** `CustomButton.ghost` + **destructive** | `shad.Button.ghost` / `.destructive` | Skip, cancel, delete |
| `VitheyField` / `CustomTextField` | `shad.TextField` | Login, settings, comments, apply |
| `VitheySearchPill` | `shad.TextField` pill | Home, Search, Map, Chat |
| `VitheyCard` / `VitheyInfoCard` | `shad.Card` | Settings, finance, job context |
| **Add** `VitheySwitch` | `shad.Switch` | Settings, privacy, security, notif prefs |
| **Upgrade** `showConfirmDialog` | `shad.AlertDialog` + `CustomButton` | Logout, block, delete, accept/reject |
| **Add** `VitheyActionSheet` | `shad` / themed modal sheet | Post menu, notification row, search result |
| **Upgrade** `VitheyFilterChips` | Shadcn chip or styled `FilterChip` via tokens | Map, Search, Home, Finance |
| `UserAvatar` | keep | Feed, chat, comments, profile |
| `AppAppBar` | keep; icon actions = ghost buttons | Inner screens |
| `StatusBadge` | keep | Finance, applications, chat |
| `EmptyStateWidget` / `AppErrorWidget` / `LoadingWidget` / `ShimmerListTile` | keep | All lists |
| `SectionHeader` | keep | Settings groups, profile, search |
| **Add** `VitheyListTile` | card row + chevron | Settings home, help, about |
| **Add** `VitheyTextArea` | `VitheyField(maxLines: n)` alias | Create post, report, chatbot (if needed) |

**Do not add** a new `VitheyButton` name. Extend `CustomButton` so existing call sites stay valid.

Export everything from `lib/core/widgets/widgets.dart`. Screens import that barrel.

## 4. Screen map (10 modules)

Use the collapsed module tree. Each row = “compose these adapters; no new button style.”

| Module | Screens | Kit to use |
|--------|---------|------------|
| **auth** | Splash, language, onboarding, login/register, forgot password, startup, Google coming-soon | `AppLogo`, wave bg, `CustomButton`, `VitheyField`, ghost Skip/Back |
| **home** | Shell, feed, create post, post detail, reels, notifications | `AppAppBar`, `UserAvatar`, `CustomButton`, `VitheyField` (comment), `VitheyActionSheet`, `EmptyState` / shimmer |
| **profile** | Profile, edit, applicants, applicant detail, CV preview | `UserAvatar`, `VitheyCard`, `CustomButton`, `showConfirmDialog` (accept/reject), `StatusBadge` |
| **jobs** | Apply CV, success, application status | `CustomButton`, `VitheyField`, `VitheyCard`, `StatusBadge`, upload zone stays module widget |
| **finance** | Home, payment, verification, status | `VitheyCard`, `StatusBadge`, `CustomButton`, `EmptyState` |
| **chat** | List, detail, profile | `VitheySearchPill`, `UserAvatar`, `showConfirmDialog` (block/report — **one** helper), composer = `VitheyField` |
| **chatbot** | Chat + history drawer | `CustomButton` outline chips, `showConfirmDialog` (delete session), keep markdown |
| **search** | Search, see all | `VitheySearchPill`, `VitheyFilterChips`, `SectionHeader`, `UserAvatar` |
| **settings** | Home, account, privacy, security, password, notif prefs, help, about | `VitheyListTile`, `VitheySwitch`, `VitheyField`, `VitheyCard`, `showConfirmDialog` (logout) |
| **map** | Map, add place | `VitheySearchPill`, `VitheyFilterChips`, `CustomButton`, place sheet = `VitheyCard` + buttons. **Map canvas stays GoogleMap** |

Startup chips (`SelectableSkillChip`, interest cards) stay **module widgets** (used only on startup). Style them with `AppColors` / `VitheyCard`, do not force them into core.

## 5. Phases (do in this order)

Do **not** restyle all 60+ screens in one chat. Each phase must still run on the device (`flutter run` is already up).

### Phase 0 — Kit (1 chat)

Finish adapters in `lib/core/widgets/` only.

- Add `ghost` + `destructive` to `CustomButton`
- Add `VitheySwitch`, `VitheyListTile`, `VitheyActionSheet`
- Point `showConfirmDialog` at `shad.AlertDialog` (same `Future<bool?>` API)
- Rebuild `VitheyFilterChips` on brand tokens (optional Shadcn chip)
- Export from `widgets.dart`
- Add a short `prompt/Prompt Frontend/COMPONENT_KIT.md` table (name → when to use)

**Stop when:** no new screen work; `dart analyze` on `core/widgets` is clean.

### Phase 1 — Settings + Auth (highest form density)

Replace Material / raw shad in:

- `modules/settings/**`
- `modules/auth/**` (login, forgot, startup bottom nav, oauth button)

Use kit only. Keep wave background. Google OAuth stays “coming soon.”

### Phase 2 — Home + Search + Notifications

Feed chrome, comment field, notification action sheet, search bar/chips. Do not redesign post cards from scratch — only swap buttons/fields/dialogs.

### Phase 3 — Profile + Jobs + Finance

Accept/reject dialogs → `showConfirmDialog`. Apply/status CTAs → `CustomButton`. Finance cards → `VitheyCard` + `StatusBadge`.

### Phase 4 — Chat + Chatbot + Map

One block/report dialog helper. Chatbot chips → `CustomButton.outline`. Map search/filters already have pills/chips — route them through the kit; do not touch GoogleMap.

### Phase 5 — Sweep

- `rg "import 'package:shadcn_flutter"` under `lib/modules/` → should be **zero** (or only a documented exception)
- `rg "ElevatedButton|TextFormField|AlertDialog\\("` under `lib/modules/` → zero for those types
- Light + dark check on: Login, Settings home, Home feed, Chat detail, Map, Finance

## 6. What this is not

| Out of scope | Why |
|--------------|-----|
| New color palette / “GenZ rebrand” | Brand is already teal `#03B4AC` |
| Replacing GetX or folder collapse | Already 10 modules |
| Building map-service / backend | Separate `Prompt Backend/run-glm-flash` |
| Pixel-perfect clone of shadcn.dev desktop | Mobile + Vithey radius 16–24, 48px tap targets |
| Rewriting post/reel video UI | Media widgets stay specialized |

## 7. How to run later (GLM)

Copy-paste pack (one new GLM chat per file, **in order**): [`run-shadcn-standard/README.md`](run-shadcn-standard/README.md)

| Chat | Prompt |
|------|--------|
| 0 | [`run-shadcn-standard/00-kit.md`](run-shadcn-standard/00-kit.md) |
| 1 | [`run-shadcn-standard/01-settings-auth.md`](run-shadcn-standard/01-settings-auth.md) |
| 2 | [`run-shadcn-standard/02-home-search-notification.md`](run-shadcn-standard/02-home-search-notification.md) |
| 3 | [`run-shadcn-standard/03-profile-jobs-finance.md`](run-shadcn-standard/03-profile-jobs-finance.md) |
| 4 | [`run-shadcn-standard/04-chat-chatbot-map.md`](run-shadcn-standard/04-chat-chatbot-map.md) |
| 5 | [`run-shadcn-standard/05-sweep.md`](run-shadcn-standard/05-sweep.md) |

Do **not** open 10 UI terminals that all edit `custom_button.dart` at once. Kit first, then screens.

## 8. Definition of done (whole app)

- Every CTA/field/switch/dialog on product screens goes through `core/widgets`
- Light and dark both use `context.appColors`
- New screens in `COMMON_CONTEXT.md` / kickoff already say: compose kit, do not invent buttons
- Flutter analyze has no new issues from the migration
- App still builds; Map / Reels / PDF still work

## Approve to start

Start with **Phase 0 only** (the kit). Then Phase 1 on Settings + Auth so you can see the standard on real forms before touching the feed.
