import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class SettingsLogoutButton extends StatelessWidget {
  const SettingsLogoutButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: SizedBox(
        width: double.infinity,
        child: CustomButton(
          label: 'Logout',
          icon: Icons.logout,
          variant: CustomButtonVariant.destructive,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
