import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/data/models/payment_args.dart';
import 'package:aub_connect_app/data/models/payment_invoice_model.dart';

class _BankOption {
  const _BankOption({required this.name, required this.color});

  final String name;
  final Color color;
}

const _banks = [
  _BankOption(name: 'Acleda Bank', color: AppColors.primary),
  _BankOption(name: 'ABA Bank', color: Color(0xFFE31E24)),
  _BankOption(name: 'Canadia Bank', color: Color(0xFFF7A600)),
];

class BankSelectSheet {
  static Future<void> show({required PaymentInvoice invoice}) {
    final context = Get.context!;
    return Get.bottomSheet<void>(
      _BankSelectSheetBody(invoice: invoice),
      isScrollControlled: true,
      backgroundColor: context.scheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}

class _BankSelectSheetBody extends StatelessWidget {
  const _BankSelectSheetBody({required this.invoice});

  final PaymentInvoice invoice;

  void _selectBank(String bankName) {
    Get.back();
    Get.toNamed(
      AppRoutes.financePayment,
      arguments: PaymentArgs(
        invoice: invoice,
        method: PaymentMethodType.otherBank,
        bankName: bankName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select a Bank',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.heading,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose which bank to pay from',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.muted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 108,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final bank in _banks)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _BankTile(
                        label: bank.name,
                        color: bank.color,
                        icon: Icons.account_balance,
                        onTap: () => _selectBank(bank.name),
                      ),
                    ),
                  _BankTile(
                    label: 'More (soon)',
                    color: colors.muted,
                    icon: Icons.more_horiz,
                    onTap: null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BankTile extends StatelessWidget {
  const _BankTile({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 76,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.heading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
