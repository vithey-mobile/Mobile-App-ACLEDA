# Finance Prompt Index

Use this folder as the single source of truth for student verification and Finance.

## Folder layout

| Path | Contents |
| --- | --- |
| `v0/` | All original finance prompts |
| `v1/` | Redesigned screens (`*-v1.md`) |
| Root | [`update.md`](update.md) — **as-built ayheng finance/verification/transaction**, this README |

Do **not** treat older short UI briefs as overriding `update.md` + `v1/` as-built rules.

## Reading order

1. Student Verification Form:
   - Current UI: [`v1/01.verify_from-v1.md`](v1/01.verify_from-v1.md) — `Verification Screen 1.png` / `2.png`
   - Original: [`v0/01.verify_from.md`](v0/01.verify_from.md)
2. Verification Status:
   - Current UI: [`v1/02.pending_verify-v1.md`](v1/02.pending_verify-v1.md) — `Verification Status Screen.png`
   - Original: [`v0/02.pending_verify.md`](v0/02.pending_verify.md)
3. Finance Home:
   - Current UI: [`v1/03.finance_home-v1.md`](v1/03.finance_home-v1.md) — **20px pad; list amount = total with fees**
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

- [x] Verification form matches **v1** images
- [x] Status screen pending matches **v1**
- [x] Finance home: balance + paycheck + transactions; **20px** padding
- [x] Transaction list shows **total** (base + processing fee + late)
- [x] Invoice preview matches **v1** `Transaction.png`; Total Due aligns with list
- [x] Unverified users gated to verification
- [ ] Dark mode readable on verification, status, finance, invoice
- [ ] `USE_MOCK_API=false` works against gateway when backend ready
- [ ] `flutter analyze` zero errors on touched files
