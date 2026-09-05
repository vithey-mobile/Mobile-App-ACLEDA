import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/vithey_card.dart';
import 'package:flutter/material.dart';

/// Settings-style row on a [VitheyCard] surface.
///
/// Icon in a tinted 12-radius square, title + optional subtitle, and a
/// trailing slot (chevron by default; pass a [VitheySwitch] for toggles).
/// Minimum row height is 48px.
class VitheyListTile extends StatelessWidget {
  const VitheyListTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = true,
    this.destructive = false,
    this.margin,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// Explicit trailing widget (e.g. [VitheySwitch]). When null and
  /// [showChevron] is true, a chevron is shown.
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  /// Tints title/icon with the error color — for "sign out", "delete", etc.
  final bool destructive;

  /// Outer margin around the card.
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accent = context.scheme.primary;
    final iconColor = destructive ? AppColors.error : accent;
    final titleColor = destructive ? AppColors.error : colors.heading;

    return VitheyCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: margin,
      bordered: true,
      elevated: false,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.muted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (showChevron)
              Icon(Icons.chevron_right_rounded, color: colors.muted),
          ],
        ),
      ),
    );
  }
}
