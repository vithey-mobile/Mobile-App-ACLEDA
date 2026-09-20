# Auth Sign In / Sign Up — Background Alignment Prompt

> **Branch context:** last `ayheng` commit before this work: `688669d` (Settings UI update).  
> **This file is an implementation prompt only.** Do not treat it as as-built docs.  
> **No code in this file.** Implement in a later step from this prompt.

---

## Goal

Update **Authentication Sign In** and **Sign Up** so their **background style matches Language and Onboarding**.

Keep all auth **content** (forms, fields, buttons, links, labels, validation UI, Google / social row, toggles between Sign In and Sign Up). Only the **background / chrome around that content** changes.

Language, Onboarding, and Auth should feel like **three screens of one visual family**: same background language; **different content only**.

**Morph transitions are required.** Language ↔ Onboarding morph is already complete — Auth must join that same morph system when moving **to Auth** and **back** (especially Onboarding ↔ Auth Sign In / Sign Up). The background must animate continuously; it must not hard-cut or jump to a different chrome model.

---

## Source of truth (do not edit these)

Use these as the visual / structural reference. **Do not modify them.**

| Screen                       | Role                                           |
| ---------------------------- | ---------------------------------------------- |
| **Onboarding**               | Canonical mixed teal + white wave background   |
| **Select Language**          | Same background family as Onboarding           |
| **Auth (Sign In / Sign Up)** | **Target** — adopt that background; keep forms |

Canonical implementation to **reuse / follow** (read-only for this task):

- Onboarding background (wave layers, teal + white mix)
- Select Language screen layout that sits on that background

Prompts / code for Language and Onboarding are **out of scope** for edits.

---

## Current Auth problem (what to remove)

Auth today is **not** the same concept as Language / Onboarding:

| Auth (current)                              | Language / Onboarding (desired concept)               |
| ------------------------------------------- | ----------------------------------------------------- |
| One full-bleed background                   | Mixed teal + white wave background as the page itself |
| **White container overlay** on top          | **No** white overlay card / sheet container           |
| Content lives **inside** that white overlay | Content sits **directly** on the mixed background     |

**What to do:** remove the Auth white overlay / sheet-container approach for Sign In and Sign Up.

**What to keep:** every Sign In / Sign Up content element that already exists (inputs, CTAs, helper text, links, icons inside the form area, etc.).

---

## What TO DO

1. **Align Auth background with Onboarding + Language**
   - Same visual system: layered teal / light-teal / white waves (or whatever the shared Onboarding/Language background already is).
   - Sign In and Sign Up share **one** Auth background treatment (same style on both panels / modes).
   - Prefer **reusing** the existing Onboarding/Language background widget(s) rather than inventing a new Auth-only wave.

2. **Remove Auth’s white overlay container**
   - No full-width white card / morphing white sheet / floating white panel that frames the entire form.
   - Content should read as sitting on the mixed background, like Language and Onboarding.

3. **Preserve Auth content**
   - Sign In: email, password, forgot password, primary Sign In, “Sign in with”, Google (and related), “Don’t have an account? / Sign Up”, etc.
   - Sign Up: all existing fields, primary CTA, switch to Sign In, etc.
   - Do not delete, rename, or redesign the product copy unless needed for layout fit on the new background.
   - Do not change auth business logic, validation rules, navigation targets, or controllers beyond what layout wiring requires.

4. **Same family, different content**
   - Language → language picker content
   - Onboarding → slides / CTA content
   - Auth → Sign In / Sign Up forms  
     Background style stays consistent across all three.

5. **Both Sign In and Sign Up**
   - Apply the background change to **both**. Switching Sign In ↔ Sign Up must keep the same background concept (only content morphs / swaps).

6. **Morph transition (same as Language ↔ Onboarding)**
   - Language ↔ Onboarding morph is **done** — treat it as the reference behavior (wave factor / shared background continuous morph; content crossfades or reveals on the entering screen).
   - Auth must support the **same kind of morph** when:
     - **Onboarding → Auth** (Sign In / Sign Up)
     - **Auth → Onboarding** (back / leave Auth toward intro)
     - And any other intro path that already morphs into Auth (e.g. if Language can reach Auth through Onboarding, the chain must stay seamless).
   - Forward and back must both feel continuous: waves stay in the **same mixed teal + white family**; do **not** morph Auth into a solid-teal-only full screen or into the old white overlay sheet.
   - Prefer the existing intro morph / handoff pattern (entering screen drives the animation; leaving screen does not reinvent a second system).
   - Auth resting state after morph must match Language / Onboarding resting background style (not a different end-state).
   - **Constraint:** do not rewrite Language or Onboarding morph logic. Wire Auth to **participate** in the existing handoff (flags, factors, shared background) so those screens stay unchanged while Auth enters/exits correctly.

---

## What NOT TO DO

