import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class VerificationInfoCard extends StatelessWidget {
  const VerificationInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verification takes 24 - 48 hours',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: context.appColors.heading,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "You'll receive an email once your student status is verified.",
            style: TextStyle(
              color: context.appColors.muted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
