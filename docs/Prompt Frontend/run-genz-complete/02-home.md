# GLM 5.3 Flash — Prompt 02 — Home (GenZ)

Copy everything below `---` into a **new** chat. Run after Prompt 00. Parallel OK with 01, 03–10.

---

You are a Flutter UI agent. Restyle **home module only** to GenZ smart screens.

## Read

`prompt/Prompt Frontend/run-genz-complete/DESIGN_SYSTEM.md`

## Own only

```text
vithey_app/lib/modules/home/**
```

## Screens / areas

Main shell / tab chrome touchpoints in home, Home feed, Reels, Create Post, Post Detail, Notifications, home widgets (job poster card, share/comment sheets chrome).

## Requirements

1. Header action icons (search, chat, map, notifications) use rounder `VitheyIconButton` chrome + primary wash.
2. Feed cards / job poster cards: radius `VitheyRadii.card`, softer borders via `context.appColors`.
3. Bottom sheets / action sheets: prefer `showVitheyActionSheet` / kit; radius 24.
4. Notification list: pill filters via `VitheyFilterChips`; cards radius ≥ 16; icon badges rounder.
5. Create Post / Post Detail: kit fields + buttons; media corners `VitheyRadii.media`.
6. Reels controls: larger circular icon hit targets (48).
7. Empty / error / loading use kit widgets.
8. Do not break Apply / video playback / follow / react logic.

## Do not

- Edit `modules/search` or `modules/map` (only home entry icons)
- Redesign tab bar in a different module if shell lives only here — OK to touch `home/shell`

## Stop when

Home family is GenZ-consistent; analyze clean on owned files.