- **Do not change Language** (UI, layout, background, assets, prompts).
- **Do not change Onboarding** (UI, layout, background, assets, prompts).
- **Do not remove** Sign In / Sign Up content: forms, buttons, texts, links, icons that belong to the forms.
- **Do not** replace Auth with a Language or Onboarding screen; only borrow their **background style**.
- **Do not** reintroduce a dominant white overlay container as the main Auth chrome.
- **Do not** replace the Language ↔ Onboarding morph with a new unrelated transition system on Auth (hard cuts, fade-only route changes, or Auth-only solid teal morph that breaks visual continuity).
- **Do not** expand scope to Forgot Password / Reset / Google-only screens unless those screens currently share the same Auth shell background — if they share the shell, keep them consistent; if separate, leave them unless required for a shared shell.

---

## Concept note (must follow)

```
Language / Onboarding
┌──────────────────────────────────────┐
│  Mixed teal + white wave BACKGROUND  │
│  (page itself — no white overlay)    │
│                                      │
│        Content on that surface       │
└──────────────────────────────────────┘

Auth (target)
┌──────────────────────────────────────┐
│  SAME mixed teal + white BACKGROUND  │
│  (no white overlay container)        │
│                                      │
│   Sign In / Sign Up content kept     │
└──────────────────────────────────────┘

Auth (current — remove this model)
┌──────────────────────────────────────┐
│           Base background            │
│   ┌──────────────────────────────┐   │
│   │  WHITE OVERLAY CONTAINER     │   │
│   │  (forms live only inside)    │   │
│   └──────────────────────────────┘   │
└──────────────────────────────────────┘
```

Follow the **Onboarding and Language** concept: background is the mixed color surface; content is placed on it without a separate white container wrapping the whole form.

### Morph continuity

```
Language  ←morph→  Onboarding  ←morph→  Auth (Sign In / Sign Up)
   ^                    ^                        ^
   |                    |                        |
   already done         already done             must match that morph
```

- Same shared wave background parameters morph between screens.
- Content of the destination screen reveals while the background eases.
- Going **back** from Auth to Onboarding uses the same morph family in reverse (or the entering-screen morph pattern already used by intro).
- Result: user never sees Auth “snap” to a different background language than Language / Onboarding.

---

## Layout / readability guidance

- Keep text and fields readable on teal / wave areas (contrast). If a local soft surface is needed for a single field cluster, it must **not** recreate the old full-screen white overlay sheet.
- Logo / header treatment should feel consistent with Language / Onboarding (e.g. shared logo widget), without rewriting those screens.
- Light / dark: follow how Onboarding / Language already handle theme; do not invent a third theme language.

---

## Scope checklist

| In scope                                     | Out of scope                             |
| -------------------------------------------- | ---------------------------------------- |
| Auth Sign In background                      | Editing Language module / morph          |
| Auth Sign Up background                      | Editing Onboarding module / morph        |
| Removing Auth white overlay chrome           | Rewriting auth API / validation / routes |
| Reusing Onboarding/Language background style | New marketing copy for auth              |
| Auth join of existing intro morph handoffs   | Unrelated Settings / Home work           |
| Keeping existing form content                | Breaking Language ↔ Onboarding morph     |

---

## Acceptance criteria

- [ ] Sign In uses the same background **style** as Language and Onboarding (mixed teal + white; no full white overlay container).
- [ ] Sign Up uses the same background **style** as Sign In / Language / Onboarding.
- [ ] All previous Sign In / Sign Up content remains present and usable.
- [ ] Language screen is **unchanged**.
- [ ] Onboarding screen is **unchanged**.
- [ ] Switching Sign In ↔ Sign Up does not fall back to the old white-container Auth chrome.
- [ ] **Onboarding → Auth** uses a continuous morph (same family as Language ↔ Onboarding); no hard cut.
- [ ] **Auth → Onboarding** (back) uses the same morph continuity; no hard cut / wrong end background.
- [ ] Auth resting background after morph matches Language / Onboarding style (not solid-teal-only or white overlay).
- [ ] No regressions to auth flows (submit, validation errors, Google entry, navigation).

---

## Implementation reminder (for the coding agent)

1. Read Onboarding + Select Language background widgets **and** their morph / intro handoff first (Language ↔ Onboarding is the reference).
2. Point Auth shell at that shared background (prefer reuse over fork).
3. Strip Auth white overlay / sheet wrapper.
4. Re-seat existing Sign In / Sign Up widgets on the new surface.
5. Wire Auth into the existing morph handoff for **enter Auth** and **leave Auth → Onboarding** without editing Language/Onboarding screens.
6. Verify forward + back morphs; verify Sign In ↔ Sign Up content still works.

**Deliverable of this file:** the prompt above.  
**Not in this step:** writing or changing application code.

- if anyfiles is changed and not used again, remove them.
