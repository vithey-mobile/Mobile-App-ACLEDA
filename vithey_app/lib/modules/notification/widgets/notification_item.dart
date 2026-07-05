import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/data/models/app_notification_model.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:intl/intl.dart';

class NotificationTypeBadge extends StatelessWidget {
  const NotificationTypeBadge({super.key, required this.type});

  final NotificationType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(_iconFor(type), size: 11, color: Colors.white),
    );
  }

  IconData _iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.postLike:
        return Icons.favorite;
      case NotificationType.postComment:
      case NotificationType.postMention:
        return Icons.chat_bubble;
      case NotificationType.postShare:
        return Icons.share;
      case NotificationType.newFollower:
        return Icons.person_add;
      case NotificationType.jobApplicationReceived:
      case NotificationType.jobApplicationStatus:
        return Icons.work_outline;
      case NotificationType.chatRequest:
      case NotificationType.chatMessage:
        return Icons.message;
      case NotificationType.paymentDue:
      case NotificationType.paymentOverdue:
        return Icons.payments_outlined;
      case NotificationType.studentVerification:
        return Icons.verified_user_outlined;
      case NotificationType.system:
        return Icons.info_outline;
    }
  }
}

class NotificationItem extends StatelessWidget {
  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onMore,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    return Material(
      color: isUnread ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  if (notification.actor != null)
                    UserAvatar(name: notification.actor!.fullName, radius: 22)
                  else
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.authInputFill,
                      child: const Icon(Icons.notifications_none, color: AppColors.authMuted),
                    ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: NotificationTypeBadge(type: notification.type),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.displayText,
                      style: TextStyle(
                        fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatRelativeTime(notification.createdAt),
                      style: const TextStyle(fontSize: 12, color: AppColors.authMuted),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  if (isUnread)
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: onMore,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return 'Yesterday';
    return DateFormat('MMM d').format(time);
  }
}
