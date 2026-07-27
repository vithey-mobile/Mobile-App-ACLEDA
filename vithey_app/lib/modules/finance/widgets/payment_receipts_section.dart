import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/data/models/finance_dashboard_model.dart';
import 'package:aub_connect_app/modules/finance/widgets/payment_receipt_tile.dart';

/// Fixed section header + scrollable transaction list (list scrolls under the title).
class PaymentReceiptsSection extends StatelessWidget {
  const PaymentReceiptsSection({
    super.key,
    required this.payments,
    required this.showAll,
    required this.onToggleShowAll,
    required this.onPaymentTap,
    this.onRefresh,
  });

  final List<PaymentSummary> payments;
  final bool showAll;
  final VoidCallback onToggleShowAll;
  final ValueChanged<String> onPaymentTap;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final list = ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: payments.length,
      itemBuilder: (_, index) {
        final payment = payments[index];
        return PaymentReceiptTile(
          payment: payment,
          onTap: () => onPaymentTap(payment.id),
        );
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'Recent Transaction',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.appColors.heading,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: onToggleShowAll,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(44, 44),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                showAll ? 'See Less' : 'See All',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: onRefresh == null
              ? list
              : RefreshIndicator(onRefresh: onRefresh!, child: list),
        ),
      ],
    );
  }
}
