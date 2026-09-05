import 'package:flutter/material.dart';

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
    final child = isLoading
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
              Text(label),
            ],
          );

    switch (variant) {
      case CustomButtonVariant.primary:
        return ElevatedButton(onPressed: isLoading ? null : onPressed, child: child);
      case CustomButtonVariant.secondary:
        return FilledButton.tonal(onPressed: isLoading ? null : onPressed, child: child);
      case CustomButtonVariant.outline:
        return OutlinedButton(onPressed: isLoading ? null : onPressed, child: child);
    }
  }
}
