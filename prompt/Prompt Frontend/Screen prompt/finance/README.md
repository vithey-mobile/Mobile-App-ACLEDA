# Finance Prompt Index

Use this folder as the single source of truth for student verification and Finance.

## Folder layout

| Path | Contents |
| --- | --- |
| `v0/` | All original finance prompts |
| `v1/` | Redesigned screens (`*-v1.md`) |
| Root | `update.md`, this README only |

Do **not** modify `update.md` when implementing v1.

## Reading order

1. Student Verification Form:
   - Current UI: [`v1/01.verify_from-v1.md`](v1/01.verify_from-v1.md) — `Verification Screen 1.png` / `2.png`
   - Original: [`v0/01.verify_from.md`](v0/01.verify_from.md)
2. Verification Status:
   - Current UI: [`v1/02.pending_verify-v1.md`](v1/02.pending_verify-v1.md) — `Verification Status Screen.png`
   - Original: [`v0/02.pending_verify.md`](v0/02.pending_verify.md)
3. Finance Home:
   - Current UI: [`v1/03.finance_home-v1.md`](v1/03.finance_home-v1.md)
   - Original: [`v0/03.finance_home.md`](v0/03.finance_home.md)
4. Invoice Detail:
   - Current UI: [`v1/04.detail_invoice-v1.md`](v1/04.detail_invoice-v1.md) — `Transaction.png`
   - Original: [`v0/04.detail_invoice.md`](v0/04.detail_invoice.md)

## Ownership boundaries

| Prompt | Owns |
|---|---|
| Verification Form | Student ID/email/password UI, document upload states, submit CTA |
| Verification Status | Lifecycle, polling, role refresh, Finance provisioning |
| Finance Home | Access gate, balance card, paycheck strip, transaction list |
| Invoice Detail | Breakdown, totals, private PDF download, report CTA |

Avoid duplicating invoice logic in Finance Home or form/status logic in Finance screens. All flows use authoritative server status and stable IDs.

## Acceptance checklist (release gate)

- [ ] Verification form matches **v1** images (`Verification Screen 1.png` / `2.png`, `Upload Icon.png`)
- [ ] Status screen pending matches **v1** `Verification Status Screen.png` (verified/rejected still covered)
- [ ] Finance home matches **v1** images (`Finace See All.png` / `Finace See Less.png`)
- [ ] Invoice preview matches **v1** `Transaction.png`
- [ ] Unverified users gated to verification (no broken Finance screen)
- [ ] Dark mode readable on verification, status, finance, invoice
- [ ] `USE_MOCK_API=false` works against gateway when backend ready
- [ ] `flutter analyze` zero errors on touched files
