import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class VerificationNextStepsCard extends StatelessWidget {
  const VerificationNextStepsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = context.appColors.muted;
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
            'What happens next?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: context.appColors.heading,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Our verification team is reviewing your documents. This typically takes 24 - 48 hours.',
            style: TextStyle(color: muted, height: 1.45, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Text(
            "You'll receive an email notification once your verification is complete.",
            style: TextStyle(color: muted, height: 1.45, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
