import 'package:aub_connect_app/data/models/finance_dashboard_model.dart';
import 'package:aub_connect_app/data/models/money_model.dart';

class PaymentInvoiceArgs {
  const PaymentInvoiceArgs({required this.paymentId});

  final String paymentId;
}

class PaymentInvoice {
  const PaymentInvoice({
    required this.paymentId,
    required this.invoiceReference,
    required this.feeName,
    required this.status,
    required this.baseAmount,
    required this.processingFee,
    required this.lateCharges,
    required this.total,
    this.dueAt,
    this.paidAt,
    this.invoiceFileId,
  });

  final String paymentId;
  final String invoiceReference;
  final String feeName;
  final PaymentStatus status;
  final Money baseAmount;
  final Money processingFee;
  final Money lateCharges;
  final Money total;
  final DateTime? dueAt;
  final DateTime? paidAt;
  final String? invoiceFileId;

  String get totalLabel => status == PaymentStatus.paid ? 'Total Paid' : 'Total Due';

  String get statusLabel {
    switch (status) {
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.unpaid:
        return 'Not Paid';
      case PaymentStatus.overdue:
        return 'Overdue';
    }
  }
}
