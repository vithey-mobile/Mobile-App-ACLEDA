import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class DeleteNotificationDialog {
  static Future<bool?> show() {
    final context = Get.context;
    if (context == null) return Future.value(null);

    return shad.showDialog<bool>(
      context: context,
      builder: (context) => shad.Card(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const shad.Text('Delete notification?'),
              const SizedBox(height: 8),
              const shad.Text(
                'This removes only this notification from your list. The related post, application, message, or payment will not be deleted.',
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  shad.Button.ghost(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const shad.Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  shad.Button.destructive(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const shad.Text('Delete'),
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
