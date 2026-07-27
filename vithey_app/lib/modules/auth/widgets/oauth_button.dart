import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_assets.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Shared auth CTA label style — primary and outline buttons match size/weight.
const kAuthButtonFontSize = 16.0;
const kAuthButtonFontWeight = FontWeight.w600;

class OAuthButton extends StatelessWidget {
  const OAuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.fontSize = kAuthButtonFontSize,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return AuthOutlineButton(
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      fontSize: fontSize,
      leading: Image.asset(
        AppAssets.googleIcon,
        width: 20,
        height: 20,
        fit: BoxFit.contain,
      ),
    );
  }
}

/// Outline CTA matching Google button chrome (used for Google + Back).
class AuthOutlineButton extends StatelessWidget {
  const AuthOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.isLoading = false,
    this.fontSize = kAuthButtonFontSize,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final bool isLoading;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: shad.Button.outline(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const shad.CircularProgressIndicator()
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: kAuthButtonFontWeight,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class SocialDivider extends StatelessWidget {
  const SocialDivider({
    super.key,
    this.label,
    this.fontSize = 12,
  });

  /// When null/empty, renders a plain horizontal rule (same height chrome).
  final String? label;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final color = context.appColors.border;
    final text = label?.trim();
    // Keep both variants the same height so Sign Up Part 1/2 chrome matches.
    const height = 18.0;
    if (text == null || text.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Divider(color: color, height: 1, thickness: 1),
        ),
      );
    }
    return SizedBox(
      height: height,
      child: shad.Divider(
        color: color,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: context.appColors.muted,
            fontWeight: FontWeight.w500,
            height: 1,
          ),
        ),
      ),
    );
  }
}
