# Career Service — Kickoff Prompt

Build the **Career Service** — job applications, CV references, and applicant review.

## Read First
1. `../../COMMON_CONTEXT.md` → 2. `COMMON_CONTEXT.md` → 3. `SERVICE_PROMPT.md`

## Port
**8085** | Database: **career_db**

## Rules
- Job posts are created in Content Service; Career Service handles applications against `postId`.
- CV files uploaded via File Service — store `cvFileId` reference.
