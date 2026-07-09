# Prompt Frontend — Vithey App (Flutter)

All Flutter AI prompts and the **frontend↔backend API contract** live here.

## Start

1. Read `KICKOFF_PROMPT.md`
2. Read `COMMON_CONTEXT.md`
3. Read `api-intergration/integration-contract.md`
4. Run `Screen prompt/00-foundation-prompt.md`, then follow `Screen prompt/README.md`

## UI / Component System

This project uses a **Shadcn Flutter–style design system**: screens must be composed using shared components + theme tokens.

- Shared components: `vithey_app/lib/core/widgets/`
- Theme + semantic tokens: `vithey_app/lib/core/theme/` (especially `app_semantic_colors.dart`)

If `shadcn_ui` or `shadcn_flutter` is installed in `vithey_app/pubspec.yaml`, those widgets may be used too, but do not break the GetX module architecture.

## Folder map

| File / folder | Purpose |
|---------------|---------|
| `KICKOFF_PROMPT.md` | Kickoff rules and screen execution order |
| `COMMON_CONTEXT.md` | Architecture, packages, GetX patterns |
| `Folder_Stucture_flutter.md` | Full `vithey_app/lib/` tree |
| `00-project-summary.md` | Product features and user journeys |
| `01-navigation-and-flow.md` | Routes, navigation table, mermaid flow |
| `02-ai-implementation-guide.md` | Full-stack build phases |
| `api-intergration/README.md` | API integration prompt index |
| `api-intergration/integration-contract.md` | **Single source of truth for API** |
| `api-intergration/api-overview.md` | Endpoint index |
| `Screen prompt/` | **All Flutter screen prompts**, organized by feature flow |

## Output

Build generates `vithey_app/` at repo root (or sibling folder) with `pubspec.yaml` name `aub_connect_app`.

## Master prompt

Use `MASTER_AI_PROMPT.md` at repo root — set `TASK:` to any `Screen prompt/**/*.md` file.
