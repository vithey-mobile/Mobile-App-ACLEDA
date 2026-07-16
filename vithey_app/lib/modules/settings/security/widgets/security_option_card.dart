import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Rounded grouped card holding the security option rows, matching the
/// Privacy screen card style.
class SecurityOptionCard extends StatelessWidget {
  const SecurityOptionCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.appColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.appColors.subtleShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(children: children),
      ),
    );
  }
}

/// Switch row styled like the Privacy screen rows: primary outline icon,
/// bold title, muted subtitle, compact shad.Switch (same as Dark Mode row).
class SecuritySwitchTile extends StatelessWidget {
  const SecuritySwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appColors.cardSurface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: context.scheme.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.appColors.heading,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: context.appColors.muted),
                  ),
                ],
              ),
            ),
            shad.Switch(value: value, onChanged: (v) => onChanged(v)),
          ],
        ),
      ),
    );
  }
}
