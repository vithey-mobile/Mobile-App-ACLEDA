import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/widgets/vithey_card.dart';
import 'package:aub_connect_app/modules/settings/widgets/squircle_icon.dart';
import 'package:flutter/material.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

class ActiveSessionsCard extends StatelessWidget {
  const ActiveSessionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return VitheyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SquircleIcon(icon: LucideIcons.shield, radius: 16),
              const SizedBox(width: 12),
              Text(
                'Active Sessions',
                style: context.text.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SquircleIcon(
                icon: LucideIcons.smartphone,
                size: 40,
                radius: 16,
                color: colors.heading,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Device',
                      style: context.text.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Last active: Just now',
                      style: context.text.bodySmall?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: context.scheme.primary.withValues(
                    alpha: context.isDarkMode ? 0.20 : 0.12,
                  ),
                  borderRadius: BorderRadius.circular(VitheyRadii.pill),
                ),
                child: Text(
                  'Active',
                  style: context.text.labelMedium?.copyWith(
                    color: context.scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
