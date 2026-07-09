import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/app_notification_model.dart';
import 'package:aub_connect_app/modules/notification/utils/notification_display_text.dart';
import 'package:aub_connect_app/modules/notification/widgets/notification_type_badge.dart';
import 'package:intl/intl.dart';

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
    final parts = NotificationDisplayText.parts(notification);

    return Semantics(
      label: '${isUnread ? 'Unread. ' : ''}${NotificationDisplayText.build(notification)}',
      button: true,
      child: Material(
        color: isUnread ? AppColors.primary.withValues(alpha: 0.04) : Colors.transparent,
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
                      UserAvatar(
                        name: notification.actor!.fullName,
                        imageUrl: notification.actor!.avatarUrl,
                        radius: 24,
                      )
                    else
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: context.appColors.inputFill,
                        child: Icon(
                          NotificationTypeBadge.iconFor(notification.type),
                          color: NotificationTypeBadge.colorFor(notification.type),
                          size: 22,
                        ),
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
                      _NotificationText(
                        actorName: parts.actorName,
                        actionText: parts.actionText,
                        isUnread: isUnread,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatRelativeTime(notification.createdAt),
                        style: TextStyle(fontSize: 13, color: context.appColors.muted),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    if (isUnread)
                      Semantics(
                        label: 'Unread',
                        child: Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(bottom: 8, top: 4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 22),
                    IconButton(
                      icon: const Icon(Icons.more_horiz),
                      tooltip: 'More options',
                      onPressed: onMore,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                    ),
                  ],
                ),
              ],
            ),
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

class _NotificationText extends StatelessWidget {
  const _NotificationText({
    required this.actorName,
    required this.actionText,
    required this.isUnread,
  });

  final String? actorName;
  final String actionText;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    final baseWeight = isUnread ? FontWeight.w600 : FontWeight.w400;

    if (actorName == null) {
      return Text(
        actionText,
        style: TextStyle(fontWeight: baseWeight, height: 1.35, fontSize: 15),
      );
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 15,
          height: 1.35,
          color: context.appColors.heading,
        ),
        children: [
          TextSpan(
            text: actorName,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: ' $actionText',
            style: TextStyle(fontWeight: baseWeight),
          ),
        ],
      ),
    );
  }
}
