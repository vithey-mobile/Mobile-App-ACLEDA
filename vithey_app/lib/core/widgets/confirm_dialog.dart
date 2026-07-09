import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

Future<bool?> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = AppStrings.confirm,
  String cancelLabel = AppStrings.cancel,
}) {
  return shad.showDialog<bool>(
    context: context,
    builder: (context) => shad.Card(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            shad.Text(title),
            const SizedBox(height: 8),
            shad.Text(message).muted(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                shad.Button.ghost(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: shad.Text(cancelLabel),
                ),
                const SizedBox(width: 8),
                shad.Button.primary(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: shad.Text(confirmLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
