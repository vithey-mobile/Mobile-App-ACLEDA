import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/app_screen_body.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/assistant_message.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/chatbot_app_bar.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/chatbot_composer.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/chatbot_history_drawer.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/chatbot_suggestion_list.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/user_message_bubble.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/jump_to_latest_button.dart';
import 'package:aub_connect_app/modules/chatbot/chatbot_controller.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:get/get.dart';

class ChatbotScreen extends GetView<ChatbotController> {
  const ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      drawer: ChatbotHistoryDrawer(controller: controller),
      appBar: buildChatbotAppBar(
        onMenu: controller.openDrawer,
        onNewChat: controller.newChat,
      ),
      body: AppScreenBody(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Obx(() {
                    if (controller.isLoadingMessages.value) {
                      return const LoadingWidget();
                    }
                    if (!controller.hasMessages) {
                      return const SizedBox.expand();
                    }
                    return ListView.builder(
                      controller: controller.scrollController,
                      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                      itemCount: controller.messages.length,
                      itemBuilder: (_, index) {
                        final message = controller.messages[index];
                        if (message.role == AiMessageRole.user) {
                          return UserMessageBubble(
                            content: message.content,
                            createdAt: message.createdAt,
                          );
                        }
                        return AssistantMessage(
                          message: message,
                          onCopy: () => controller.copyMessage(message.content),
                          onShare: () => controller.shareMessage(message.content),
                          onRegenerate: message.isTerminal && controller.currentSessionId != null
                              ? () => controller.regenerateMessage(message)
                              : null,
                          onCodeCopied: controller.copyCodeBlock,
                        );
                      },
                    );
                  }),
                  Obx(() {
                    if (!controller.showJumpToLatest.value) return const SizedBox.shrink();
                    return Positioned(
                      right: 16,
                      bottom: 12,
                      child: JumpToLatestButton(onTap: controller.forceScrollToBottom),
                    );
                  }),
                ],
              ),
            ),
            Obx(() {
              final showSuggestions = !controller.hasMessages && !controller.isLoadingMessages.value;
              if (!showSuggestions) return const SizedBox.shrink();
              return ChatbotSuggestionList(
                items: ChatbotSuggestionList.defaultItems,
                onPromptTap: controller.fillStarterPrompt,
              );
            }),
            Obx(() => ChatbotComposer(
                  controller: controller.inputController,
                  isGenerating: controller.isGenerating.value,
                  onSend: controller.sendMessage,
                  onStop: controller.stopGenerating,
                  onAttachment: controller.showAttachmentComingSoon,
                )),
            Obx(() {
              if (!controller.hasMessages) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Vithey AI may make mistakes. Verify important information.',
                  style: TextStyle(fontSize: 11, color: context.scheme.onSurfaceVariant),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
