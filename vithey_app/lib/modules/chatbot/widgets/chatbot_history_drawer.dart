import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';
import 'package:aub_connect_app/modules/chatbot/chatbot_controller.dart';
import 'package:intl/intl.dart';

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
              child: ElevatedButton(
                onPressed: controller.newChat,
                child: const Text('New Chat'),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingSessions.value) {
                  return const LoadingWidget();
                }
                if (controller.sessions.isEmpty) {
                  return const Center(child: Text('No chat history yet'));
                }
                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    if (controller.pinnedSessions.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: Text('Pinned', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      ...controller.pinnedSessions.map((s) => _SessionTile(
                            session: s,
                            isSelected: controller.currentSessionId == s.id,
                            onTap: () => controller.selectSession(s.id),
                            onRename: () => controller.renameSession(s),
                            onPin: () => controller.togglePin(s),
                            onDelete: () => controller.deleteSession(s),
                          )),
                    ],
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text('Recent Chats', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ...controller.recentSessions.map((s) => _SessionTile(
                          session: s,
                          isSelected: controller.currentSessionId == s.id,
                          onTap: () => controller.selectSession(s.id),
                          onRename: () => controller.renameSession(s),
                          onPin: () => controller.togglePin(s),
                          onDelete: () => controller.deleteSession(s),
                        )),
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
    required this.onRename,
    required this.onPin,
    required this.onDelete,
  });

  final AiSession session;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onPin;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
      child: ListTile(
        onTap: onTap,
        title: Text(
          session.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          session.preview.isNotEmpty ? session.preview : _formatTime(session.updatedAt),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12),
        ),
        leading: session.isPinned ? const Icon(Icons.push_pin, size: 16, color: AppColors.primary) : null,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'rename':
                onRename();
              case 'pin':
                onPin();
              case 'delete':
                onDelete();
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'rename', child: Text('Rename')),
            PopupMenuItem(
              value: 'pin',
              child: Text(session.isPinned ? 'Unpin' : 'Pin'),
            ),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return DateFormat('MMM d, h:mm a').format(time);
  }
}
