# Documentation Conventions

> Status: Active · Last reviewed: 2026-09-30

Apply these to every document in the `docs/` package (the numbered `00-*` … `20-*` folders). Do not modify the existing `docs/Prompt *` and `docs/_shared` folders — they are preserved reference material.

## 1. Header block

Every document starts with a short blockquote status line, e.g.:

```
> Status: Verified / Partially complete / Requires confirmation · Last reviewed: 2026-09-30
> Evidence: <repo paths>
```

## 2. Evidence tags

Tag non-obvious claims inline:

- `[VERIFIED]` — supported by a cited path.
- `[INFERRED]` — inferred; append the phrase `Inferred from implementation — requires business confirmation.`
- `[PLANNED]` — in plans/prompts only.
- `[TBD]` — write `TBD — Requires confirmation.` and state exactly what is needed.

Never claim a test passed, a deployment happened, UAT occurred, or a security review occurred without evidence. Test files existing ≠ tests passing.

## 3. Structure quality

- Use real headings, tables, and code fences.
- Prefer concrete file paths, commands, and config examples from the repo.
- If a topic is covered deeply elsewhere, summarise (3–6 lines) and link to the detailed doc with a relative link.
- No empty placeholders: a document with limited evidence must still contain verified content plus explicit TBDs.
- Keep each document focused; avoid copy-paste duplication across documents.

## 4. Diagrams

Use Mermaid fenced as ` ```mermaid `. Valid, minimal syntax:
- Architecture: `flowchart LR` / `graph TD`
- Flows over time: `sequenceDiagram`
- Data model: `erDiagram`
- Deployment: `flowchart`
Keep node ids simple (no spaces/special chars). Verify it parses mentally before saving.

## 5. Naming and terminology (use EXACTLY these)

- Product: **Vithey**. Backend aggregate: **Vithey backend**. AI engine: **ai_core** (Python, package `vithey_ai`).
- Services: `api-gateway`, `auth-service`, `user-profile-service`, `file-service`, `content-service`, `career-service`, `finance-service`, `chat-service`, `notification-service`, `map-service`, `eureka-server`, `config-server`.
- Databases: `auth_db`, `user_db`, `file_db`, `content_db`, `career_db`, `finance_db`, `chat_db`, `notification_db`, `map_db`, `ai_db`.
- Roles: `USER`, `STUDENT`, `COMPANY`, `ADMIN`.
- JSON is snake_case; list responses use `page`/`limit` + `meta`; AI envelope is `{data, meta, error}`.

## 6. Secrets

Environment variable NAMES only. Never a value. Use `<REDACTED>` if a value is unavoidable. Never copy from a real `.env`.

## 7. Status vocabulary (use consistently)

Feature status: `Implemented`, `Partial`, `Stub/Placeholder`, `Planned`, `Not started`, `Deprecated/Retired`.
Environment status: `Local development (verified)`, `Local demo (verified)`, `Staging (does not exist)`, `Production (does not exist)`.
Governance: `Not yet formally assessed`, `Not yet executed`, `Requires confirmation`.

## 8. Cross-linking

Link to the master index: `../00-project-overview/07-document-index.md`. Use relative paths. Prefer linking up to categories rather than duplicating content.

## 9. Requirement IDs

Use `FR-<MODULE>-NNN` and `NFR-<AREA>-NNN` (e.g. `FR-AUTH-001`, `NFR-SEC-001`). Only mark a requirement `Verified` when a file path + endpoint/entity evidence is cited.
