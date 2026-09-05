import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeleteNotificationDialog {
  static Future<bool?> show() {
    return Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete notification?'),
        content: const Text(
          'This removes only this notification from your list. The related post, application, message, or payment will not be deleted.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
