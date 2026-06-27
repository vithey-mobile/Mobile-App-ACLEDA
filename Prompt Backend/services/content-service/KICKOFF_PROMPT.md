# Content Service — Kickoff Prompt

Build the **Content Service** — posts, comments, reactions, mentions, and follows.

## Read First
1. `../../COMMON_CONTEXT.md` → 2. `COMMON_CONTEXT.md` → 3. `SERVICE_PROMPT.md`

## Port
**8084** | Database: **content_db**

## Rules
- Post media URLs come from File Service — store references only.
- Publish events for Notification Service on like, comment, mention, follow.
