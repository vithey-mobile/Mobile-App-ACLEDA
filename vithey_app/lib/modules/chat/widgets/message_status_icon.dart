import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/data/models/chat_message_model.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class MessageStatusIcon extends StatelessWidget {
  const MessageStatusIcon({
    super.key,
    required this.status,
    this.onLightBackground = false,
  });

  final MessageDeliveryStatus status;
  final bool onLightBackground;

  @override
  Widget build(BuildContext context) {
    final muted = onLightBackground ? context.appColors.muted : Colors.white70;
    final readColor =
        onLightBackground ? AppColors.primary : AppColors.primaryLight;

    switch (status) {
      case MessageDeliveryStatus.read:
        return VitheyIcon(LucideIcons.checkCheck, size: 14, color: readColor);
      case MessageDeliveryStatus.delivered:
        return VitheyIcon(LucideIcons.checkCheck, size: 14, color: muted);
      case MessageDeliveryStatus.sent:
        return VitheyIcon(LucideIcons.check, size: 14, color: muted);
      case MessageDeliveryStatus.sending:
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(strokeWidth: 1.5, color: muted),
        );
      case MessageDeliveryStatus.failed:
        return const VitheyIcon(LucideIcons.circleAlert,
            size: 14, color: AppColors.error);
    }
  }
}
