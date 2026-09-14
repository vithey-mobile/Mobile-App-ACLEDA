# Finance Module — As-Built Spec (ayheng)

> **Status:** Implemented in `vithey_app/lib/modules/finance/` and `student_verification/` on branch `ayheng`.
> This file is the **source of truth** for current Finance / Verification / Transaction behavior.
> Prompts live in this folder (flat — no version subfolders).

---

## Scope

| Screen | Prompt | Module |
|--------|--------|--------|
| Student Verification Form | `01.verify_from.md` | `student_verification/` |
| Verification Status | `02.pending_verify.md` | `student_verification/` |
| Finance Home | `03.finance_home.md` | `finance/` |
| Invoice / Transaction detail | `04.detail_invoice.md` | `invoice_preview_sheet.dart` |

---

## Access gate (unchanged)

1. Not verified → Verification Form or Status (by state).
2. Verified student → Finance Home.
3. Finance entry: `FinanceNavigation.openFinanceEntry` (home app bar / media header).

---

## Finance Home — as built

**File:** `finance_screen.dart`

| Spec | Value |
|------|-------|
| Content padding | `EdgeInsets.fromLTRB(20, 8, 20, 0)` — **20px** left/right |
| App bar | `FinanceAppBar` — title **Finance** |
| Balance card | Outstanding amount, Due pill under amount, wallet asset right, **Pay Now** full width |
| Total Paycheck | Strip under card (`FinanceTotalPaycheck`) |
| Recent Transaction | Header + See All / See Less; scrollable list |

### Transaction row

| Spec | Value |
|------|-------|
| Widget | `PaymentReceiptTile` |
| Amount shown | **Total** = base + processing fee + late charges (not base alone) |
| Status | Colored text only (Paid / Pending / Overdue) — no filled status chip |
| Icon | Status glyph without filled plate |
| Tap | Opens invoice preview for that `paymentId` |

### Money model (list)

`dart
class PaymentSummary {
  final Money amount;      // TOTAL charged (list + dashboard aggregates)
  final Money? baseAmount; // base before fees (invoice rebuild)
  // ...
}
`

Mock fee rule (`FinanceFixtures`):

- Processing fee = **2%** of base (rounded).
- Late charge = **1500** minor units when status is overdue.
- `amount` / dashboard totals use `base + processing + late`.

Invoice detail still shows authoritative breakdown: Base, Processing Fee, Late Charge, **Total Due**.

---

## Invoice detail — as built

**File:** `invoice_preview_sheet.dart`
**Visual:** `screen image/finance/Transaction.png`

| Spec | Value |
|------|-------|
| Sheet padding | **20px** left/right |
| Header | Fee name + invoice reference |
| Status panel | STATE tint + DATE |
| Breakdown | Base Amount, Processing Fee, Late Charge |
| Total | **Total Due** = `invoice.total` (matches list total) |
| Actions | Download PDF Invoice, Report an Issue |

---

## Verification — as built

| Spec | Value |
|------|-------|
| Form padding | `fromLTRB(20, …)` |
| Status padding | `fromLTRB(20, …)` |
| Upload | Student ID box + upload icon asset |

---

## Key Flutter paths

`text
lib/modules/finance/
  finance_screen.dart
  finance_controller.dart
  widgets/
    finance_balance_card.dart
    finance_total_paycheck.dart
    payment_receipts_section.dart
    payment_receipt_tile.dart
    invoice_preview_sheet.dart
lib/modules/student_verification/
  student_verification_screen.dart
  verification_status_screen.dart
lib/data/
  fixtures/finance_fixtures.dart
  models/finance_dashboard_model.dart
  models/payment_invoice_model.dart
  repositories/finance_repository.dart
  repositories/student_verification_repository.dart  # FinanceNavigation
`

---

## Acceptance (as built)

- [x] Finance content padding 20 left/right
- [x] Balance card + Total Paycheck + See All/Less transactions
- [x] Transaction list amount = total including processing fee (and late when overdue)
- [x] Invoice breakdown + Total Due consistent with list totals
- [x] Verification form/status use 20px horizontal padding
- [x] Unverified users gated away from Finance Home
