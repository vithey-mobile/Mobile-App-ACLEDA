import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/vithey_switch.dart';
import 'package:aub_connect_app/modules/settings/widgets/squircle_icon.dart';
import 'package:flutter/material.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

/// Flat settings row for use *inside* a grouped [VitheyCard] — no card
/// chrome of its own. Squircle icon, title + optional subtitle, and a
/// trailing slot (chevron by default; pass a [VitheySwitch] for toggles).
class SettingsGroupMenuTile extends StatelessWidget {
  const SettingsGroupMenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// Explicit trailing widget (e.g. [VitheySwitch]). When null and
  /// [showChevron] is true, a chevron is shown.
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.cardSurface,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                SquircleIcon(icon: icon, radius: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title, style: context.text.titleSmall),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: context.text.bodySmall?.copyWith(height: 1.3),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing!
                else if (showChevron)
                  VitheyIcon(LucideIcons.chevronRight, color: colors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
