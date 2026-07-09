import 'package:flutter/material.dart';
import 'package:aub_connect_app/data/models/finance_dashboard_model.dart';
import 'package:aub_connect_app/modules/finance/widgets/payment_receipt_tile.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class PaymentReceiptsSection extends StatelessWidget {
  const PaymentReceiptsSection({
    super.key,
    required this.payments,
    required this.showAll,
    required this.onToggleShowAll,
    required this.onPaymentTap,
  });

  final List<PaymentSummary> payments;
  final bool showAll;
  final VoidCallback onToggleShowAll;
  final ValueChanged<String> onPaymentTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Text('Payment Receipts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            shad.Button.ghost(
              onPressed: onToggleShowAll,
              child: shad.Text(showAll ? 'See Less' : 'See All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...payments.map(
          (payment) => PaymentReceiptTile(
            payment: payment,
            onTap: () => onPaymentTap(payment.id),
          ),
        ),
      ],
    );
  }
}
