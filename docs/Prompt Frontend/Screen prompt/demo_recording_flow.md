# Vithey App — Recording Demo Screen Flow

Use this as the **shot list / screen order** when recording a product demo.
Run the app with **mock API** (`USE_MOCK_API=true`) on an Android emulator or device.

**Target length:** ~6–8 minutes (full walkthrough) · ~3 minutes (highlight cut)

---

## Prep before record

| Check | Detail |
|-------|--------|
| Branch | `molika` (synced with latest shared base) |
| Mode | Mock API on |
| Fresh start | Hot restart so splash → home is clean |
| Account | Use mock Google / email login that lands on Home |
| Avoid | Already-applied jobs if you need Apply CV; clear mock apply state or pick an open job |
| Audio | Quiet room; speak short labels per screen (“Home feed”, “Apply CV”) |

---

## Flow A — Full demo (recommended)

### Act 1 · First launch & auth (~45s)

| # | Screen | Action on camera | Speak / show |
|---|--------|------------------|--------------|
| 1 | Splash | Let logo animate, wait for next | App identity |
| 2 | Select Language | Tap English (or Khmer once, then back to EN) | Localization |
| 3 | Onboarding | Swipe 1–2 pages → Continue / Skip | Value props |
| 4 | Auth / Login | Sign in with mock Google or email | Entry |
| 5 | Startup (skills / interests) | Skip or tap Next quickly if shown | Personalization |

**Cut to:** Home shell.

### Act 2 · Home & media (~90s)

| # | Screen | Action on camera | Speak / show |
|---|--------|------------------|--------------|
| 6 | Home feed | Scroll mixed Poster / Video / Job cards | Social + campus feed |
| 7 | React | Tap like on one post | Engagement |
| 8 | Comments | Open comment sheet → type short reply → send | Threaded comments |
| 9 | Post Detail | Open a poster → scroll comments → back | Detail layout |
| 10 | Create Post | Bottom tab Create → write caption → optional photo → Post | Composer (create style) |
| 11 | Own post menu | On own post → ⋮ → Edit briefly → Save (or cancel) | Edit own content |
| 12 | Reels | Switch to Reels tab → swipe 1–2 reels | Short video |

### Act 3 · Jobs & apply (~90s)

| # | Screen | Action on camera | Speak / show |
|---|--------|------------------|--------------|
| 13 | Job card | Find open job → tap **Apply** | Career entry |
| 14 | Apply · Upload CV | Show auto Position → pick / use CV → Continue | Step 1 |
| 15 | Apply · Review | File card + What happens next → Submit | Step 2 |
| 16 | Application Submitted | Success hero → View Application Status | Confirmation |
| 17 | Application Status | Show timeline (Submitted / Under review) | Tracking |

### Act 4 · Discover & connect (~60s)

| # | Screen | Action on camera | Speak / show |
|---|--------|------------------|--------------|
| 18 | Search | Open search → type name/query → recent + pin | Discovery |
| 19 | Profile (other) | Open author from feed → Follow | Social graph |
| 20 | Chat | Chat tab → open thread → send one message | Messaging |
| 21 | Vithey AI | Chatbot → ask one campus/career question | AI assistant |

### Act 5 · Profile, finance, settings (~75s)

| # | Screen | Action on camera | Speak / show |
|---|--------|------------------|--------------|
| 22 | Own Profile | Profile tab → reels/posters/jobs | Personal hub |
| 23 | QR | Show QR / Scan QR briefly | Campus identity |
| 24 | Finance | Open Finance → show fee / pay entry (mock) | Student finance |
| 25 | Map | Open Map → pan / one place pin | Nearby campus |
| 26 | Notifications | Open notifications list | Activity |
| 27 | Settings | Account / Privacy / Security peek → back | Control & trust |

**End on:** Home feed (branded close).

---

## Flow B — Short highlight (~3 min)

Use only these shots, in order:

1. Splash → Login (fast)
2. Home scroll + like + comment
3. Create Post → publish
4. Job Apply → Upload → Review → Success
5. Search + Chat one message
6. Profile + Settings home
7. Back to Home

---

## Flow C · Job-only deep demo (~2 min)

1. Home → Job card Apply  
2. Upload CV (auto position)  
3. Review + Submit  
4. Success + Status  
5. Poster side (optional): Profile → Job → Applicants list  

---

## Screen → route cheat sheet

| Demo beat | Route / entry |
|-----------|----------------|
| Splash | `AppRoutes.splash` |
| Language | `AppRoutes.selectLanguage` |
| Onboarding | `AppRoutes.onboarding` |
| Login | `AppRoutes.auth` / `login` |
| Home | `AppRoutes.home` |
| Reels | `AppRoutes.reels` |
| Create | `AppRoutes.createPost` |
| Post detail | `AppRoutes.postDetail` |
| Apply CV | `AppRoutes.applyCv` |
| Apply success | `AppRoutes.applySuccess` |
| Apply status | `AppRoutes.applicationStatus` |
| Search | `AppRoutes.search` |
| Profile | `AppRoutes.profile` |
| Chat | `AppRoutes.chat` |
| Chatbot | `AppRoutes.chatbot` |
| Finance | `AppRoutes.finance` |
| Map | `AppRoutes.map` |
| Notifications | `AppRoutes.notifications` |
| Settings | `AppRoutes.settings` |

---

## Recording tips

- Hold each screen **2–4 seconds** after the action lands.
- Prefer **portrait** 1080×1920; hide system debug banners if possible.
- If Apply shows “Already Submitted”, pick another job or restart mock state.
- Do not show real passwords, tokens, or production URLs.
- After cut, export: full take + 30s teaser (Home → Apply Success).

---

## Acceptance (demo package)

- [ ] Full Flow A recorded once without crashes  
- [ ] Apply path reaches Success (not Already Submitted)  
- [ ] Create Post appears on Home  
- [ ] Chat or AI shows one successful reply  
- [ ] Ends on Home with readable UI  
