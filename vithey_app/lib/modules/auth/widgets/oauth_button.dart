import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';

class OAuthButton extends StatelessWidget {
  const OAuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.authBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('G', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(label, style: const TextStyle(color: AppColors.authHeading, fontWeight: FontWeight.w600)),
                ],
              ),
      ),
    );
  }
}

class SocialDivider extends StatelessWidget {
  const SocialDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.authBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label, style: const TextStyle(color: AppColors.authMuted, fontSize: 12)),
        ),
        const Expanded(child: Divider(color: AppColors.authBorder)),
      ],
    );
  }
}
