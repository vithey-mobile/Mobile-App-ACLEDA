import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';
import 'package:aub_connect_app/data/repositories/ai_repository.dart';

class ChatbotController extends GetxController {
  ChatbotController(this._aiRepository);

  final AiRepository _aiRepository;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final sessions = <AiSession>[].obs;
  final messages = <AiMessage>[].obs;
  final isLoadingSessions = false.obs;
  final isLoadingMessages = false.obs;
  final isGenerating = false.obs;
  final showJumpToLatest = false.obs;

  final inputController = TextEditingController();
  final scrollController = ScrollController();

  String? _currentSessionId;
  AiTopic? _selectedTopic;
  final _drafts = <String, String>{};
  int _requestToken = 0;
  bool _sendLocked = false;

  static const starterPrompts = [
    'Help me improve my CV for campus jobs',
    'Practice interview questions for a marketing role',
    'How do I apply for jobs on Vithey?',
    'What student services does AUB offer?',
    'Explain how Vithey Finance verification works',
  ];

  bool get hasMessages => messages.isNotEmpty;
  String? get currentSessionId => _currentSessionId;

  List<AiSession> get pinnedSessions => sessions.where((s) => s.isPinned).toList();
  List<AiSession> get recentSessions => sessions.where((s) => !s.isPinned).toList();

  @override
  void onInit() {
    super.onInit();
    loadSessions();
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final max = scrollController.position.maxScrollExtent;
    final offset = scrollController.offset;
    showJumpToLatest.value = max - offset > 120;
  }

  Future<void> loadSessions() async {
    isLoadingSessions.value = true;
    try {
      sessions.assignAll(await _aiRepository.fetchSessions());
    } catch (e) {
      Get.snackbar(AppStrings.appName, 'Could not load chat history');
    } finally {
      isLoadingSessions.value = false;
    }
  }

  void openDrawer() => scaffoldKey.currentState?.openDrawer();

  void newChat() {
    _saveDraft();
    _currentSessionId = null;
    _selectedTopic = null;
    messages.clear();
    inputController.clear();
    scaffoldKey.currentState?.closeDrawer();
  }

  Future<void> selectSession(String sessionId) async {
    if (_currentSessionId == sessionId) {
      scaffoldKey.currentState?.closeDrawer();
      return;
    }
    _saveDraft();
    _currentSessionId = sessionId;
    final token = ++_requestToken;
    isLoadingMessages.value = true;
    messages.clear();
    inputController.text = _drafts[sessionId] ?? '';
    scaffoldKey.currentState?.closeDrawer();
    try {
      final loaded = await _aiRepository.fetchMessages(sessionId: sessionId);
      if (token != _requestToken) return;
      messages.assignAll(loaded);
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
    } catch (_) {
      Get.snackbar(AppStrings.appName, 'Could not load messages');
    } finally {
      if (token == _requestToken) isLoadingMessages.value = false;
    }
  }

  void fillStarterPrompt(String prompt) {
    inputController.text = prompt;
    inputController.selection = TextSelection.collapsed(offset: prompt.length);
  }

  Future<void> sendMessage() async {
    final text = inputController.text.trim();
    if (text.isEmpty || _sendLocked || isGenerating.value) return;

    _sendLocked = true;
    isGenerating.value = true;
    final clientId = 'client-${DateTime.now().millisecondsSinceEpoch}';
    final token = ++_requestToken;

    final userMessage = AiMessage(
      id: clientId,
      sessionId: _currentSessionId ?? 'draft',
      role: AiMessageRole.user,
      content: text,
      status: AiMessageStatus.complete,
      createdAt: DateTime.now(),
      clientId: clientId,
    );
    messages.add(userMessage);

    final thinking = AiMessage(
      id: 'thinking-$clientId',
      sessionId: _currentSessionId ?? 'draft',
      role: AiMessageRole.assistant,
      content: '',
      status: AiMessageStatus.thinking,
      createdAt: DateTime.now(),
    );
    messages.add(thinking);
    inputController.clear();
    _drafts.remove(_currentSessionId ?? 'draft');
    scrollToBottom();

    try {
      final response = await _aiRepository.sendMessage(
        message: text,
        sessionId: _currentSessionId,
        topic: _selectedTopic,
      );
      if (token != _requestToken) return;

      _currentSessionId = response.sessionId;
      messages.removeWhere((m) => m.id == thinking.id);
      messages.add(
        AiMessage(
          id: response.messageId ?? 'a-$clientId',
          sessionId: response.sessionId,
          role: AiMessageRole.assistant,
          content: response.reply,
          status: AiMessageStatus.complete,
          createdAt: DateTime.now(),
        ),
      );
      await loadSessions();
      scrollToBottom();
    } catch (e) {
      if (token != _requestToken) return;
      messages.removeWhere((m) => m.id == thinking.id);
      messages.add(
        AiMessage(
          id: 'err-$clientId',
          sessionId: _currentSessionId ?? 'draft',
          role: AiMessageRole.assistant,
          content: 'Sorry, I could not respond right now. Please try again.',
          status: AiMessageStatus.failed,
          createdAt: DateTime.now(),
        ),
      );
      inputController.text = text;
    } finally {
      if (token == _requestToken) {
        isGenerating.value = false;
        _sendLocked = false;
      }
    }
  }

  void stopGenerating() {
    if (!isGenerating.value) return;
    isGenerating.value = false;
    _sendLocked = false;
    final thinkingIndex = messages.indexWhere((m) => m.status == AiMessageStatus.thinking);
    if (thinkingIndex >= 0) {
      messages[thinkingIndex] = messages[thinkingIndex].copyWith(
        content: 'Response stopped.',
        status: AiMessageStatus.stopped,
      );
    }
  }

  Future<void> renameSession(AiSession session) async {
    final controller = TextEditingController(text: session.title);
    final saved = await Get.dialog<String>(
      AlertDialog(
        title: const Text('Rename chat'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Chat title'),
          maxLength: 80,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final title = controller.text.trim();
              if (title.isEmpty) return;
              Get.back(result: title);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved == null) return;
    await _aiRepository.renameSession(session.id, saved);
    await loadSessions();
  }

  Future<void> togglePin(AiSession session) async {
    await _aiRepository.togglePinSession(session.id);
    await loadSessions();
  }

  Future<void> deleteSession(AiSession session) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete chat?'),
        content: Text(
          'This will permanently delete "${session.title}" and its messages. This action can\'t be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _aiRepository.deleteSession(session.id);
    if (_currentSessionId == session.id) newChat();
    await loadSessions();
  }

  void scrollToBottom() {
    if (!scrollController.hasClients) return;
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    showJumpToLatest.value = false;
  }

  void _saveDraft() {
    final key = _currentSessionId ?? 'draft';
    final text = inputController.text;
    if (text.trim().isEmpty) {
      _drafts.remove(key);
    } else {
      _drafts[key] = text;
    }
  }

  void copyMessage(String content) {
    Get.snackbar(AppStrings.appName, 'Copied to clipboard');
  }

  @override
  void onClose() {
    inputController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
