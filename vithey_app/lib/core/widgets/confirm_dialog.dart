import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Color presets for the confirm button.
enum ConfirmDialogVariant {
  /// Generic confirmations (save, continue, clear) — primary teal.
  neutral,

  /// Irreversible actions (logout, delete, sign out everywhere) — red.
  destructive,
}

/// Shows the app-wide confirmation dialog.
///
/// Rendered with [shad.AlertDialog] + [CustomButton] (ghost cancel,
/// primary or destructive confirm).
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
  // confirmColor / foreground overrides are kept for API compatibility with
  // existing callers; styling is driven by [variant] through CustomButton.
  // The scrim + scrim-tap dismissal come from the route barrier; the
  // AlertDialog backdrop stays transparent to avoid double-darkening.
  return Get.dialog<bool>(
    ConfirmDialog(
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
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black45,
  );
}

/// App-wide confirmation dialog built on [shad.AlertDialog].
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

  /// Kept for API compatibility; styling is driven by [variant].
  final Color? confirmColor;
  final Color? confirmForegroundColor;
  final Color? cancelColor;
  final Color? cancelForegroundColor;

  void _pop(BuildContext context, bool result) {
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDestructive = variant == ConfirmDialogVariant.destructive;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: shad.AlertDialog(
        barrierColor: Colors.transparent,
        padding: const EdgeInsets.all(24),
        title: SizedBox(
          width: double.infinity,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.heading,
            ),
          ),
        ),
        content: SizedBox(
          width: double.infinity,
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: colors.muted, height: 1.4),
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: cancelLabel,
                    variant: CustomButtonVariant.ghost,
                    onPressed: () => _pop(context, false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    label: confirmLabel,
                    variant: isDestructive
                        ? CustomButtonVariant.destructive
                        : CustomButtonVariant.primary,
                    onPressed: () => _pop(context, true),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
