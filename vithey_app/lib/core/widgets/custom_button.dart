import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

enum CustomButtonVariant { primary, secondary, outline }

/// Reusable button with loading and disabled states.
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = CustomButtonVariant.primary,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final CustomButtonVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case CustomButtonVariant.primary:
        return shad.Button.primary(
          onPressed: isLoading ? null : onPressed,
          leading: icon != null ? Icon(icon, size: 18) : null,
          child: isLoading ? const shad.CircularProgressIndicator() : shad.Text(label),
        );
      case CustomButtonVariant.secondary:
        return shad.Button.secondary(
          onPressed: isLoading ? null : onPressed,
          leading: icon != null ? Icon(icon, size: 18) : null,
          child: isLoading ? const shad.CircularProgressIndicator() : shad.Text(label),
        );
      case CustomButtonVariant.outline:
        return shad.Button.outline(
          onPressed: isLoading ? null : onPressed,
          leading: icon != null ? Icon(icon, size: 18) : null,
          child: isLoading ? const shad.CircularProgressIndicator() : shad.Text(label),
        );
    }
  }
}
