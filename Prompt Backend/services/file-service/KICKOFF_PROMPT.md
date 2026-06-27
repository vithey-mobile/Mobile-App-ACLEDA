# File Service — Kickoff Prompt

Build the **File Service** — media upload to MinIO for CV, avatar, poster, and video files.

## Read First
1. `../../COMMON_CONTEXT.md` → 2. `COMMON_CONTEXT.md` → 3. `SERVICE_PROMPT.md`

## Port
**8083** | Storage: **MinIO** (no PostgreSQL required; optional metadata DB)

## Rules
- All file bytes go to MinIO — never store files on local disk in production.
- Return public/signed URLs for other services to reference.
