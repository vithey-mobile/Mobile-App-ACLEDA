import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/data/models/app_notification_model.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class NotificationActionSheet extends StatelessWidget {
  const NotificationActionSheet({
    super.key,
    required this.notification,
    required this.onMarkRead,
    required this.onDelete,
  });

  final AppNotification notification;
  final VoidCallback? onMarkRead;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.appColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              notification.displayText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            if (onMarkRead != null)
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: const Text('Mark as read'),
                onTap: onMarkRead,
              )
            else
              ListTile(
                leading: Icon(Icons.check_circle, color: context.appColors.muted),
                title: const Text('Already read'),
                enabled: false,
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Delete notification', style: TextStyle(color: AppColors.error)),
              onTap: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
