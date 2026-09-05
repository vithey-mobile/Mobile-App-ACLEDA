import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

enum CustomButtonVariant {
  /// Filled teal — main CTA (submit, continue, apply).
  primary,

  /// Muted filled — supporting actions.
  secondary,

  /// Bordered transparent — alternatives next to a primary CTA.
  outline,

  /// Borderless, minimal — skip / cancel / low-emphasis actions.
  ghost,

  /// Red — delete, remove, block, destructive confirmations.
  destructive,
}

/// Reusable button with loading and disabled states.
///
/// Wraps [shad.Button] so feature screens never import shadcn_flutter
/// directly. Icon + label are always **centered** as one group.
///
/// Do not pass content via Shadcn `leading` — that path uses
/// IntrinsicWidth + Expanded and breaks full-width buttons.
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = CustomButtonVariant.primary,
    this.icon,
    this.leading,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final CustomButtonVariant variant;
  final IconData? icon;

  /// Optional widget before the label (e.g. brand logo). Ignored when [icon] is set.
  final Widget? leading;

  /// Overrides the label/icon color (e.g. white CTAs on the teal wave).
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final leadingWidget =
        icon != null ? Icon(icon, size: 18, color: foregroundColor) : leading;

    final labelWidget = shad.Text(
      label,
      style: foregroundColor != null
          ? TextStyle(color: foregroundColor)
          : null,
    );

    final Widget child;
    if (isLoading) {
      child = const shad.CircularProgressIndicator();
    } else if (leadingWidget == null) {
      child = labelWidget;
    } else {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          leadingWidget,
          const SizedBox(width: 8),
          labelWidget,
        ],
      );
    }

    final enabled = isLoading ? null : onPressed;
    // Always center — including icon + title (Logout, OAuth, etc.).
    const alignment = Alignment.center;

    final shad.Button button = switch (variant) {
      CustomButtonVariant.primary => shad.Button.primary(
          onPressed: enabled,
          alignment: alignment,
          child: child,
        ),
      CustomButtonVariant.secondary => shad.Button.secondary(
          onPressed: enabled,
          alignment: alignment,
          child: child,
        ),
      CustomButtonVariant.outline => shad.Button.outline(
          onPressed: enabled,
          alignment: alignment,
          child: child,
        ),
      CustomButtonVariant.ghost => shad.Button.ghost(
          onPressed: enabled,
          alignment: alignment,
          child: child,
        ),
      CustomButtonVariant.destructive => shad.Button.destructive(
          onPressed: enabled,
          alignment: alignment,
          child: child,
        ),
    };

    // Enforce the 48px minimum tap target for every variant.
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
      child: button,
    );
  }
}
