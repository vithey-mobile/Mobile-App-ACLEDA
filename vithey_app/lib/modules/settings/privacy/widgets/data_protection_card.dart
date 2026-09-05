import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/vithey_card.dart';
import 'package:flutter/material.dart';

class DataProtectionCard extends StatelessWidget {
  const DataProtectionCard({super.key, required this.onLearnMore});

  final VoidCallback onLearnMore;

  @override
  Widget build(BuildContext context) {
    final primary = context.scheme.primary;

    return VitheyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, color: primary),
              const SizedBox(width: 8),
              Text(
                'Data Protection',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: context.appColors.heading,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your data is encrypted and securely stored. We never share your personal information with third parties without your consent.',
            style: TextStyle(color: context.appColors.heading, height: 1.4),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onLearnMore,
            child: Text(
              'Learn more about our privacy practices →',
              style: TextStyle(color: primary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
