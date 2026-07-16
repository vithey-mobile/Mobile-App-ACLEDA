import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class PasswordHeader extends StatelessWidget {
  const PasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = context.scheme.primary;

    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.lock_outline, color: primary, size: 32),
        ),
        const SizedBox(height: 16),
        Text(
          'Update your password',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: context.appColors.heading,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose a strong password to keep your account safe',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.appColors.muted),
        ),
      ],
    );
  }
}
