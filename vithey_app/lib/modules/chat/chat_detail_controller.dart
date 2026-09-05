import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/data/models/chat_args.dart';
import 'package:aub_connect_app/data/models/chat_message_model.dart';
import 'package:aub_connect_app/data/models/chat_participant.dart';
import 'package:aub_connect_app/data/repositories/chat_repository.dart';

class ChatDetailController extends GetxController {
  ChatDetailController(this._chatRepository);

  final ChatRepository _chatRepository;

  final messages = <ChatMessage>[].obs;
  final participant = Rxn<ChatParticipant>();
  final isLoading = true.obs;
  final isSending = false.obs;
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  String? _conversationId;
  bool _sendLocked = false;

  @override
  void onInit() {
    super.onInit();
    final args = ChatDetailArgs.from(Get.arguments);
    _conversationId = args.conversationId;
    _loadThread();
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
      await _chatRepository.markConversationRead(_conversationId!);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      Get.snackbar(AppStrings.appName, 'Could not load messages');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || _conversationId == null || _sendLocked) return;

    _sendLocked = true;
    isSending.value = true;
    final clientId = 'client-${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = ChatMessage(
      id: clientId,
      conversationId: _conversationId!,
      senderId: ChatRepository.currentUserId,
      text: text,
      createdAt: DateTime.now(),
      status: MessageDeliveryStatus.sending,
      isOwn: true,
      clientId: clientId,
    );
    messages.add(optimistic);
    messageController.clear();
    _scrollToBottom();

    try {
      final saved = await _chatRepository.sendMessage(
        conversationId: _conversationId!,
        text: text,
        clientId: clientId,
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
      );
      messages[index] = saved.copyWith(status: MessageDeliveryStatus.sent);
    } catch (_) {
      messages[index] = message.copyWith(isFailed: true, status: MessageDeliveryStatus.failed);
    }
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
      AlertDialog(
        title: const Text('Block this user?'),
        content: const Text('You will no longer receive messages from this person.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Get.back(result: true), child: const Text('Block')),
        ],
      ),
    );
    if (confirmed != true) return;
    await _chatRepository.blockConversation(_conversationId!);
    Get.back();
    Get.snackbar(AppStrings.appName, 'User blocked');
  }

  void _scrollToBottom() {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
