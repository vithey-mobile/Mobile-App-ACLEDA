import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';

/// Fixed full-back teal for Auth v2. Does not move with Sign In ↔ Sign Up.
class AuthTealBackdrop extends StatelessWidget {
  const AuthTealBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.primaryLight,
      child: SizedBox.expand(),
    );
  }
}
