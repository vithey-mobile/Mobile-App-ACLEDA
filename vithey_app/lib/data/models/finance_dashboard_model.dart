import 'package:aub_connect_app/data/models/money_model.dart';

enum PaymentStatus { paid, unpaid, overdue }

class PaymentSummary {
  const PaymentSummary({
    required this.id,
    required this.feeName,
    required this.amount,
    required this.status,
    required this.dueDate,
    this.paidAt,
  });

  final String id;
  final String feeName;
  final Money amount;
  final PaymentStatus status;
  final DateTime dueDate;
  final DateTime? paidAt;

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

  String get dateLabel {
    if (status == PaymentStatus.paid && paidAt != null) {
      return 'Paid ${_formatDate(paidAt!)}';
    }
    return 'Due ${_formatDate(dueDate)}';
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class FinanceDashboard {
  const FinanceDashboard({
    required this.totalDue,
    required this.nextDueDate,
    required this.daysRemaining,
    required this.summaryStatus,
    required this.payments,
    this.hasMore = false,
  });

  final Money totalDue;
  final DateTime nextDueDate;
  final int daysRemaining;
  final String summaryStatus;
  final List<PaymentSummary> payments;
  final bool hasMore;

  String get dueBadgeLabel => daysRemaining > 0 ? 'Due in $daysRemaining Days' : 'Due Today';

  String get nextDueDateLabel {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[nextDueDate.month - 1]} ${nextDueDate.day}, ${nextDueDate.year}';
  }
}
