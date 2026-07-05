import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aub_connect_app/data/models/finance_dashboard_model.dart';
import 'package:aub_connect_app/data/models/money_model.dart';
import 'package:aub_connect_app/data/models/payment_invoice_model.dart';
import 'package:aub_connect_app/data/services/finance_service.dart';

class FinanceRepository {
  FinanceRepository(this._financeService);

  final FinanceService _financeService;

  bool get useMockApi => dotenv.env['USE_MOCK_API']?.toLowerCase() != 'false';

  Future<FinanceDashboard> getFinanceDashboard({int page = 1, int limit = 20}) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final payments = _mockPayments();
      final unpaid = payments.where((p) => p.status != PaymentStatus.paid).toList();
      final totalMinor = unpaid.fold<int>(0, (sum, p) => sum + p.amount.amountMinor);
      final nextDue = unpaid.isEmpty
          ? DateTime.now().add(const Duration(days: 14))
          : unpaid.map((p) => p.dueDate).reduce((a, b) => a.isBefore(b) ? a : b);
      final daysRemaining = nextDue.difference(DateTime.now()).inDays.clamp(0, 999);
      return FinanceDashboard(
        totalDue: Money(amountMinor: totalMinor, currency: 'USD'),
        nextDueDate: nextDue,
        daysRemaining: daysRemaining,
        summaryStatus: totalMinor == 0 ? 'Paid' : 'Not Yet Paid',
        payments: payments,
        hasMore: false,
      );
    }

    final payments = await _financeService.fetchPayments(page: page, limit: limit);
    final unpaid = payments.where((p) => p.status != PaymentStatus.paid).toList();
    final totalMinor = unpaid.fold<int>(0, (sum, p) => sum + p.amount.amountMinor);
    final nextDue = unpaid.isEmpty ? DateTime.now() : unpaid.first.dueDate;
    return FinanceDashboard(
      totalDue: Money(amountMinor: totalMinor),
      nextDueDate: nextDue,
      daysRemaining: nextDue.difference(DateTime.now()).inDays,
      summaryStatus: totalMinor == 0 ? 'Paid' : 'Not Yet Paid',
      payments: payments,
      hasMore: payments.length >= limit,
    );
  }

  Future<PaymentInvoice> getPaymentInvoice(String paymentId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final payment = _mockPayments().firstWhere((p) => p.id == paymentId);
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
    return _financeService.fetchPaymentInvoice(paymentId);
  }

  Future<void> downloadInvoice(String paymentId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      return;
    }
    await _financeService.fetchPaymentInvoice(paymentId);
  }

  List<PaymentSummary> _mockPayments() {
    final now = DateTime.now();
    return [
      PaymentSummary(
        id: 'pay-1',
        feeName: 'Tuition Fee',
        amount: const Money(amountMinor: 450000),
        status: PaymentStatus.unpaid,
        dueDate: now.add(const Duration(days: 14)),
      ),
      PaymentSummary(
        id: 'pay-2',
        feeName: 'Library Fine',
        amount: const Money(amountMinor: 2500),
        status: PaymentStatus.overdue,
        dueDate: now.subtract(const Duration(days: 3)),
      ),
      PaymentSummary(
        id: 'pay-3',
        feeName: 'School Fee',
        amount: const Money(amountMinor: 120000),
        status: PaymentStatus.unpaid,
        dueDate: now.add(const Duration(days: 21)),
      ),
      PaymentSummary(
        id: 'pay-4',
        feeName: 'Housing',
        amount: const Money(amountMinor: 180000),
        status: PaymentStatus.paid,
        dueDate: now.subtract(const Duration(days: 30)),
        paidAt: now.subtract(const Duration(days: 28)),
      ),
      PaymentSummary(
        id: 'pay-5',
        feeName: 'Trip Fee',
        amount: const Money(amountMinor: 75000),
        status: PaymentStatus.paid,
        dueDate: now.subtract(const Duration(days: 60)),
        paidAt: now.subtract(const Duration(days: 58)),
      ),
      PaymentSummary(
        id: 'pay-6',
        feeName: 'Lab Equipment',
        amount: const Money(amountMinor: 45000),
        status: PaymentStatus.unpaid,
        dueDate: now.add(const Duration(days: 7)),
      ),
    ];
  }
}
