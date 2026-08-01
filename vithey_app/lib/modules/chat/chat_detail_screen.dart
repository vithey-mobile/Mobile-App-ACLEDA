import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/modules/chat/chat_detail_controller.dart';
import 'package:aub_connect_app/modules/chat/widgets/chat_composer.dart';
import 'package:aub_connect_app/modules/chat/widgets/chat_detail_header.dart';
import 'package:aub_connect_app/modules/chat/widgets/chat_emoji_panel.dart';
import 'package:aub_connect_app/modules/chat/widgets/date_separator.dart';
import 'package:aub_connect_app/modules/chat/widgets/jump_to_latest_chip.dart';
import 'package:aub_connect_app/modules/chat/widgets/message_bubble.dart';
import 'package:aub_connect_app/modules/chat/widgets/reply_preview_bar.dart';
import 'package:aub_connect_app/modules/chat/widgets/typing_indicator_banner.dart';

class ChatDetailScreen extends GetView<ChatDetailController> {
  const ChatDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.inputFill,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(
          () => ChatDetailHeader(
            participant: controller.participant.value,
            isTyping: controller.isTyping.value,
            onBack: Get.back,
            onProfileTap: controller.openParticipantProfile,
            onSearch: controller.openThreadSearch,
            onMenu: controller.handleHeaderMenu,
          ),
        ),
      ),
      body: Column(
        children: [
          Obx(() {
            if (!controller.hasThreadSearch) return const SizedBox.shrink();
            return Material(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.35),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${AppStrings.chatThreadSearchHint}: ${controller.threadSearchQuery.value}',
                        style: TextStyle(fontSize: 13, color: context.appColors.muted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: controller.clearThreadSearch,
                      child: const Text(AppStrings.clearSearch),
                    ),
                  ],
                ),
              ),
            );
          }),
          Expanded(
            child: Stack(
              children: [
                Obx(() {
                  if (controller.isLoading.value && controller.messages.isEmpty) {
                    return const LoadingWidget();
                  }
                  final visible = controller.visibleMessages;
                  if (!controller.isLoading.value && visible.isEmpty) {
                    return Center(
                      child: Text(
                        controller.hasThreadSearch
                            ? AppStrings.chatThreadSearchEmpty
                            : AppStrings.chatSayHello,
                        style: TextStyle(color: context.appColors.muted),
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    itemCount: visible.length,
                    itemBuilder: (_, index) {
                      final message = visible[index];
                      return Column(
                        children: [
                          if (controller.shouldShowDateSeparatorInThread(index))
                            DateSeparator(date: message.createdAt),
                          MessageBubble(
                            message: message,
                            showAvatar: controller.shouldShowAvatarInThread(index),
                            participantName: controller.participant.value?.fullName ?? '',
                            participantAvatarUrl: controller.participant.value?.avatarUrl,
                            onRetry: () => controller.retryMessage(message),
                            onLongPress: () => controller.showMessageActions(message),
                            onReactionTap: (emoji) =>
                                controller.reactToMessage(message, emoji),
                            showSeenLabel: controller.shouldShowSeenLabelInThread(index),
                          ),
                        ],
                      );
                    },
                  );
                }),
                Obx(() {
                  if (!controller.showJumpToLatest.value) return const SizedBox.shrink();
                  return Positioned(
                    left: 0,
                    right: 0,
                    bottom: 8,
                    child: JumpToLatestChip(onTap: controller.forceScrollToBottom),
                  );
                }),
              ],
            ),
          ),
          Obx(() {
            if (controller.isTyping.value) {
              return TypingIndicatorBanner(
                participantName: controller.participant.value?.fullName ?? 'Someone',
              );
            }
            return const SizedBox.shrink();
          }),
          Obx(() {
            final reply = controller.replyToMessage.value;
            if (reply == null) return const SizedBox.shrink();
            return ReplyPreviewBar(
              preview: reply.text,
              onCancel: controller.cancelReply,
            );
          }),
          Obx(
            () => ChatComposer(
              controller: controller.messageController,
              isSending: controller.isSending,
              onSend: () {
                controller.hideEmojiPanel();
                controller.sendMessage();
              },
              attachments: List.from(controller.pendingAttachments),
              onAddAttachment: controller.openAttachmentMenu,
              onRemoveAttachment: controller.removePendingAttachment,
              showEmojiPanel: controller.showEmojiPanel.value,
              onToggleEmoji: () {
                FocusManager.instance.primaryFocus?.unfocus();
                controller.toggleEmojiPanel();
              },
              onFocusText: controller.hideEmojiPanel,
            ),
          ),
          Obx(() {
            if (!controller.showEmojiPanel.value) {
              return const SizedBox.shrink();
            }
            return ChatEmojiPanel(
              onEmojiSelected: controller.insertEmoji,
            );
          }),
        ],
      ),
    );
  }
}
