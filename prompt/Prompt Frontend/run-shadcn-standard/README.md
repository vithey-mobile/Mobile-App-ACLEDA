# GLM 5.3 Flash — Shadcn standard (6 chats)

Copy-paste prompts to make every screen use the **same reusable kit**. Plan: [`../SHADCN_STANDARD_PLAN.md`](../SHADCN_STANDARD_PLAN.md)

**Run in order. One new chat per file. Do not run these 6 in parallel** — they all depend on Phase 0 widgets.

| # | File | Scope |
|---|------|--------|
| 0 | [`00-kit.md`](00-kit.md) | `lib/core/widgets/` only |
| 1 | [`01-settings-auth.md`](01-settings-auth.md) | Settings + Auth |
| 2 | [`02-home-search-notification.md`](02-home-search-notification.md) | Home, Search, Notifications |
| 3 | [`03-profile-jobs-finance.md`](03-profile-jobs-finance.md) | Profile, Jobs, Finance |
| 4 | [`04-chat-chatbot-map.md`](04-chat-chatbot-map.md) | Chat, Chatbot, Map chrome |
| 5 | [`05-sweep.md`](05-sweep.md) | Zero raw Material CTAs / zero `shadcn` imports in modules |
| 6 | [`06-finish-leftovers.md`](06-finish-leftovers.md) | `VitheyDialog` + snackbar links + docs |

## How

1. Open a **new** GLM / Cursor Agent chat.
2. Copy **everything below the `---` line** in that file.
3. Merge. Then open the next chat.

Do **not** touch backend. Do **not** move the 10 module folders. Do **not** invent a new color palette.

## Current status (2026-09-05)

| Phase | Status |
|-------|--------|
| 0 Kit | **Done** |
| 1 Settings + Auth | **Done** |
| 2 Home + Search + Notification | **Done** |
| 3 Profile + Jobs + Finance | **Done** |
| 4 Chat + Chatbot + Map chrome | **Done** (`GoogleMap` stays) |
| 5 Sweep | **Done** |
| 6 Finish leftovers | **Done** — `VitheyDialog`, snackbar `VitheyTextLink`, docs complete |
