# GLM 5.3 Flash — Prompt 11 — Sweep + completion (LAST)

Copy everything below `---` into a **new** chat **after** 01–10 are merged.

---

You are a Flutter completion agent. Make the GenZ pass **actually complete** across the app. Do not start a new visual brand.

## Read

`prompt/Prompt Frontend/run-genz-complete/DESIGN_SYSTEM.md`  
`prompt/Prompt Frontend/COMPONENT_KIT.md`

## Own

Any leftover under `vithey_app/lib/modules/**` and tiny kit fixes under `vithey_app/lib/core/widgets/**` if modules need a missing export.

## Do this

### 1) Kill leftovers (modules only)

Search and fix:

- `ElevatedButton` / `TextButton` / `OutlinedButton` / `FilterChip` / `ChoiceChip` / Material `Card(` used as chrome
- `Colors.teal` / `0xFF00BFA5` / random primary hex
- `BorderRadius.circular(8)` on primary cards/icon buttons you can safely bump to GenZ radii (prefer `VitheyRadii`)
- Module imports of `shadcn_flutter`

### 2) Icon chrome audit

App bars / quick actions still using tiny raw `IconButton` without soft fill → wrap with `VitheyIconButton` / chrome pattern from 00.

### 3) States

Any screen you touch missing empty/error/loading → add kit widgets.

### 4) Docs

Update `prompt/Prompt Frontend/run-genz-complete/README.md` status table: mark 00–11 **Done** with date when finished.

Update `prompt/Prompt Frontend/COMPONENT_KIT.md` if Prompt 00 missed GenZ section.

### 5) Verify

- `dart analyze` on `vithey_app/lib` for issues you introduced
- List remaining intentional exceptions (e.g. `GoogleMap`, platform views)

## Stop when

- Near-zero raw CTA leftovers in modules
- README status complete
- Short summary of modules polished + known exceptions
