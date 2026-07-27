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
    final leading = icon != null ? Icon(icon, size: 18) : null;
    // Keep the label centered when the button is stretched full width;
    // icon buttons keep the default start alignment next to the icon.
    final alignment = icon == null ? Alignment.center : null;
    final child = isLoading ? const shad.CircularProgressIndicator() : shad.Text(label);

    switch (variant) {
      case CustomButtonVariant.primary:
        return shad.Button.primary(
          onPressed: isLoading ? null : onPressed,
          leading: leading,
          alignment: alignment,
          child: child,
        );
      case CustomButtonVariant.secondary:
        return shad.Button.secondary(
          onPressed: isLoading ? null : onPressed,
          leading: leading,
          alignment: alignment,
          child: child,
        );
      case CustomButtonVariant.outline:
        return shad.Button.outline(
          onPressed: isLoading ? null : onPressed,
          leading: leading,
          alignment: alignment,
          child: child,
        );
    }
  }
}
