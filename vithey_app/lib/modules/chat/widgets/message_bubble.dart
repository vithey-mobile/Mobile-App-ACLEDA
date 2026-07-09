import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/chat_message_model.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.showAvatar,
    required this.participantName,
    this.participantAvatarUrl,
    this.onRetry,
    this.onLongPress,
    this.showSeenLabel = false,
  });

  final ChatMessage message;
  final bool showAvatar;
  final String participantName;
  final String? participantAvatarUrl;
  final VoidCallback? onRetry;
  final VoidCallback? onLongPress;
  final bool showSeenLabel;

  String _formatBubbleTime(DateTime time) {
    return DateFormat('h:mma').format(time).replaceAll(' ', '');
  }

  @override
  Widget build(BuildContext context) {
    final isOwn = message.isOwn;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.78;
    final bubbleColor = isOwn ? AppColors.primary : context.appColors.cardSurface;
    final textColor = isOwn ? Colors.white : context.appColors.heading;
    final displayText = message.isDeleted ? 'This message was deleted' : message.text;
    final timeColor = isOwn ? Colors.white.withValues(alpha: 0.75) : context.appColors.muted;

    return Padding(
      padding: EdgeInsets.only(bottom: showSeenLabel ? 4 : 8),
      child: Row(
        mainAxisAlignment: isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isOwn && showAvatar)
            UserAvatar(name: participantName, imageUrl: participantAvatarUrl, radius: 16)
          else if (!isOwn)
            const SizedBox(width: 32),
          if (!isOwn) const SizedBox(width: 6),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: GestureDetector(
              onLongPress: message.isDeleted ? null : onLongPress,
              child: Column(
                crossAxisAlignment: isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (message.replyToPreview != null && message.replyToPreview!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isOwn ? Colors.white.withValues(alpha: 0.15) : context.appColors.inputFill,
                        borderRadius: BorderRadius.circular(8),
                        border: Border(
                          left: BorderSide(color: isOwn ? Colors.white70 : AppColors.primary, width: 3),
                        ),
                      ),
                      child: Text(
                        message.replyToPreview!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isOwn ? Colors.white70 : context.appColors.muted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                    decoration: BoxDecoration(
                      color: message.isDeleted ? bubbleColor.withValues(alpha: 0.7) : bubbleColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isOwn ? 16 : 4),
                        bottomRight: Radius.circular(isOwn ? 4 : 16),
                      ),
                      border: isOwn ? null : Border.all(color: context.appColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            displayText,
                            style: TextStyle(
                              color: message.isDeleted ? textColor.withValues(alpha: 0.7) : textColor,
                              fontSize: 15,
                              height: 1.4,
                              fontStyle: message.isDeleted ? FontStyle.italic : FontStyle.normal,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatBubbleTime(message.createdAt),
                              style: TextStyle(fontSize: 11, color: timeColor),
                            ),
                            if (message.isFailed) ...[
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: onRetry,
                                child: const Text(
                                  'Retry',
                                  style: TextStyle(color: AppColors.error, fontSize: 11),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (showSeenLabel && isOwn && message.status == MessageDeliveryStatus.read)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, right: 4),
                      child: Text(
                        AppStrings.chatSeen,
                        style: TextStyle(fontSize: 11, color: context.appColors.muted),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
