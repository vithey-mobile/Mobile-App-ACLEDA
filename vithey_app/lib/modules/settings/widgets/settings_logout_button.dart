import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class SettingsLogoutButton extends StatelessWidget {
  const SettingsLogoutButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: SizedBox(
        width: double.infinity,
        child: shad.Button.outline(
          onPressed: onPressed,
          leading: const Icon(Icons.logout, color: AppColors.error),
          child: const shad.Text('Logout'),
        ),
      ),
    );
  }
}
