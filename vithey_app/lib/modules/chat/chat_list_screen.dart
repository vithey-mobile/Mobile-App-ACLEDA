import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_assets.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/chat_message_model.dart';
import 'package:aub_connect_app/data/models/chat_participant.dart';
import 'package:aub_connect_app/modules/chat/chat_list_controller.dart';
import 'package:aub_connect_app/modules/home/widgets/home_bottom_navigation.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends GetView<ChatListController> {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(AppAssets.logoApp, width: 28, height: 28),
            const SizedBox(width: 8),
            Text(AppStrings.appName.split(' ').first),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingWidget();
        if (controller.hasError.value) {
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
              _RecentContactsRow(controller: controller),
              if (controller.messageRequests.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('Message Requests', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ...controller.messageRequests.map((request) => _RequestCard(
                      request: request,
                      onAccept: () => controller.acceptRequest(request),
                      onDecline: () => controller.declineRequest(request),
                    )),
              ],
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('Messages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              if (controller.filteredConversations.isEmpty)
                const EmptyStateWidget(
                  title: 'No messages yet',
                  subtitle: 'Start a conversation with Add Chat',
                )
              else
                ...controller.filteredConversations.map(
                  (conversation) => _ConversationTile(
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
        ),
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search conversations',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: controller.searchQuery.call,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RecentContactsRow extends StatelessWidget {
  const _RecentContactsRow({required this.controller});

  final ChatListController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _AddChatButton(onTap: controller.openAddChat),
          ...controller.recentContacts.map(
            (contact) => _ContactChip(
              contact: contact,
              onTap: () => controller.openContactChat(contact),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddChatButton extends StatelessWidget {
  const _AddChatButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: const Icon(Icons.add, color: AppColors.primary),
            ),
            const SizedBox(height: 6),
            const Text('Add Chat', style: TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _ContactChip extends StatelessWidget {
  const _ContactChip({required this.contact, required this.onTap});

  final ChatParticipant contact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            UserAvatar(name: contact.fullName, imageUrl: contact.avatarUrl, radius: 26),
            const SizedBox(height: 6),
            Text(
              contact.fullName.split(' ').first,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation, required this.onTap});

  final ConversationModel conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final time = _formatRelativeTime(conversation.updatedAt);
    return ListTile(
      onTap: onTap,
      leading: UserAvatar(
        name: conversation.participant.fullName,
        imageUrl: conversation.participant.avatarUrl,
        radius: 24,
      ),
      title: Text(conversation.participant.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        conversation.lastMessagePreview,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.authMuted),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(time, style: const TextStyle(fontSize: 12, color: AppColors.authMuted)),
          if (conversation.unreadCount > 0) ...[
            const SizedBox(height: 4),
            CircleAvatar(
              radius: 10,
              backgroundColor: AppColors.primary,
              child: Text(
                '${conversation.unreadCount}',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ] else if (conversation.lastMessageIsOwn)
            Icon(
              conversation.lastMessageStatus == MessageDeliveryStatus.read
                  ? Icons.done_all
                  : Icons.done,
              size: 16,
              color: conversation.lastMessageStatus == MessageDeliveryStatus.read
                  ? AppColors.primary
                  : AppColors.authMuted,
            ),
        ],
      ),
    );
  }

  String _formatRelativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return DateFormat('MMM d').format(time);
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
                  child: Text(request.requester.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(request.initialMessage),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: onDecline, child: const Text('Decline'))),
                const SizedBox(width: 8),
                Expanded(child: ElevatedButton(onPressed: onAccept, child: const Text('Accept'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
