import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class AccountInfoCard extends StatelessWidget {
  const AccountInfoCard({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;

  bool get _hasValue => value != null && value!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final primary = context.scheme.primary;
    final displayValue = _hasValue ? value!.trim() : 'Not set';
    final isLink = onTap != null && _hasValue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: colors.subtleShadow, blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLink ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(label, style: TextStyle(color: colors.muted, fontSize: 13)),
                    ),
                    if (trailing != null) trailing!,
                    if (isLink) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.open_in_new, size: 16, color: primary),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _hasValue
                        ? (isLink ? AppColors.primary : colors.heading)
                        : colors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AccountListInfoCard extends StatelessWidget {
  const AccountListInfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.items,
    this.emptyHint = 'No items added',
  });

  final IconData icon;
  final String label;
  final List<String> items;
  final String emptyHint;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final primary = context.scheme.primary;
    final hasItems = items.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: colors.subtleShadow, blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: primary),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: colors.muted, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          if (!hasItems)
            Text(emptyHint, style: TextStyle(fontSize: 16, color: colors.muted))
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $item',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: colors.heading),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AccountSectionLabel extends StatelessWidget {
  const AccountSectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: context.appColors.muted,
        ),
      ),
    );
  }
}
