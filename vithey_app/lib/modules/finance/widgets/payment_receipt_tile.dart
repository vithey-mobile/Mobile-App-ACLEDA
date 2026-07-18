import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/data/models/finance_dashboard_model.dart';
import 'package:aub_connect_app/modules/finance/widgets/finance_status_colors.dart';

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
    final statusColor = FinanceStatusColors.listAccent(payment.status);
    final statusIcon = payment.status == PaymentStatus.paid
        ? Icons.check_circle_outline
        : Icons.schedule_outlined;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: context.appColors.cardSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.appColors.border),
          ),
          child: Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.feeName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.appColors.heading,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      payment.dateLabel,
                      style: TextStyle(color: context.appColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    payment.amount.formatted,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: context.appColors.heading,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    payment.statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}
