import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/assistant_message.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/chatbot_composer.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/chatbot_empty_state.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/chatbot_history_drawer.dart';
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
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: controller.openDrawer,
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Vithey AI',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: 'New Chat',
            onPressed: controller.newChat,
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
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
                    return ChatbotEmptyState(
                      prompts: ChatbotController.starterPrompts,
                      onPromptTap: controller.fillStarterPrompt,
                    );
                  }
                  return ListView.builder(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                    itemCount: controller.messages.length,
                    itemBuilder: (_, index) {
                      final message = controller.messages[index];
                      if (message.role == AiMessageRole.user) {
                        return UserMessageBubble(content: message.content);
                      }
                      return AssistantMessage(
                        message: message,
                        onCopy: () => controller.copyMessage(message.content),
                      );
                    },
                  );
                }),
                Obx(() {
                  if (!controller.showJumpToLatest.value) return const SizedBox.shrink();
                  return Positioned(
                    right: 16,
                    bottom: 12,
                    child: JumpToLatestButton(onTap: controller.scrollToBottom),
                  );
                }),
              ],
            ),
          ),
          Obx(() => ChatbotComposer(
                controller: controller.inputController,
                isGenerating: controller.isGenerating.value,
                onSend: controller.sendMessage,
                onStop: controller.stopGenerating,
              )),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Vithey AI may make mistakes. Verify important information.',
              style: TextStyle(fontSize: 11, color: context.scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
