import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/data/models/chat_args.dart';
import 'package:aub_connect_app/data/models/chat_message_model.dart';
import 'package:aub_connect_app/data/models/chat_participant.dart';
import 'package:aub_connect_app/data/models/profile_args.dart';
import 'package:aub_connect_app/data/repositories/chat_repository.dart';
import 'package:aub_connect_app/data/repositories/profile_repository.dart';
import 'package:aub_connect_app/data/repositories/student_verification_repository.dart';

class ChatListController extends GetxController {
  ChatListController(this._chatRepository);

  final ChatRepository _chatRepository;

  final conversations = <ConversationModel>[].obs;
  final messageRequests = <MessageRequestModel>[].obs;
  final recentContacts = <ChatParticipant>[].obs;
  final isLoading = true.obs;
  final isRefreshing = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final currentTab = 3.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadChatList();
  }

  Future<void> loadChatList() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final results = await Future.wait([
        _chatRepository.fetchConversations(),
        _chatRepository.fetchMessageRequests(),
        _chatRepository.fetchRecentContacts(),
      ]);
      conversations.assignAll(results[0] as List<ConversationModel>);
      messageRequests.assignAll(results[1] as List<MessageRequestModel>);
      recentContacts.assignAll(results[2] as List<ChatParticipant>);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshChatList() async {
    isRefreshing.value = true;
    try {
      await loadChatList();
    } finally {
      isRefreshing.value = false;
    }
  }

  List<ConversationModel> get filteredConversations {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return conversations;
    return conversations
        .where((c) => c.participant.fullName.toLowerCase().contains(query))
        .toList();
  }

  void openConversation(String conversationId) {
    Get.toNamed(AppRoutes.chatDetail, arguments: ChatDetailArgs(conversationId: conversationId))
        ?.then((_) => refreshChatList());
  }

  Future<void> openAddChat() async {
    final contacts = recentContacts;
    if (contacts.isEmpty) {
      Get.snackbar(AppStrings.appName, 'No contacts available');
      return;
    }
    final selected = await Get.dialog<ChatParticipant>(
      _AddChatDialog(contacts: contacts),
    );
    if (selected == null) return;
    final conversationId = await _chatRepository.findOrCreateConversation(selected.id);
    openConversation(conversationId);
  }

  void openContactChat(ChatParticipant contact) async {
    final conversationId = await _chatRepository.findOrCreateConversation(contact.id);
    openConversation(conversationId);
  }

  Future<void> acceptRequest(MessageRequestModel request) async {
    await _chatRepository.acceptMessageRequest(request.id);
    messageRequests.removeWhere((r) => r.id == request.id);
    final conversationId = await _chatRepository.findOrCreateConversation(request.requester.id);
    openConversation(conversationId);
  }

  Future<void> declineRequest(MessageRequestModel request) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Decline request?'),
        content: const Text('This person will not be able to message you unless they send a new request.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Get.back(result: true), child: const Text('Decline')),
        ],
      ),
    );
    if (confirmed != true) return;
    await _chatRepository.declineMessageRequest(request.id);
    messageRequests.removeWhere((r) => r.id == request.id);
  }

  void onTabSelected(int index) {
    currentTab.value = index;
    switch (index) {
      case 0:
        Get.offNamed(AppRoutes.home);
        break;
      case 1:
        FinanceNavigation.openFinanceEntry();
        currentTab.value = 3;
        break;
      case 2:
        Get.offNamed(AppRoutes.createPost);
        break;
      case 3:
        break;
      case 4:
        Get.offNamed(
          AppRoutes.profile,
          arguments: const ProfileArgs(userId: ProfileRepository.currentUserId),
        );
        break;
    }
  }
}

class _AddChatDialog extends StatelessWidget {
  const _AddChatDialog({required this.contacts});

  final List<ChatParticipant> contacts;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Start a chat'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: contacts.length,
          itemBuilder: (_, index) {
            final contact = contacts[index];
            return ListTile(
              title: Text(contact.fullName),
              onTap: () => Get.back(result: contact),
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
      ],
    );
  }
}
