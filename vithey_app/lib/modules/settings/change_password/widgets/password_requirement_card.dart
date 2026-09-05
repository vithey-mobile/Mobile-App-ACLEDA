import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/vithey_card.dart';
import 'package:flutter/material.dart';

class PasswordRequirementCard extends StatelessWidget {
  const PasswordRequirementCard({super.key, required this.requirements});

  /// Requirement label mapped to whether it is currently met.
  final Map<String, bool> requirements;

  @override
  Widget build(BuildContext context) {
    return VitheyCard(
      bordered: true,
      elevated: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requirements',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: context.appColors.heading,
            ),
          ),
          const SizedBox(height: 12),
          for (final entry in requirements.entries)
            _RequirementRow(met: entry.value, text: entry.key),
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.met, required this.text});

  final bool met;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = met ? context.scheme.primary : context.appColors.muted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}
