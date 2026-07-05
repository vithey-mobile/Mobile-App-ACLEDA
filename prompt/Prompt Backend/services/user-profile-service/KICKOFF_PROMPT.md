# User Profile Service — Kickoff Prompt

Build the **User/Profile Service** — profiles, avatars, bios, social links, and user settings.

## Read First
1. `../../COMMON_CONTEXT.md` → 2. `COMMON_CONTEXT.md` → 3. `SERVICE_PROMPT.md`

## Port
**8082** | Database: **user_db**

## Rules
- Listens to `user.registered` from Auth Service to create profile.
- Avatar file stored via File Service — store URL only.
