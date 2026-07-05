import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/data/models/finance_dashboard_model.dart';
import 'package:aub_connect_app/data/models/payment_invoice_model.dart';

class InvoicePreviewSheet {
  static Future<void> show({
    required PaymentInvoice invoice,
    required Future<void> Function() onDownload,
  }) {
    return Get.bottomSheet<void>(
      _InvoiceSheet(invoice: invoice, onDownload: onDownload),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}

class _InvoiceSheet extends StatefulWidget {
  const _InvoiceSheet({required this.invoice, required this.onDownload});

  final PaymentInvoice invoice;
  final Future<void> Function() onDownload;

  @override
  State<_InvoiceSheet> createState() => _InvoiceSheetState();
}

class _InvoiceSheetState extends State<_InvoiceSheet> {
  bool _downloading = false;

  Future<void> _download() async {
    setState(() => _downloading = true);
    try {
      await widget.onDownload();
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoice = widget.invoice;
    final date = invoice.status == PaymentStatus.paid ? invoice.paidAt : invoice.dueAt;
    final dateLabel = invoice.status == PaymentStatus.paid ? 'Paid Date' : 'Due Date';

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.authBorder, borderRadius: BorderRadius.circular(4)),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
          ),
          Text(invoice.feeName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(invoice.invoiceReference, style: const TextStyle(color: AppColors.authMuted)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.authInputFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _StatusPill(label: invoice.statusLabel, status: invoice.status),
                const Spacer(),
                if (date != null) Text('$dateLabel: ${_formatDate(date)}'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('BREAKDOWN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          _BreakdownRow(label: 'Base Amount', value: invoice.baseAmount.formatted),
          _BreakdownRow(label: 'Processing Fee', value: invoice.processingFee.formatted),
          _BreakdownRow(label: 'Late Charges', value: invoice.lateCharges.formatted),
          const Divider(height: 24),
          Row(
            children: [
              Text(invoice.totalLabel, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(invoice.total.formatted, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          CustomButton(
            label: 'Download PDF Invoice',
            icon: Icons.download_outlined,
            isLoading: _downloading,
            onPressed: _download,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.authMuted)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
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
        color = AppColors.warning;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }
}
