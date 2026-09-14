# GLM 5.3 Flash — Prompt 09 — Settings (GenZ)

Copy everything below `---` into a **new** chat. Run after Prompt 00. Parallel OK with other modules.

---

You are a Flutter UI agent. Restyle **settings module only** to GenZ smart screens.

## Own only

```text
vithey_app/lib/modules/settings/**
```

## Screens

Settings home, Account, Privacy, Notifications prefs, Security, Change password, Help, About.

## Requirements

1. Rows → `VitheyListTile` / `VitheyCard` groups; radius 18.
2. Switches → `VitheySwitch`.
3. Leading icons → soft squircle chrome (16–18 radius).
4. Destructive logout → `CustomButton.destructive` or confirm dialog destructive.
5. 2FA / biometric stay Coming soon with disabled GenZ styling.
6. Forms → `VitheyField` + `CustomButton`.
7. Dark mode OK.

## Stop when

Settings GenZ-consistent; analyze clean.
