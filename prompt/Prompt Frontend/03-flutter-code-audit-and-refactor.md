# Flutter Code Audit and Reusable-Widget Refactor Prompt

Use this prompt to review and improve the existing Flutter app in
`vithey_app/`. This is an **existing-code refactor**, not a request to rebuild
the app or redesign its screens.

## Role

Act as a senior Flutter engineer. Audit the entire Flutter project, explain the
evidence you find, and then refactor it in small, verifiable batches.

Preserve the current UX, navigation, API contracts, GetX architecture, and all
working behavior unless a change is required to fix a confirmed defect.

## Read first

1. `Prompt Frontend/KICKOFF_PROMPT.md`
2. `Prompt Frontend/COMMON_CONTEXT.md`
3. `Prompt Frontend/api-intergration/integration-contract.md`
4. `Prompt Frontend/01-navigation-and-flow.md`
5. `vithey_app/pubspec.yaml`
6. `vithey_app/analysis_options.yaml`
7. The relevant feature prompt before changing that feature

Treat the code in `vithey_app/` as the implementation source of truth when a
prompt describes an older file name or structure. Report documentation drift;
do not force working code back into an obsolete structure.

## Main goals

1. Make repeated UI reusable without creating overly generic widgets.
2. Remove harmful hard-coded values from screens and business logic.
3. Separate UI, state, domain logic, repositories, and services correctly.
4. Remove code, imports, assets, and dependencies that are proven unused.
5. Keep the app runnable and behaviorally equivalent after every batch.
6. Leave `flutter analyze` with zero errors and zero warnings. Resolve relevant
   info-level findings when safe.

## Non-negotiable safety rules

- Inspect before editing. Do not rewrite the app from scratch.
- Preserve unrelated and uncommitted user changes.
- Never delete a file, asset, route, dependency, or public API based only on
  its name or one text search.
- Prove an item is unused through analyzer output, import/reference searches,
  route and binding inspection, asset registration, platform configuration,
  generated-code relationships, and tests where applicable.
- Do not manually edit or delete generated files such as `*.g.dart`.
- Do not apply `dart fix --apply`, mass formatting, or bulk replacements before
  reviewing the proposed changes and limiting their scope.
- Do not add packages when the current SDK or an existing dependency is enough.
- Do not change backend code or API payloads during this frontend refactor.
- Do not hide analyzer findings with broad `ignore` rules. Fix the cause unless
  a narrow suppression is documented and justified.

## What “no hard-coding” means

Hard-coding is harmful when a value represents configuration, shared design,
domain behavior, identity, routing, API data, or localized user-facing text.

Move these values to the appropriate source:

| Value | Correct source |
| --- | --- |
| API base URLs, timeouts, environment flags | `core/config/` or environment |
| API paths | `core/constants/api_endpoints.dart` |
| Route names | the existing route constants |
| Asset paths | `core/constants/app_assets.dart` |
| Repeated user-facing strings | localization/string keys |
| Brand and semantic colors | theme or semantic color tokens |
| Repeated spacing, radius, duration, elevation | shared design tokens |
| Mock users, IDs, counts, posts, messages | typed fixtures/mock data |
| Business thresholds and limits | named domain/config constants |
| Current user identity | session/current-user service |

Do **not** replace every literal mechanically. Local layout values such as a
one-off `SizedBox(height: 8)` or `BorderRadius.circular(12)` may remain when
they are clear, intentional, and not part of a repeated design rule. Use
`const` where valid. Avoid meaningless constants such as `value1` or
`defaultNumber`.

## Reusable-widget decision rules

Before creating a widget:

1. Search `lib/core/widgets/`, the feature's `widgets/`, and other modules for
   an existing component with the same responsibility.
2. Extend or compose an existing component when that keeps its API clear.
3. Keep a component feature-local when it is used by one feature only.
4. Promote it to `lib/core/widgets/` when two or more independent features use
   the same visual and behavioral contract.
5. Prefer focused composition over a “universal” widget with many booleans.
6. Pass typed data and callbacks through constructors. Shared widgets must not
   call repositories, perform navigation, or read feature controllers.
7. Shared widgets must support light/dark themes, text scaling, safe areas,
   keyboard insets, and narrow/wide layouts where relevant.
8. Preserve stable keys and controller ownership; do not create disposable
   controllers inside repeated `build()` methods.

Suggested size signals, not automatic rules:

- A screen `build()` method above roughly 100–150 lines deserves inspection.
- A non-generated UI file above roughly 300–400 lines likely contains
  extractable sections.
- Similar UI or logic appearing twice deserves comparison, but extraction is
  required only when the contracts are genuinely the same.

## Architecture rules

