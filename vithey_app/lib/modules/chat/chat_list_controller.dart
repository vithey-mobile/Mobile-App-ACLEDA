import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/navigation/main_tab_navigation.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/data/models/chat_args.dart';
import 'package:aub_connect_app/data/models/chat_folder.dart';
import 'package:aub_connect_app/data/models/chat_message_model.dart';
import 'package:aub_connect_app/data/models/chat_participant.dart';
import 'package:aub_connect_app/data/models/search_args.dart';
import 'package:aub_connect_app/data/repositories/chat_repository.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class ChatListController extends GetxController {
  ChatListController(this._chatRepository, this._localStorage);

  final ChatRepository _chatRepository;
  final LocalStorageService _localStorage;

  final conversations = <ConversationModel>[].obs;
  final messageRequests = <MessageRequestModel>[].obs;
  final recentContacts = <ChatParticipant>[].obs;
  final customFolders = <ChatFolder>[].obs;
  final selectedFolderId = ChatFolderIds.all.obs;
  final isLoading = true.obs;
  final isRefreshing = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;
  /// True when contacts header is collapsed (scrolled) — used to hide folder border.
  final headerCollapsed = false.obs;

  final searchController = TextEditingController();
  final searchFocusNode = FocusNode();

  StreamSubscription<List<ConversationModel>>? _conversationSub;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
    _conversationSub =
        _chatRepository.watchConversations().listen(conversations.assignAll);
    _chatRepository.connectRealtime();
    _loadFolders();
    loadChatList();
  }

  Future<void> _loadFolders() async {
    try {
      final raw = await _localStorage.readChatFoldersJson();
      if (raw == null || raw.isEmpty) return;
      final list = jsonDecode(raw) as List<dynamic>;
      customFolders.assignAll(
        list
            .whereType<Map>()
            .map((e) => ChatFolder.fromJson(Map<String, dynamic>.from(e)))
            .where((f) => f.id.isNotEmpty && f.name.isNotEmpty),
      );
    } catch (_) {
      // Keep empty folders on parse errors.
    }
  }

  Future<void> _persistFolders() async {
    final json = jsonEncode(customFolders.map((f) => f.toJson()).toList());
    await _localStorage.saveChatFoldersJson(json);
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

  void selectFolder(String folderId) {
    selectedFolderId.value = folderId;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  List<ConversationModel> get filteredConversations {
    var list = conversations.toList();
    final folderId = selectedFolderId.value;

    if (folderId == ChatFolderIds.unread) {
      list = list.where((c) => c.unreadCount > 0).toList();
    } else if (folderId != ChatFolderIds.all) {
      final folder = customFolders.firstWhereOrNull((f) => f.id == folderId);
      if (folder != null) {
        final ids = folder.conversationIds.toSet();
        list = list.where((c) => ids.contains(c.id)).toList();
      }
    }

    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list
          .where((c) => c.participant.fullName.toLowerCase().contains(query))
          .toList();
    }
    return list;
  }

  int countForFolder(String folderId) {
    if (folderId == ChatFolderIds.all) return conversations.length;
    if (folderId == ChatFolderIds.unread) {
      return conversations.where((c) => c.unreadCount > 0).length;
    }
    final folder = customFolders.firstWhereOrNull((f) => f.id == folderId);
    if (folder == null) return 0;
    final ids = folder.conversationIds.toSet();
    return conversations.where((c) => ids.contains(c.id)).length;
  }

  Future<ChatFolder?> createFolder(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;
    final folder = ChatFolder(
      id: 'folder_${DateTime.now().millisecondsSinceEpoch}',
      name: trimmed,
    );
    customFolders.add(folder);
    await _persistFolders();
    return folder;
  }

  Future<void> renameFolder(String folderId, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final index = customFolders.indexWhere((f) => f.id == folderId);
    if (index < 0) return;
    customFolders[index] = customFolders[index].copyWith(name: trimmed);
    customFolders.refresh();
    await _persistFolders();
  }

  Future<void> deleteFolder(String folderId) async {
    customFolders.removeWhere((f) => f.id == folderId);
    if (selectedFolderId.value == folderId) {
      selectedFolderId.value = ChatFolderIds.all;
    }
    await _persistFolders();
  }

  Future<void> addConversationToFolder(
    String folderId,
    String conversationId,
  ) async {
    final index = customFolders.indexWhere((f) => f.id == folderId);
    if (index < 0) return;
    final folder = customFolders[index];
    if (folder.conversationIds.contains(conversationId)) return;
    customFolders[index] = folder.copyWith(
      conversationIds: [...folder.conversationIds, conversationId],
    );
    customFolders.refresh();
    await _persistFolders();
  }

  Future<void> removeConversationFromFolder(
    String folderId,
    String conversationId,
  ) async {
    final index = customFolders.indexWhere((f) => f.id == folderId);
    if (index < 0) return;
    final folder = customFolders[index];
    customFolders[index] = folder.copyWith(
      conversationIds:
          folder.conversationIds.where((id) => id != conversationId).toList(),
    );
    customFolders.refresh();
    await _persistFolders();
  }

  List<ChatFolder> foldersContaining(String conversationId) {
    return customFolders
        .where((f) => f.conversationIds.contains(conversationId))
        .toList();
  }

  void openConversation(String conversationId) {
    Get.toNamed(
      AppRoutes.chatDetail,
      arguments: ChatDetailArgs(conversationId: conversationId),
    )?.then((_) => refreshChatList());
  }

  Future<void> openAddChat() async {
    await Get.toNamed(
      AppRoutes.search,
      arguments: const SearchArgs(mode: SearchMode.pickUserForChat),
    );
  }

  void openContactChat(ChatParticipant contact) async {
    final conversationId =
        await _chatRepository.findOrCreateConversation(contact.id);
    openConversation(conversationId);
  }

  Future<void> acceptRequest(MessageRequestModel request) async {
    await _chatRepository.acceptMessageRequest(request.id);
    messageRequests.removeWhere((r) => r.id == request.id);
    final conversationId =
        await _chatRepository.findOrCreateConversation(request.requester.id);
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
          shad.Button.ghost(
            onPressed: () => Get.back(result: false),
            child: const shad.Text('Cancel'),
          ),
          shad.Button.primary(
            onPressed: () => Get.back(result: true),
            child: const shad.Text('Decline'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _chatRepository.declineMessageRequest(request.id);
    messageRequests.removeWhere((r) => r.id == request.id);
  }

  void onTabSelected(int index) {
    MainTabNavigation.handle(
      index,
      currentIndex: MainTabNavigation.home,
    );
  }

  @override
  void onClose() {
    _conversationSub?.cancel();
    searchController.dispose();
    searchFocusNode.dispose();
    super.onClose();
  }
}
