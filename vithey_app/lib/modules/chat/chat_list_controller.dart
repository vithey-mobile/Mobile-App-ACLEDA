import 'dart:async';

import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/data/models/chat_args.dart';
import 'package:aub_connect_app/data/models/chat_message_model.dart';
import 'package:aub_connect_app/data/models/chat_participant.dart';
import 'package:aub_connect_app/data/models/profile_args.dart';
import 'package:aub_connect_app/data/models/search_args.dart';
import 'package:aub_connect_app/data/repositories/chat_repository.dart';
import 'package:aub_connect_app/data/repositories/profile_repository.dart';
import 'package:aub_connect_app/data/repositories/student_verification_repository.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

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

  StreamSubscription<List<ConversationModel>>? _conversationSub;

  @override
  void onInit() {
    super.onInit();
    _conversationSub = _chatRepository.watchConversations().listen(conversations.assignAll);
    _chatRepository.connectRealtime();
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
    await Get.toNamed(
      AppRoutes.search,
      arguments: const SearchArgs(mode: SearchMode.pickUserForChat),
    );
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
      shad.AlertDialog(
        title: const shad.Text('Decline request?'),
        content: const shad.Text(
          'This person will not be able to message you unless they send a new request.',
        ),
        actions: [
          shad.Button.ghost(onPressed: () => Get.back(result: false), child: const shad.Text('Cancel')),
          shad.Button.primary(onPressed: () => Get.back(result: true), child: const shad.Text('Decline')),
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
          arguments: ProfileArgs(userId: ProfileRepository.currentUserId),
        );
        break;
    }
  }

  @override
  void onClose() {
    _conversationSub?.cancel();
    super.onClose();
  }
}
