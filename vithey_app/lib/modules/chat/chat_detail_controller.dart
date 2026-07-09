import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/data/models/chat_args.dart';
import 'package:aub_connect_app/data/models/chat_message_model.dart';
import 'package:aub_connect_app/data/models/chat_participant.dart';
import 'package:aub_connect_app/data/repositories/chat_repository.dart';
import 'package:aub_connect_app/modules/chat/widgets/chat_thread_search_sheet.dart';
import 'package:aub_connect_app/modules/chat/widgets/date_separator.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class ChatDetailController extends GetxController {
  ChatDetailController(this._chatRepository);

  final ChatRepository _chatRepository;

  final messages = <ChatMessage>[].obs;
  final participant = Rxn<ChatParticipant>();
  final isLoading = true.obs;
  final isSending = false.obs;
  final isTyping = false.obs;
  final showJumpToLatest = false.obs;
  final replyToMessage = Rxn<ChatMessage>();
  final threadSearchQuery = ''.obs;
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  String? _conversationId;
  bool _sendLocked = false;
  StreamSubscription<List<ChatMessage>>? _messageSub;
  StreamSubscription<List<ConversationModel>>? _conversationSub;
  final _pendingReadIds = <String>{};

  @override
  void onInit() {
    super.onInit();
    final args = ChatDetailArgs.from(Get.arguments);
    _conversationId = args.conversationId;
    _chatRepository.setActiveConversation(_conversationId);
    scrollController.addListener(_onScroll);
    _messageSub = _chatRepository
        .watchMessages(_conversationId!)
        .listen(_onMessagesUpdated);
    _conversationSub = _chatRepository.watchConversations().listen((conversations) {
      final match = conversations.where((c) => c.id == _conversationId).toList();
      if (match.isEmpty) return;
      isTyping.value = match.first.isTyping;
      participant.value = match.first.participant;
    });
    _loadThread();
  }

  void _onMessagesUpdated(List<ChatMessage> updated) {
    final wasAtBottom = _isNearBottom();
    messages.assignAll(updated);
    if (wasAtBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) => forceScrollToBottom());
    } else if (updated.isNotEmpty) {
      showJumpToLatest.value = true;
    }
    _markVisibleMessagesRead();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    showJumpToLatest.value = !_isNearBottom() && messages.isNotEmpty;
    if (_isNearBottom()) _markVisibleMessagesRead();
  }

  bool _isNearBottom() {
    if (!scrollController.hasClients) return true;
    final max = scrollController.position.maxScrollExtent;
    return scrollController.offset >= max - 80;
  }

  Future<void> _loadThread() async {
    if (_conversationId == null) return;
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _chatRepository.fetchMessages(conversationId: _conversationId!),
        _chatRepository.getConversation(_conversationId!),
      ]);
      messages.assignAll(results[0] as List<ChatMessage>);
      final conversation = results[1] as ConversationModel?;
      participant.value = conversation?.participant;
      isTyping.value = conversation?.isTyping ?? false;
      await _chatRepository.markConversationRead(_conversationId!);
      WidgetsBinding.instance.addPostFrameCallback((_) => forceScrollToBottom());
    } catch (e) {
      Get.snackbar(AppStrings.appName, 'Could not load messages');
    } finally {
      isLoading.value = false;
    }
  }

  bool get hasThreadSearch => threadSearchQuery.value.trim().isNotEmpty;

  List<ChatMessage> get visibleMessages {
    final query = threadSearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return messages;
    return messages
        .where((message) => !message.isDeleted && message.text.toLowerCase().contains(query))
        .toList();
  }

  void openThreadSearch() {
    showChatThreadSearchSheet(
      initialQuery: threadSearchQuery.value,
      onQueryChanged: (value) => threadSearchQuery.value = value,
      onClear: clearThreadSearch,
    );
  }

  void clearThreadSearch() => threadSearchQuery.value = '';

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || _conversationId == null || _sendLocked) return;

    _sendLocked = true;
    isSending.value = true;
    final clientId = 'client-${DateTime.now().millisecondsSinceEpoch}';
    final reply = replyToMessage.value;
    final optimistic = ChatMessage(
      id: clientId,
      conversationId: _conversationId!,
      senderId: ChatRepository.currentUserId,
      text: text,
      createdAt: DateTime.now(),
      status: MessageDeliveryStatus.sending,
      isOwn: true,
      clientId: clientId,
      replyToMessageId: reply?.id,
      replyToPreview: reply?.text,
    );
    messages.add(optimistic);
    messageController.clear();
    replyToMessage.value = null;
    forceScrollToBottom();

    try {
      final saved = await _chatRepository.sendMessage(
        conversationId: _conversationId!,
        text: text,
        clientId: clientId,
        replyToMessageId: reply?.id,
        replyToPreview: reply?.text,
      );
      final index = messages.indexWhere((m) => m.clientId == clientId);
      if (index >= 0) {
        messages[index] = saved.copyWith(status: MessageDeliveryStatus.sent);
      }
    } catch (_) {
      final index = messages.indexWhere((m) => m.clientId == clientId);
      if (index >= 0) {
        messages[index] = optimistic.copyWith(isFailed: true, status: MessageDeliveryStatus.failed);
      }
      Get.snackbar(AppStrings.appName, 'Message failed to send');
    } finally {
      isSending.value = false;
      _sendLocked = false;
    }
  }

  Future<void> retryMessage(ChatMessage message) async {
    if (_conversationId == null) return;
    final index = messages.indexWhere((m) => m.id == message.id);
    if (index < 0) return;
    messages[index] = message.copyWith(isFailed: false, status: MessageDeliveryStatus.sending);
    try {
      final saved = await _chatRepository.sendMessage(
        conversationId: _conversationId!,
        text: message.text,
        clientId: message.clientId,
        replyToMessageId: message.replyToMessageId,
        replyToPreview: message.replyToPreview,
      );
      messages[index] = saved.copyWith(status: MessageDeliveryStatus.sent);
    } catch (_) {
      messages[index] = message.copyWith(isFailed: true, status: MessageDeliveryStatus.failed);
    }
  }

  void setReplyTo(ChatMessage message) {
    if (message.isDeleted) return;
    replyToMessage.value = message;
  }

  void cancelReply() => replyToMessage.value = null;

  Future<void> copyMessage(ChatMessage message) async {
    await Clipboard.setData(ClipboardData(text: message.text));
    Get.snackbar(AppStrings.appName, 'Copied to clipboard');
  }

  Future<void> deleteMessage(ChatMessage message) async {
    final confirmed = await Get.dialog<bool>(
      shad.AlertDialog(
        title: const shad.Text('Delete message?'),
        content: const shad.Text('This message will be removed for you.'),
        actions: [
          shad.Button.ghost(onPressed: () => Get.back(result: false), child: const shad.Text('Cancel')),
          shad.Button.primary(onPressed: () => Get.back(result: true), child: const shad.Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    await _chatRepository.deleteMessage(message.id);
  }

  void showMessageActions(ChatMessage message) {
    if (message.isDeleted) return;
    Get.bottomSheet(
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Get.back();
                copyMessage(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                Get.back();
                setReplyTo(message);
              },
            ),
            if (message.isOwn)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete'),
                onTap: () {
                  Get.back();
                  deleteMessage(message);
                },
              ),
          ],
        ),
      ),
      backgroundColor: Get.theme.colorScheme.surface,
    );
  }

  void _markVisibleMessagesRead() {
    if (_conversationId == null) return;
    for (final message in messages) {
      if (!message.isOwn && message.status != MessageDeliveryStatus.read) {
        _pendingReadIds.add(message.id);
      }
    }
    if (_pendingReadIds.isEmpty) return;
    final ids = List<String>.from(_pendingReadIds);
    _pendingReadIds.clear();
    for (final id in ids) {
      _chatRepository.markMessageRead(id);
    }
  }

  void forceScrollToBottom() {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    showJumpToLatest.value = false;
  }

  bool shouldShowDateSeparator(int index, List<ChatMessage> source) {
    if (index == 0) return true;
    final current = source[index].createdAt;
    final previous = source[index - 1].createdAt;
    return DateSeparator.labelFor(current) != DateSeparator.labelFor(previous);
  }

  bool shouldShowAvatar(int index, List<ChatMessage> source) {
    final message = source[index];
    if (message.isOwn) return false;
    if (index == 0) return true;
    return source[index - 1].senderId != message.senderId;
  }

  bool shouldShowSeenLabel(int index, List<ChatMessage> source) {
    final message = source[index];
    if (!message.isOwn || message.status != MessageDeliveryStatus.read) return false;
    for (var i = index + 1; i < source.length; i++) {
      if (source[i].isOwn) return false;
    }
    return true;
  }

  bool shouldShowDateSeparatorInThread(int index) => shouldShowDateSeparator(index, visibleMessages);

  bool shouldShowAvatarInThread(int index) => shouldShowAvatar(index, visibleMessages);

  bool shouldShowSeenLabelInThread(int index) => shouldShowSeenLabel(index, visibleMessages);

  void handleHeaderMenu(String action) {
    switch (action) {
      case 'profile':
        openParticipantProfile();
      case 'block':
        blockConversation();
      case 'report':
        reportUser();
    }
  }

  Future<void> reportUser() async {
    final current = participant.value;
    if (current == null) return;
    final reasonController = TextEditingController();
    final confirmed = await Get.dialog<bool>(
      shad.AlertDialog(
        title: const shad.Text('Report user'),
        content: shad.TextField(
          controller: reasonController,
          hintText: 'Reason for report',
          maxLines: 3,
        ),
        actions: [
          shad.Button.ghost(onPressed: () => Get.back(result: false), child: const shad.Text('Cancel')),
          shad.Button.primary(onPressed: () => Get.back(result: true), child: const shad.Text('Report')),
        ],
      ),
    );
    if (confirmed != true) return;
    await _chatRepository.reportUser(current.id, reasonController.text.trim());
    reasonController.dispose();
    Get.snackbar(AppStrings.appName, 'Report submitted');
  }

  void openParticipantProfile() {
    final current = participant.value;
    if (current == null || _conversationId == null) return;
    Get.toNamed(
      AppRoutes.chatProfile,
      arguments: ChatProfileArgs(
        conversationId: _conversationId!,
        participantId: current.id,
      ),
    );
  }

  Future<void> blockConversation() async {
    if (_conversationId == null) return;
    final confirmed = await Get.dialog<bool>(
      shad.AlertDialog(
        title: const shad.Text('Block this user?'),
        content: const shad.Text('You will no longer receive messages from this person.'),
        actions: [
          shad.Button.ghost(onPressed: () => Get.back(result: false), child: const shad.Text('Cancel')),
          shad.Button.primary(onPressed: () => Get.back(result: true), child: const shad.Text('Block')),
        ],
      ),
    );
    if (confirmed != true) return;
    await _chatRepository.blockConversation(_conversationId!);
    Get.back();
    Get.snackbar(AppStrings.appName, 'User blocked');
  }

  @override
  void onClose() {
    _chatRepository.setActiveConversation(null);
    _messageSub?.cancel();
    _conversationSub?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
