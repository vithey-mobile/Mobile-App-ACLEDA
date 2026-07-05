import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';

class VerificationNextStepsCard extends StatelessWidget {
  const VerificationNextStepsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What happens next?', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(
            'Authorized reviewers are checking your submitted data. You will receive an email or in-app notification after completion, usually within 24–48 hours.',
            style: TextStyle(color: AppColors.authHeading, height: 1.4),
          ),
        ],
      ),
    );
  }
}
