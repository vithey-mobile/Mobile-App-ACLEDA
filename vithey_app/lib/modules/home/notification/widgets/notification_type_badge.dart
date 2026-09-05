import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/data/models/app_notification_model.dart';

class NotificationTypeBadge extends StatelessWidget {
  const NotificationTypeBadge({super.key, required this.type});

  final NotificationType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: colorFor(type),
        shape: BoxShape.circle,
        border:
            Border.all(color: Theme.of(context).colorScheme.surface, width: 2),
      ),
      child: Icon(iconFor(type), size: 11, color: Colors.white),
    );
  }

  static Color colorFor(NotificationType type) {
    return switch (type) {
      NotificationType.postLike => const Color(0xFFE91E63),
      NotificationType.postComment ||
      NotificationType.postMention =>
        const Color(0xFF2196F3),
      NotificationType.postShare => AppColors.primary,
      NotificationType.newFollower => AppColors.success,
      NotificationType.jobApplicationReceived ||
      NotificationType.jobApplicationStatus =>
        const Color(0xFFFF9800),
      NotificationType.chatRequest ||
      NotificationType.chatMessage =>
        AppColors.primary,
      NotificationType.paymentDue ||
      NotificationType.paymentOverdue =>
        const Color(0xFFFFC107),
      NotificationType.aiAssistantResponse => const Color(0xFF9C27B0),
      NotificationType.studentVerification => AppColors.primary,
      NotificationType.system => AppColors.bodyLight,
    };
  }

  static IconData iconFor(NotificationType type) {
    return switch (type) {
      NotificationType.postLike => Icons.favorite,
      NotificationType.postComment ||
      NotificationType.postMention =>
        Icons.mode_comment,
      NotificationType.postShare => Icons.share,
      NotificationType.newFollower => Icons.person_add,
      NotificationType.jobApplicationReceived ||
      NotificationType.jobApplicationStatus =>
        Icons.work_outline,
      NotificationType.chatRequest ||
      NotificationType.chatMessage =>
        Icons.chat_bubble,
      NotificationType.paymentDue ||
      NotificationType.paymentOverdue =>
        Icons.payments,
      NotificationType.aiAssistantResponse => Icons.auto_awesome,
      NotificationType.studentVerification => Icons.verified_user,
      NotificationType.system => Icons.campaign,
    };
  }
}
