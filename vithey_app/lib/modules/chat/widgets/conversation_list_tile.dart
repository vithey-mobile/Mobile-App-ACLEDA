import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/utils/relative_time.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/chat_message_model.dart';

class ConversationListTile extends StatelessWidget {
  const ConversationListTile({
    super.key,
    required this.conversation,
    required this.onTap,
    this.onLongPress,
  });

  final ConversationModel conversation;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  String get _subtitle {
    if (conversation.isTyping) return AppStrings.chatTyping;
    if (conversation.lastMessageIsOwn) {
      return 'You: ${conversation.lastMessagePreview}';
    }
    return conversation.lastMessagePreview;
  }

  bool get _showReadCheck =>
      !conversation.isTyping &&
      conversation.unreadCount == 0 &&
      conversation.lastMessageIsOwn &&
      conversation.lastMessageStatus == MessageDeliveryStatus.read;

  @override
  Widget build(BuildContext context) {
    final hasUnread = conversation.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: conversation.participant.isOnline
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              child: UserAvatar(
                name: conversation.participant.fullName,
                imageUrl: conversation.participant.avatarUrl,
                radius: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.participant.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                      fontSize: 16,
                      color: context.appColors.heading,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: conversation.isTyping ? AppColors.primary : context.appColors.muted,
                      fontWeight: conversation.isTyping ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (hasUnread)
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      conversation.unreadCount > 99 ? '99+' : '${conversation.unreadCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  )
                else if (_showReadCheck)
                  const Icon(Icons.done_all, size: 18, color: AppColors.primary),
                const SizedBox(height: 6),
                Text(
                  RelativeTime.formatChatList(conversation.updatedAt),
                  style: TextStyle(fontSize: 12, color: context.appColors.muted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
