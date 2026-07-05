import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';

class VerificationInfoCard extends StatelessWidget {
  const VerificationInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.authInputFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.authBorder,
            child: Icon(Icons.info_outline, size: 18, color: AppColors.authMuted),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verification takes 24–48 hours', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text(
                  'You\'ll receive an email when your student status is verified. You can continue using Vithey in the meantime!',
                  style: TextStyle(color: AppColors.authMuted, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
