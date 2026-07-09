import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';
import 'package:aub_connect_app/modules/chatbot/chatbot_controller.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class ChatbotHistoryDrawer extends StatelessWidget {
  const ChatbotHistoryDrawer({super.key, required this.controller});

  final ChatbotController controller;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.82,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: shad.Button.primary(
                onPressed: () {
                  controller.newChat();
                  Get.back();
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_comment_outlined, size: 20, color: Colors.white),
                    SizedBox(width: 8),
                    shad.Text('New Chat'),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingSessions.value) {
                  return const LoadingWidget();
                }
                final sessions = controller.sortedSessions;
                if (sessions.isEmpty) {
                  return const Center(child: Text('No chat history yet'));
                }
                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Text(
                        'Recent Chats',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.muted,
                        ),
                      ),
                    ),
                    ...sessions.map(
                      (s) => _SessionTile(
                        session: s,
                        isSelected: controller.currentSessionId == s.id,
                        onTap: () => controller.selectSession(s.id),
                        onDelete: () => controller.deleteSession(s),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.session,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  final AiSession session;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Text(
                    session.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                tooltip: 'Delete chat',
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
