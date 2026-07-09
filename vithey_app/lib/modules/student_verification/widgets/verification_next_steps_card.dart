import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class VerificationNextStepsCard extends StatelessWidget {
  const VerificationNextStepsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('What happens next?', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Authorized reviewers are checking your submitted data. You will receive an email or in-app notification after completion, usually within 24–48 hours.',
            style: TextStyle(color: context.appColors.heading, height: 1.4),
          ),
        ],
      ),
    );
  }
}
