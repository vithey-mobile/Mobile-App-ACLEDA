import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/data/models/payment_args.dart';
import 'package:aub_connect_app/data/models/payment_invoice_model.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(VitheyRadii.sheet)),
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
              style: context.text.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Choose which bank to pay from',
              textAlign: TextAlign.center,
              style: context.text.bodySmall,
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
                        icon: LucideIcons.landmark,
                        onTap: () => _selectBank(bank.name),
                      ),
                    ),
                  _BankTile(
                    label: 'More banks',
                    color: colors.muted,
                    icon: LucideIcons.ellipsis,
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
    final disabled = onTap == null;
    return Opacity(
      opacity: disabled ? 0.75 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 76,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              disabled
                  ? CustomPaint(
                      painter: _DashedCirclePainter(color: color),
                      child: Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        child: VitheyIcon(icon, color: color, size: 26),
                      ),
                    )
                  : Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: color.withValues(alpha: 0.3)),
                      ),
                      child: VitheyIcon(icon, color: color, size: 26),
                    ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: disabled ? colors.muted : colors.heading,
                ),
              ),
              if (disabled) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.muted.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(VitheyRadii.pill),
                  ),
                  child: Text(
                    'Coming soon',
                    style: context.text.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final path = Path()
      ..addOval(Offset.zero & size);
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}
