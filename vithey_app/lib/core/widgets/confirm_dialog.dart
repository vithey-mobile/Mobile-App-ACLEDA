import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

/// Color presets for the confirm button.
enum ConfirmDialogVariant {
  /// Generic confirmations (save, continue, clear) — primary teal.
  neutral,

  /// Irreversible actions (logout, delete, sign out everywhere) — red.
  destructive,
}

/// Shows the app-wide confirmation dialog.
///
/// Returns `true` when confirmed, `false` when cancelled, and `null` when
/// dismissed via the scrim or back button.
Future<bool?> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = AppStrings.confirm,
  String cancelLabel = AppStrings.cancel,
  ConfirmDialogVariant variant = ConfirmDialogVariant.neutral,
  Color? confirmColor,
  Color? confirmForegroundColor,
  Color? cancelColor,
  Color? cancelForegroundColor,
  bool barrierDismissible = true,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black45,
    builder: (context) => ConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      variant: variant,
      confirmColor: confirmColor,
      confirmForegroundColor: confirmForegroundColor,
      cancelColor: cancelColor,
      cancelForegroundColor: cancelForegroundColor,
    ),
  );
}

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = AppStrings.confirm,
    this.cancelLabel = AppStrings.cancel,
    this.variant = ConfirmDialogVariant.neutral,
    this.confirmColor,
    this.confirmForegroundColor,
    this.cancelColor,
    this.cancelForegroundColor,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final ConfirmDialogVariant variant;
  final Color? confirmColor;
  final Color? confirmForegroundColor;
  final Color? cancelColor;
  final Color? cancelForegroundColor;

  Color _confirmBackground(BuildContext context) {
    if (confirmColor != null) return confirmColor!;
    switch (variant) {
      case ConfirmDialogVariant.destructive:
        return AppColors.error;
      case ConfirmDialogVariant.neutral:
        return context.scheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final confirmBackground = _confirmBackground(context);
    final confirmForeground = confirmForegroundColor ?? Colors.white;
    final cancelBorder = cancelColor ?? colors.border;
    final cancelForeground = cancelForegroundColor ?? colors.heading;

    return Dialog(
      backgroundColor: colors.cardSurface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.heading,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: colors.muted, height: 1.4),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _DialogButton(
                      label: cancelLabel,
                      foreground: cancelForeground,
                      background: Colors.transparent,
                      border: cancelBorder,
                      onTap: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DialogButton(
                      label: confirmLabel,
                      foreground: confirmForeground,
                      background: confirmBackground,
                      onTap: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.foreground,
    required this.background,
    required this.onTap,
    this.border,
  });

  final String label;
  final Color foreground;
  final Color background;
  final VoidCallback onTap;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: border != null ? BorderSide(color: border!) : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
