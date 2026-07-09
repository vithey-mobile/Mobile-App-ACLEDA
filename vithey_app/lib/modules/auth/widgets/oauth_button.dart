import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

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
      child: shad.Button.outline(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const shad.CircularProgressIndicator()
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const shad.Text('G'),
                  const SizedBox(width: 8),
                  shad.Text(label),
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
    return shad.Divider(
      color: context.appColors.border,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: shad.Text(label),
    );
  }
}