- Screens compose page-level widgets and connect them to controller state.
- Feature widgets render data and emit callbacks.
- GetX controllers own presentation state, validation flow, and user actions.
- Repositories orchestrate data sources and map failures.
- Services perform raw HTTP, storage, file, or socket operations.
- Models contain typed data and serialization.
- Core widgets contain reusable presentation only, never business rules.
- Do not call Dio, storage, or repositories directly from a widget.
- Do not put large widget trees in controllers.
- Bindings own dependency registration. Avoid hidden `Get.put` calls in UI.

## Required audit workflow

### Phase 1 — Baseline and inventory

Run and record:

```powershell
git status --short
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Also inspect:

- all non-generated Dart files under `lib/` and `test/`;
- route declarations, `GetPage` registrations, and bindings;
- `core/widgets/`, themes, constants, config, services, and repositories;
- the largest non-generated screens, widgets, and controllers;
- repeated widget names, layouts, validators, formatters, and async-state code;
- raw colors, asset paths, route strings, URLs, mock identities, visible text,
  and repeated magic values;
- imports, exported barrels, assets in `pubspec.yaml`, and dependencies.

If the baseline already fails, distinguish pre-existing findings from findings
introduced by the refactor.

### Phase 2 — Report before refactoring

Produce a prioritized table:

| Priority | File/area | Evidence | Risk | Recommended change | Verification |
| --- | --- | --- | --- | --- | --- |

Use:

- **P0** — crash, data loss, security, broken navigation/build;
- **P1** — incorrect logic, lifecycle leak, serious architectural violation;
- **P2** — duplication, harmful hard-coding, oversized UI/controller;
- **P3** — cleanup, naming, safe unused code, minor lint.

Include a proposed batch order. Do not mix unrelated features in one batch.

### Phase 3 — Refactor in small batches

For each approved/in-scope batch:

1. State the behavior that must remain unchanged.
2. Add or update tests for logic with meaningful branches.
3. Extract or improve the smallest useful reusable API.
4. Update all affected call sites.
5. Remove the old duplication only after call sites compile.
6. Format only touched Dart files.
7. Run targeted tests and `flutter analyze`.
8. Summarize exactly what changed and any remaining risk.

Recommended batch order:

1. analyzer/build blockers;
2. core tokens, shared widgets, and shared utilities;
3. one feature at a time, starting with the largest/highest-risk files;
4. unused imports and private declarations;
5. unused assets and dependencies after full-project proof;
6. final documentation and tests.

## Safe unused-code removal

Use the following evidence:

- analyzer diagnostics;
- `rg` searches for symbols, file names, asset paths, routes, and exports;
- route and binding reachability;
- reflection/code-generation annotations;
- Android, iOS, web, desktop, and build-script references;
- `pubspec.yaml` asset and dependency declarations;
- generated files and generator inputs;
- tests and mock/demo entry points.

Classify every candidate as:

- **safe to remove** — no runtime/build/test/config references;
- **keep** — reachable, generated, platform-configured, or intentionally public;
- **needs confirmation** — externally consumed or impossible to prove locally.

Remove only the first category. After removal, run `flutter pub get`,
`flutter analyze`, and `flutter test`. For dependency changes, also perform at
least one relevant debug build when the SDK/toolchain is available.

## Logic-review checklist

Check each feature for:

- loading, empty, success, and error states;
- double-tap/double-submit protection;
- controller, focus node, text controller, animation, stream, and worker cleanup;
- stale async responses after navigation or query changes;
- pagination termination, refresh behavior, and duplicate item handling;
- optimistic-update rollback and retry/idempotency behavior;
- nullability, enum parsing, date/time zones, currency, and localization;
- auth/session source instead of mock identity in production paths;
- route argument validation and binding lifecycle;
- repository error mapping instead of UI-specific exception parsing;
- list item keys and preservation of item state;
- accessibility labels, text scaling, tap targets, safe areas, and keyboard
  behavior;
- light/dark theme compatibility and semantic color usage.

## Definition of done

- Repeated UI uses clear shared or feature-local widgets.
- No harmful hard-coded URLs, routes, asset paths, identities, domain values,
  repeated visible strings, or raw semantic colors remain in touched code.
- Screens and controllers have focused responsibilities.
- Every deletion has evidence.
- No generated code was manually edited.
- `flutter analyze` reports no errors or warnings.
- `flutter test` passes.
- Relevant debug build(s) pass when tooling is available.
- The final report lists changed files, removed items, tests run, unresolved
  findings, and recommended next batch.

## Expected final response

Provide:

1. the highest-impact findings;
2. the refactor batches completed;
3. reusable widgets/utilities created or improved;
4. hard-coded values centralized;
5. unused code/assets/dependencies removed with evidence;
6. commands run and their results;
7. remaining work ordered by priority.

