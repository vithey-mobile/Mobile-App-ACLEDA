import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';

class SettingsLogoutButton extends StatelessWidget {
  const SettingsLogoutButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.logout, color: AppColors.error),
          label: const Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            backgroundColor: const Color(0xFFFFEBEE),
            side: const BorderSide(color: Color(0xFFFFCDD2)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
