import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/data/models/finance_dashboard_model.dart';

class PaymentReceiptTile extends StatelessWidget {
  const PaymentReceiptTile({
    super.key,
    required this.payment,
    required this.onTap,
  });

  final PaymentSummary payment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPaid = payment.status == PaymentStatus.paid;
    final isOverdue = payment.status == PaymentStatus.overdue;
    final iconColor = isPaid ? AppColors.success : isOverdue ? AppColors.error : const Color(0xFFE91E63);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: iconColor.withOpacity(0.12),
                child: Icon(Icons.payments_outlined, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(payment.feeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(payment.dateLabel, style: const TextStyle(color: AppColors.authMuted, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(payment.amount.formatted, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  _StatusPill(label: payment.statusLabel, status: payment.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.status});

  final String label;
  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case PaymentStatus.paid:
        color = AppColors.success;
      case PaymentStatus.overdue:
        color = AppColors.error;
      case PaymentStatus.unpaid:
        color = const Color(0xFFE91E63);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
