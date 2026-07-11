import 'package:aub_connect_app/data/fixtures/mock_clock.dart';
import 'package:aub_connect_app/data/fixtures/mock_ids.dart';
import 'package:aub_connect_app/data/models/finance_dashboard_model.dart';
import 'package:aub_connect_app/data/models/money_model.dart';
import 'package:aub_connect_app/data/models/payment_invoice_model.dart';

abstract final class FinanceFixtures {
  static List<PaymentSummary> buildPayments() {
    return [
      PaymentSummary(
        id: MockIds.pay1,
        feeName: 'Tuition Fee',
        amount: const Money(amountMinor: 450000),
        status: PaymentStatus.unpaid,
        dueDate: MockClock.daysFromNow(14),
      ),
      PaymentSummary(
        id: MockIds.pay2,
        feeName: 'Library Fine',
        amount: const Money(amountMinor: 2500),
        status: PaymentStatus.overdue,
        dueDate: MockClock.daysAgo(3),
      ),
      PaymentSummary(
        id: MockIds.pay3,
        feeName: 'School Fee',
        amount: const Money(amountMinor: 120000),
        status: PaymentStatus.unpaid,
        dueDate: MockClock.daysFromNow(21),
      ),
      PaymentSummary(
        id: MockIds.pay4,
        feeName: 'Housing',
        amount: const Money(amountMinor: 180000),
        status: PaymentStatus.paid,
        dueDate: MockClock.daysAgo(30),
        paidAt: MockClock.daysAgo(28),
      ),
      PaymentSummary(
        id: MockIds.pay5,
        feeName: 'Trip Fee',
        amount: const Money(amountMinor: 75000),
        status: PaymentStatus.paid,
        dueDate: MockClock.daysAgo(60),
        paidAt: MockClock.daysAgo(58),
      ),
      PaymentSummary(
        id: MockIds.pay6,
        feeName: 'Lab Equipment',
        amount: const Money(amountMinor: 45000),
        status: PaymentStatus.unpaid,
        dueDate: MockClock.daysFromNow(7),
      ),
    ];
  }

  static FinanceDashboard buildDashboard() {
    final payments = buildPayments();
    final unpaid = payments.where((p) => p.status != PaymentStatus.paid).toList();
    final totalMinor = unpaid.fold<int>(0, (sum, p) => sum + p.amount.amountMinor);
    final nextDue = unpaid.isEmpty
        ? MockClock.daysFromNow(14)
        : unpaid.map((p) => p.dueDate).reduce((a, b) => a.isBefore(b) ? a : b);
    final daysRemaining = nextDue.difference(MockClock.now).inDays.clamp(0, 999);
    return FinanceDashboard(
      totalDue: Money(amountMinor: totalMinor, currency: 'USD'),
      nextDueDate: nextDue,
      daysRemaining: daysRemaining,
      summaryStatus: totalMinor == 0 ? 'Paid' : 'Not Yet Paid',
      payments: payments,
      hasMore: false,
    );
  }

  static PaymentInvoice buildInvoice(String paymentId) {
    final payment = buildPayments().firstWhere((p) => p.id == paymentId);
    final base = payment.amount.amountMinor;
    final processing = (base * 0.02).round();
    final late = payment.status == PaymentStatus.overdue ? 1500 : 0;
    return PaymentInvoice(
      paymentId: payment.id,
      invoiceReference: 'INV-${payment.id.toUpperCase()}',
      feeName: payment.feeName,
      status: payment.status,
      baseAmount: Money(amountMinor: base),
      processingFee: Money(amountMinor: processing),
      lateCharges: Money(amountMinor: late),
      total: Money(amountMinor: base + processing + late),
      dueAt: payment.dueDate,
      paidAt: payment.paidAt,
      invoiceFileId: 'invoice-${payment.id}',
    );
  }
}
