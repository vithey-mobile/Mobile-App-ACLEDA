import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/data/models/finance_dashboard_model.dart';
import 'package:aub_connect_app/data/models/payment_args.dart';
import 'package:aub_connect_app/data/models/payment_invoice_model.dart';
import 'package:aub_connect_app/modules/finance/widgets/bank_select_sheet.dart';
import 'package:aub_connect_app/modules/finance/widgets/finance_status_colors.dart';

class InvoicePreviewSheet {
  static Future<void> show({
    required PaymentInvoice invoice,
    required Future<void> Function() onDownload,
  }) {
    final context = Get.context!;
    return Get.bottomSheet<void>(
      _InvoiceSheet(invoice: invoice, onDownload: onDownload),
      isScrollControlled: true,
      backgroundColor: context.scheme.surface,
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

  void _reportIssue() {
    Get.snackbar(AppStrings.appName, 'Report an issue is coming soon');
  }

  void _payWithAcleda() {
    Get.back();
    Get.toNamed(
      AppRoutes.financePayment,
      arguments: PaymentArgs(invoice: widget.invoice, method: PaymentMethodType.acleda),
    );
  }

  void _payWithAnotherBank() {
    Get.back();
    BankSelectSheet.show(invoice: widget.invoice);
  }

  @override
  Widget build(BuildContext context) {
    final invoice = widget.invoice;
    final theme = _InvoiceTheme.fromStatus(invoice.status);
    final date = invoice.status == PaymentStatus.paid ? invoice.paidAt : invoice.dueAt;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.appColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                invoice.feeName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: context.appColors.heading,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                invoice.invoiceReference,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.appColors.muted,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: theme.panelFill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STATUS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: context.appColors.muted,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: theme.pillColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              invoice.statusLabel.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'DATE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: context.appColors.muted,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            date != null ? _formatDate(date) : '—',
                            style: TextStyle(
                              color: theme.accent,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'BREAKDOWN',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                  fontSize: 12,
                  color: context.appColors.muted,
                ),
              ),
              const SizedBox(height: 12),
              _BreakdownRow(
                label: 'Base Amount',
                value: invoice.baseAmount.formatted,
              ),
              _BreakdownRow(
                label: 'Processing Fee',
                value: invoice.processingFee.formatted,
              ),
              _BreakdownRow(
                label: 'Late Charge',
                value: invoice.lateCharges.formatted,
                valueColor: theme.moneyAccent,
              ),
              Divider(height: 28, color: context.appColors.border),
              Row(
                children: [
                  Text(
                    'Total Due',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: context.appColors.heading,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    invoice.total.formatted,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.moneyAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              if (invoice.status == PaymentStatus.paid) ...[
                _InvoiceActionButton(
                  label: 'Download PDF Invoice',
                  icon: Icons.download_outlined,
                  isLoading: _downloading,
                  onPressed: _download,
                ),
                const SizedBox(height: 10),
                _InvoiceActionButton(
                  label: 'Report an Issue',
                  icon: Icons.help_outline,
                  onPressed: _reportIssue,
                ),
              ] else ...[
                _InvoiceActionButton(
                  label: 'Pay Now With Acleda',
                  icon: Icons.account_balance_wallet_outlined,
                  onPressed: _payWithAcleda,
                ),
                const SizedBox(height: 10),
                _InvoiceActionButton(
                  label: 'Pay Now With Another Bank',
                  icon: Icons.account_balance_outlined,
                  onPressed: _payWithAnotherBank,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _InvoiceTheme {
  const _InvoiceTheme({
    required this.panelFill,
    required this.pillColor,
    required this.accent,
    required this.moneyAccent,
  });

  final Color panelFill;
  final Color pillColor;
  final Color accent;
  final Color moneyAccent;

  factory _InvoiceTheme.fromStatus(PaymentStatus status) {
    final color = FinanceStatusColors.invoiceAccent(status);
    return _InvoiceTheme(
      panelFill: FinanceStatusColors.invoicePanelFill(status),
      pillColor: color,
      accent: color,
      moneyAccent: color,
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: context.appColors.muted)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: valueColor ?? context.appColors.heading,
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceActionButton extends StatelessWidget {
  const _InvoiceActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }
}
