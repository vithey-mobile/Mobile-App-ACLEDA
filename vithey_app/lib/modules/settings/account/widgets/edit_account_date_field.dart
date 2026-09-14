import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

class EditAccountDateField extends StatelessWidget {
  const EditAccountDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final primary = context.scheme.primary;
    final display = value != null ? DateFormat('MMMM dd, yyyy').format(value!) : 'Not set';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(VitheyRadii.card),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(color: colors.subtleShadow, blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              VitheyIcon(LucideIcons.cake, size: 18, color: primary),
              const SizedBox(width: 8),
              Text(label, style: context.text.bodySmall),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(VitheyRadii.field),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: colors.inputFill,
                borderRadius: BorderRadius.circular(VitheyRadii.field),
                border: Border.all(color: colors.border),
              ),
              child: Text(
                display,
                style: context.text.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: value != null ? colors.heading : colors.muted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
