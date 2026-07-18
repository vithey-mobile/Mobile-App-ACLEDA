import 'package:aub_connect_app/data/fixtures/mock_clock.dart';
import 'package:aub_connect_app/data/fixtures/mock_ids.dart';
import 'package:aub_connect_app/data/models/finance_dashboard_model.dart';
import 'package:aub_connect_app/data/models/money_model.dart';
import 'package:aub_connect_app/data/models/payment_invoice_model.dart';

abstract final class FinanceFixtures {
  /// Mixed statuses with interleaved due dates so newest-first order
  /// shows recent Paid and Pending together (not all pending on top).
  static List<PaymentSummary> buildPayments() {
    return [
      PaymentSummary(
        id: MockIds.pay1,
        feeName: 'School Fee',
        amount: const Money(amountMinor: 120000),
        status: PaymentStatus.unpaid,
        dueDate: MockClock.daysFromNow(16),
      ),
      PaymentSummary(
        id: MockIds.pay2,
        feeName: 'Housing Fee',
        amount: const Money(amountMinor: 250000),
        status: PaymentStatus.paid,
        dueDate: MockClock.daysFromNow(14),
        paidAt: MockClock.daysAgo(1),
      ),
      PaymentSummary(
        id: MockIds.pay3,
        feeName: 'Library Fee',
        amount: const Money(amountMinor: 1000),
        status: PaymentStatus.unpaid,
        dueDate: MockClock.daysFromNow(12),
      ),
      PaymentSummary(
        id: MockIds.pay4,
        feeName: 'Food Fee',
        amount: const Money(amountMinor: 50000),
        status: PaymentStatus.paid,
        dueDate: MockClock.daysFromNow(10),
        paidAt: MockClock.daysAgo(2),
      ),
      PaymentSummary(
        id: MockIds.pay5,
        feeName: 'Trip',
        amount: const Money(amountMinor: 5000),
        status: PaymentStatus.unpaid,
        dueDate: MockClock.daysFromNow(8),
      ),
      PaymentSummary(
        id: MockIds.pay6,
        feeName: 'Tuition Fee',
        amount: const Money(amountMinor: 450000),
        status: PaymentStatus.paid,
        dueDate: MockClock.daysFromNow(6),
        paidAt: MockClock.daysAgo(3),
      ),
      PaymentSummary(
        id: MockIds.pay7,
        feeName: 'Lab Equipment',
        amount: const Money(amountMinor: 45000),
        status: PaymentStatus.unpaid,
        dueDate: MockClock.daysFromNow(4),
      ),
      PaymentSummary(
        id: MockIds.pay8,
        feeName: 'Sports Club',
        amount: const Money(amountMinor: 35000),
        status: PaymentStatus.paid,
        dueDate: MockClock.daysFromNow(2),
        paidAt: MockClock.now,
      ),
      PaymentSummary(
        id: MockIds.pay9,
        feeName: 'Exam Fee',
        amount: const Money(amountMinor: 25000),
        status: PaymentStatus.unpaid,
        dueDate: MockClock.daysFromNow(1),
      ),
      PaymentSummary(
        id: MockIds.pay10,
        feeName: 'Dormitory Deposit',
        amount: const Money(amountMinor: 150000),
        status: PaymentStatus.overdue,
        dueDate: MockClock.daysAgo(2),
      ),
      PaymentSummary(
        id: MockIds.pay11,
        feeName: 'ID Card Replacement',
        amount: const Money(amountMinor: 1500),
        status: PaymentStatus.paid,
        dueDate: MockClock.daysAgo(4),
        paidAt: MockClock.daysAgo(5),
      ),
      PaymentSummary(
        id: MockIds.pay12,
        feeName: 'Workshop Fee',
        amount: const Money(amountMinor: 8000),
        status: PaymentStatus.overdue,
        dueDate: MockClock.daysAgo(7),
      ),
      PaymentSummary(
        id: MockIds.pay13,
        feeName: 'Internet Package',
        amount: const Money(amountMinor: 20000),
        status: PaymentStatus.paid,
        dueDate: MockClock.daysAgo(9),
        paidAt: MockClock.daysAgo(8),
      ),
      PaymentSummary(
        id: MockIds.pay14,
        feeName: 'Parking Permit',
        amount: const Money(amountMinor: 12000),
        status: PaymentStatus.unpaid,
        dueDate: MockClock.daysFromNow(28),
      ),
      PaymentSummary(
        id: MockIds.pay15,
        feeName: 'Graduation Fee',
        amount: const Money(amountMinor: 75000),
        status: PaymentStatus.paid,
        dueDate: MockClock.daysAgo(18),
        paidAt: MockClock.daysAgo(16),
      ),
    ];
  }

  static FinanceDashboard buildDashboard() {
    final payments = List<PaymentSummary>.from(buildPayments())
      ..sort((a, b) => b.sortDate.compareTo(a.sortDate));
    final unpaid = payments.where((p) => p.status != PaymentStatus.paid).toList();
    final totalMinor = unpaid.fold<int>(0, (sum, p) => sum + p.amount.amountMinor);
    final paycheckMinor = payments
        .where((p) => p.status == PaymentStatus.paid)
        .fold<int>(0, (sum, p) => sum + p.amount.amountMinor);
    final nextDuePayment = unpaid.isEmpty
        ? null
        : unpaid.reduce((a, b) => a.dueDate.isBefore(b.dueDate) ? a : b);
    final nextDue = nextDuePayment?.dueDate ?? MockClock.daysFromNow(14);
    final daysRemaining = nextDue.difference(MockClock.now).inDays.clamp(0, 999);
    return FinanceDashboard(
      totalDue: Money(amountMinor: totalMinor, currency: 'USD'),
      totalPaycheck: Money(amountMinor: paycheckMinor, currency: 'USD'),
      nextDueDate: nextDue,
      daysRemaining: daysRemaining,
      summaryStatus: totalMinor == 0 ? 'Paid' : 'Not Yet Paid',
      payments: payments,
      nextDuePaymentId: nextDuePayment?.id,
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
      invoiceReference: _referenceFor(payment.id),
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

  static String _referenceFor(String paymentId) {
    final seed = paymentId.hashCode.abs().toRadixString(16).toUpperCase();
    final padded = '${seed}A34D1B522'.substring(0, 8);
    final prefix = paymentId.contains('1') || paymentId.contains('6')
        ? 'Y3T'
        : paymentId.contains('3')
            ? 'TEXU'
            : 'VTH';
    return '$prefix-$padded';
  }
}
