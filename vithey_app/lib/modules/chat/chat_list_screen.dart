import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/core/widgets/shimmer_list_tile.dart';
import 'package:aub_connect_app/data/models/chat_message_model.dart';
import 'package:aub_connect_app/modules/chat/chat_list_controller.dart';
import 'package:aub_connect_app/modules/chat/widgets/add_chat_contacts_row.dart';
import 'package:aub_connect_app/modules/chat/widgets/chat_list_app_bar.dart';
import 'package:aub_connect_app/modules/chat/widgets/conversation_list_tile.dart';
import 'package:aub_connect_app/modules/home/widgets/home_bottom_navigation.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class ChatListScreen extends GetView<ChatListController> {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bodyBackground,
      appBar: const ChatListAppBar(),
      body: Obx(() {
        if (controller.isLoading.value && controller.conversations.isEmpty) {
          return ListView.builder(
            itemCount: 5,
            itemBuilder: (_, __) => const ShimmerListTile(),
          );
        }
        if (controller.hasError.value && controller.conversations.isEmpty) {
          return AppErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.loadChatList,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshChatList,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              AddChatContactsRow(
                contacts: controller.recentContacts,
                onAddChat: controller.openAddChat,
                onContactTap: controller.openContactChat,
              ),
              if (controller.messageRequests.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    AppStrings.chatMessageRequests,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: context.appColors.heading,
                    ),
                  ),
                ),
                ...controller.messageRequests.map(
                  (request) => _RequestCard(
                    request: request,
                    onAccept: () => controller.acceptRequest(request),
                    onDecline: () => controller.declineRequest(request),
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  AppStrings.chatMessages,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.appColors.heading,
                  ),
                ),
              ),
              if (controller.filteredConversations.isEmpty)
                const EmptyStateWidget(
                  title: AppStrings.chatNoMessages,
                  subtitle: AppStrings.chatNoMessagesSubtitle,
                )
              else
                ...controller.filteredConversations.map(
                  (conversation) => ConversationListTile(
                    conversation: conversation,
                    onTap: () => controller.openConversation(conversation.id),
                  ),
                ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.onTabSelected(2),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Obx(
        () => HomeBottomNavigation(
          currentIndex: controller.currentTab.value,
          onTap: controller.onTabSelected,
          usePillHighlight: true,
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.onAccept,
    required this.onDecline,
  });

  final MessageRequestModel request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UserAvatar(name: request.requester.fullName, radius: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    request.requester.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(request.initialMessage),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: shad.Button.outline(
                    onPressed: onDecline,
                    child: const shad.Text('Decline'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: shad.Button.primary(
                    onPressed: onAccept,
                    child: const shad.Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
