import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class NotificationPreferenceTile extends StatelessWidget {
  const NotificationPreferenceTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final heading = context.appColors.heading;
    final muted = context.appColors.muted;

    return Semantics(
      toggled: value,
      enabled: enabled,
      label: '$title. $subtitle',
      child: Material(
        color: context.appColors.cardSurface,
        child: InkWell(
          onTap: enabled ? () => onChanged(!value) : null,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: enabled ? 1 : 0.48,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(icon, color: context.scheme.primary, size: 24),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: heading,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(color: muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  shad.Switch(
                    value: value,
                    enabled: enabled,
                    onChanged: enabled ? onChanged : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
