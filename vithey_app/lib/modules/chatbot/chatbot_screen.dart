import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/navigation/main_tab_navigation.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
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
import 'package:aub_connect_app/modules/home/shell/main_shell_screen.dart';
import 'package:get/get.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  ChatbotController get controller => Get.find<ChatbotController>();

  @override
  void initState() {
    super.initState();
    controller.bindScaffold(_scaffoldKey);
  }

  @override
  void dispose() {
    controller.unbindScaffold(_scaffoldKey);
    super.dispose();
  }

  void _backToHome() {
    if (Get.key.currentState?.canPop() == true) {
      Get.back();
      return;
    }
    goToMainTab(MainTabNavigation.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: context.appColors.cardSurface,
      drawer: ChatbotHistoryDrawer(controller: controller),
      appBar: buildChatbotAppBar(
        onMenu: controller.openDrawer,
        onBackHome: _backToHome,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Obx(() {
                  if (controller.isLoadingMessages.value) {
                    return const LoadingWidget();
                  }
                  if (!controller.hasMessages) {
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: ChatbotSuggestionList(
                        items: ChatbotSuggestionList.defaultItems,
                        onPromptTap: controller.fillStarterPrompt,
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: controller.messages.length,
                    itemBuilder: (_, index) {
                      final message = controller.messages[index];
                      if (message.role == AiMessageRole.user) {
                        return UserMessageBubble(
                          content: message.content,
                          createdAt: message.createdAt,
                          attachments: message.attachments,
                        );
                      }
                      return AssistantMessage(
                        message: message,
                        onCopy: () =>
                            controller.copyMessage(message.content),
                        onShare: () =>
                            controller.shareMessage(message.content),
                        onRegenerate: message.isTerminal &&
                                controller.currentSessionId != null
                            ? () => controller.regenerateMessage(message)
                            : null,
                        onCodeCopied: controller.copyCodeBlock,
                      );
                    },
                  );
                }),
                Obx(() {
                  if (!controller.showJumpToLatest.value) {
                    return const SizedBox.shrink();
                  }
                  return Positioned(
                    right: 16,
                    bottom: 12,
                    child: JumpToLatestButton(
                      onTap: controller.forceScrollToBottom,
                    ),
                  );
                }),
              ],
            ),
          ),
          Obx(
            () => ChatbotComposer(
              controller: controller.inputController,
              isGenerating: controller.isGenerating.value,
              onSend: controller.sendMessage,
              onStop: controller.stopGenerating,
              attachments: List<ChatAttachment>.from(
                controller.pendingAttachments,
              ),
              onAddAttachment: controller.openAttachmentMenu,
              onRemoveAttachment: controller.removePendingAttachment,
            ),
          ),
          Obx(() {
            if (!controller.hasMessages) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Vithey AI may make mistakes. Verify important information.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: context.scheme.onSurfaceVariant,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
