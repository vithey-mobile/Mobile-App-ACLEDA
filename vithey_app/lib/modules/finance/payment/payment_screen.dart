import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/data/models/payment_args.dart';
import 'package:aub_connect_app/data/models/payment_invoice_model.dart';
import 'package:aub_connect_app/modules/finance/payment/payment_controller.dart';

class PaymentScreen extends GetView<PaymentController> {
  const PaymentScreen({super.key});

  bool get _isAcleda => controller.args.method == PaymentMethodType.acleda;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          _isAcleda ? 'Pay With Acleda' : 'Pay With Another Bank',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: context.appColors.border),
        ),
      ),
      body: Obx(() {
        switch (controller.status.value) {
          case PaymentFlowStatus.collecting:
            return _CollectingView(isAcleda: _isAcleda);
          case PaymentFlowStatus.processing:
            return const _ProcessingView();
          case PaymentFlowStatus.success:
            return _SuccessView(isAcleda: _isAcleda);
        }
      }),
    );
  }
}

class _CollectingView extends GetView<PaymentController> {
  const _CollectingView({required this.isAcleda});

  final bool isAcleda;

  @override
  Widget build(BuildContext context) {
    final invoice = controller.args.invoice;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _InvoiceSummaryCard(invoice: invoice),
            const SizedBox(height: 24),
            if (isAcleda) const _AcledaQrPanel() else const _BankTransferPanel(),
            const SizedBox(height: 24),
            CustomButton(
              label: isAcleda ? "I've Completed the Payment" : "I've Made the Transfer",
              onPressed: controller.confirmPayment,
            ),
            const SizedBox(height: 12),
            Text(
              'This is a preview flow — no real payment is processed yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.appColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceSummaryCard extends StatelessWidget {
  const _InvoiceSummaryCard({required this.invoice});

  final PaymentInvoice invoice;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            invoice.feeName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colors.heading,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            invoice.invoiceReference,
            style: TextStyle(
              color: colors.muted,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                invoice.totalLabel,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: colors.heading,
                ),
              ),
              const Spacer(),
              Text(
                invoice.total.formatted,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AcledaQrPanel extends StatelessWidget {
  const _AcledaQrPanel();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.qr_code_2, size: 96, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Scan this KHQR code with your Acleda Mobile app to pay',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.heading, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _BankTransferPanel extends StatelessWidget {
  const _BankTransferPanel();

  @override
  Widget build(BuildContext context) {
    final args = Get.find<PaymentController>().args;
    final reference = args.invoice.invoiceReference;
    final bankName = args.bankName ?? 'Acleda Bank';
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TRANSFER DETAILS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
              fontSize: 12,
              color: colors.muted,
            ),
          ),
          const SizedBox(height: 12),
          _CopyableRow(label: 'Bank Name', value: bankName),
          _CopyableRow(label: 'Account Name', value: 'AUB Connect School Fund'),
          _CopyableRow(label: 'Account Number', value: '0000-1234-5678'),
          _CopyableRow(label: 'Reference', value: reference),
        ],
      ),
    );
  }
}

class _CopyableRow extends StatelessWidget {
  const _CopyableRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.muted,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(color: colors.heading, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_outlined, size: 18),
            color: AppColors.primary,
            tooltip: 'Copy',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              Get.snackbar(AppStrings.appName, '$label copied');
            },
          ),
        ],
      ),
    );
  }
}

class _ProcessingView extends StatelessWidget {
  const _ProcessingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Confirming your payment…',
            style: TextStyle(color: context.appColors.muted),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends GetView<PaymentController> {
  const _SuccessView({required this.isAcleda});

  final bool isAcleda;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 20),
            Text(
              'Payment Submitted',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.heading,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isAcleda
                  ? "We'll update your invoice once Acleda confirms the payment."
                  : "We'll update your invoice once the transfer is confirmed.",
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.muted, fontSize: 13),
            ),
            const SizedBox(height: 28),
            CustomButton(
              label: 'Back to Finance',
              onPressed: controller.backToFinance,
            ),
          ],
        ),
      ),
    );
  }
}
