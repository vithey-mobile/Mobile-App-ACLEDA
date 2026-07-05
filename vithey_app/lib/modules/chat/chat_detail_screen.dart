import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/chat_message_model.dart';
import 'package:aub_connect_app/modules/chat/chat_detail_controller.dart';
import 'package:intl/intl.dart';

class ChatDetailScreen extends GetView<ChatDetailController> {
  const ChatDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Obx(() {
          final p = controller.participant.value;
          if (p == null) return const Text('Chat');
          return InkWell(
            onTap: controller.openParticipantProfile,
            child: Row(
              children: [
                UserAvatar(name: p.fullName, imageUrl: p.avatarUrl, radius: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.fullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      if (p.isOnline)
                        const Text('Active now', style: TextStyle(fontSize: 12, color: AppColors.success)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: controller.blockConversation),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const LoadingWidget();
              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                itemCount: controller.messages.length,
                itemBuilder: (_, index) {
                  final message = controller.messages[index];
                  final showAvatar = !message.isOwn &&
                      (index == 0 || controller.messages[index - 1].senderId != message.senderId);
                  return _MessageBubble(
                    message: message,
                    showAvatar: showAvatar,
                    participantName: controller.participant.value?.fullName ?? '',
                    onRetry: () => controller.retryMessage(message),
                  );
                },
              );
            }),
          ),
          _Composer(
            controller: controller.messageController,
            isSending: controller.isSending,
            onSend: controller.sendMessage,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.showAvatar,
    required this.participantName,
    required this.onRetry,
  });

  final ChatMessage message;
  final bool showAvatar;
  final String participantName;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isOwn = message.isOwn;
    final bubbleColor = isOwn ? AppColors.primary : Colors.white;
    final textColor = isOwn ? Colors.white : AppColors.authHeading;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isOwn && showAvatar)
            UserAvatar(name: participantName, radius: 14)
          else if (!isOwn)
            const SizedBox(width: 28),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isOwn ? 16 : 4),
                      bottomRight: Radius.circular(isOwn ? 4 : 16),
                    ),
                    border: isOwn ? null : Border.all(color: AppColors.authBorder),
                  ),
                  child: Text(message.text, style: TextStyle(color: textColor)),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('h:mm a').format(message.createdAt),
                      style: const TextStyle(fontSize: 11, color: AppColors.authMuted),
                    ),
                    if (isOwn) ...[
                      const SizedBox(width: 4),
                      _StatusIcon(status: message.status),
                    ],
                    if (message.isFailed) ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: onRetry,
                        child: const Text('Retry', style: TextStyle(color: AppColors.error, fontSize: 11)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});

  final MessageDeliveryStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageDeliveryStatus.read:
        return const Icon(Icons.done_all, size: 14, color: AppColors.primaryLight);
      case MessageDeliveryStatus.delivered:
      case MessageDeliveryStatus.sent:
        return const Icon(Icons.done_all, size: 14, color: Colors.white70);
      case MessageDeliveryStatus.sending:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white70),
        );
      case MessageDeliveryStatus.failed:
        return const Icon(Icons.error_outline, size: 14, color: AppColors.error);
    }
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final RxBool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write a message…',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            Obx(() => CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: isSending.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: isSending.value ? null : onSend,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
