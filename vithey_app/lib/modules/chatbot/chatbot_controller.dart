import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';
import 'package:aub_connect_app/data/repositories/ai_repository.dart';
import 'package:aub_connect_app/modules/chatbot/utils/ai_api_error.dart';

class ChatbotController extends GetxController {
  ChatbotController(this._aiRepository);

  final AiRepository _aiRepository;
  final _imagePicker = ImagePicker();
  GlobalKey<ScaffoldState>? scaffoldKey;

  final sessions = <AiSession>[].obs;
  final messages = <AiMessage>[].obs;
  final isLoadingSessions = false.obs;
  final isLoadingMessages = false.obs;
  final isGenerating = false.obs;
  final showJumpToLatest = false.obs;
  final pendingAttachments = <ChatAttachment>[].obs;

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
  bool get hasPendingAttachments => pendingAttachments.isNotEmpty;

  List<AiSession> get pinnedSessions =>
      sessions.where((s) => s.isPinned).toList();
  List<AiSession> get recentSessions =>
      sessions.where((s) => !s.isPinned).toList();

  List<AiSession> get sortedSessions {
    final list = List<AiSession>.from(sessions);
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  @override
  void onInit() {
    super.onInit();
    loadSessions();
    scrollController.addListener(_onScroll);
    final initialPrompt = Get.arguments;
    if (initialPrompt is String && initialPrompt.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => fillStarterPrompt(initialPrompt.trim()));
    }
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final max = scrollController.position.maxScrollExtent;
    final offset = scrollController.offset;
    showJumpToLatest.value = max - offset > 120;
  }

  bool get _isNearBottom {
    if (!scrollController.hasClients) return true;
    final max = scrollController.position.maxScrollExtent;
    final offset = scrollController.offset;
    return max - offset < 120;
  }

  Future<void> loadSessions() async {
    isLoadingSessions.value = true;
    try {
      sessions.assignAll(await _aiRepository.fetchSessions());
    } catch (e) {
      Get.snackbar(AppStrings.appName, aiApiErrorMessage(e));
    } finally {
      isLoadingSessions.value = false;
    }
  }

  void bindScaffold(GlobalKey<ScaffoldState> key) => scaffoldKey = key;

  void unbindScaffold(GlobalKey<ScaffoldState> key) {
    if (identical(scaffoldKey, key)) scaffoldKey = null;
  }

  void openDrawer() => scaffoldKey?.currentState?.openDrawer();

  void closeDrawer() => scaffoldKey?.currentState?.closeDrawer();

  Future<void> openAttachmentMenu() async {
    if (isGenerating.value) return;
    final choice = await Get.bottomSheet<String>(
      SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Get.theme.dividerColor,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_outlined),
                title: const Text('Photo'),
                onTap: () => Get.back(result: 'photo'),
              ),
              ListTile(
                leading: const Icon(Icons.videocam_outlined),
                title: const Text('Video'),
                onTap: () => Get.back(result: 'video'),
              ),
              ListTile(
                leading: const Icon(Icons.attach_file_rounded),
                title: const Text('File'),
                onTap: () => Get.back(result: 'file'),
              ),
            ],
          ),
        ),
      ),
    );

    switch (choice) {
      case 'photo':
        await pickPhoto();
      case 'video':
        await pickVideo();
      case 'file':
        await pickFile();
    }
  }

  Future<void> pickPhoto() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;
      _addAttachment(
        ChatAttachment(
          path: picked.path,
          name: picked.name,
          kind: ChatAttachmentKind.photo,
        ),
      );
    } catch (_) {
      Get.snackbar(AppStrings.appName, 'Could not pick photo');
    }
  }

  Future<void> pickVideo() async {
    try {
      final picked = await _imagePicker.pickVideo(source: ImageSource.gallery);
      if (picked == null) return;
      _addAttachment(
        ChatAttachment(
          path: picked.path,
          name: picked.name,
          kind: ChatAttachmentKind.video,
        ),
      );
    } catch (_) {
      Get.snackbar(AppStrings.appName, 'Could not pick video');
    }
  }

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;
      final path = file.path;
      if (path == null || path.isEmpty) {
        Get.snackbar(AppStrings.appName, 'Could not read that file');
        return;
      }
      final name = file.name;
      final lower = name.toLowerCase();
      final kind = (lower.endsWith('.png') ||
              lower.endsWith('.jpg') ||
              lower.endsWith('.jpeg') ||
              lower.endsWith('.gif') ||
              lower.endsWith('.webp'))
          ? ChatAttachmentKind.photo
          : (lower.endsWith('.mp4') ||
                  lower.endsWith('.mov') ||
                  lower.endsWith('.avi') ||
                  lower.endsWith('.mkv'))
              ? ChatAttachmentKind.video
              : ChatAttachmentKind.file;
      _addAttachment(ChatAttachment(path: path, name: name, kind: kind));
    } catch (_) {
      Get.snackbar(AppStrings.appName, 'Could not pick file');
    }
  }

  void _addAttachment(ChatAttachment attachment) {
    if (pendingAttachments.length >= 5) {
      Get.snackbar(AppStrings.appName, 'You can attach up to 5 items');
      return;
    }
    if (pendingAttachments.any((a) => a.path == attachment.path)) return;
    pendingAttachments.add(attachment);
  }

  void removePendingAttachment(ChatAttachment attachment) {
    pendingAttachments.removeWhere((a) => a.path == attachment.path);
  }

  void clearPendingAttachments() => pendingAttachments.clear();

  void newChat() {
    _saveDraft();
    _currentSessionId = null;
    _selectedTopic = null;
    messages.clear();
    inputController.clear();
    clearPendingAttachments();
    closeDrawer();
  }

  Future<void> selectSession(String sessionId) async {
    if (_currentSessionId == sessionId) {
      closeDrawer();
      return;
    }
    _saveDraft();
    _currentSessionId = sessionId;
    final token = ++_requestToken;
    isLoadingMessages.value = true;
    messages.clear();
    clearPendingAttachments();
    inputController.text = _drafts[sessionId] ?? '';
    closeDrawer();
    try {
      final loaded = await _aiRepository.fetchMessages(sessionId: sessionId);
      if (token != _requestToken) return;
      messages.assignAll(loaded);
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
    } catch (e) {
      if (token != _requestToken) return;
      Get.snackbar(AppStrings.appName, aiApiErrorMessage(e));
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
    final attachments = List<ChatAttachment>.from(pendingAttachments);
    if ((text.isEmpty && attachments.isEmpty) ||
        _sendLocked ||
        isGenerating.value) {
      return;
    }

    _sendLocked = true;
    isGenerating.value = true;
    final clientId = 'client-${DateTime.now().millisecondsSinceEpoch}';
    final token = ++_requestToken;

    final displayContent = text;
    final apiMessage = _buildApiMessage(text, attachments);

    final userMessage = AiMessage(
      id: clientId,
      sessionId: _currentSessionId ?? 'draft',
      role: AiMessageRole.user,
      content: displayContent,
      status: AiMessageStatus.complete,
      createdAt: DateTime.now(),
      clientId: clientId,
      attachments: attachments,
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
    clearPendingAttachments();
    _drafts.remove(_currentSessionId ?? 'draft');
    scrollToBottom();

    try {
      final response = await _aiRepository.sendMessage(
        message: apiMessage,
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
          content: aiApiErrorMessage(e),
          status: AiMessageStatus.failed,
          createdAt: DateTime.now(),
        ),
      );
      inputController.text = text;
      pendingAttachments.assignAll(attachments);
    } finally {
      if (token == _requestToken) {
        isGenerating.value = false;
        _sendLocked = false;
      }
    }
  }

  String _buildApiMessage(String text, List<ChatAttachment> attachments) {
    if (attachments.isEmpty) return text;
    final labels = attachments.map((a) {
      return switch (a.kind) {
        ChatAttachmentKind.photo => 'Photo: ${a.name}',
        ChatAttachmentKind.video => 'Video: ${a.name}',
        ChatAttachmentKind.file => 'File: ${a.name}',
      };
    }).join('\n');
    if (text.isEmpty) {
      return 'I attached:\n$labels\nPlease review and help me with this.';
    }
    return '$text\n\nAttached:\n$labels';
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

  Future<void> regenerateMessage(AiMessage assistantMessage) async {
    if (_currentSessionId == null || isGenerating.value) return;
    final index = messages.indexWhere((m) => m.id == assistantMessage.id);
    if (index < 0) return;

    _sendLocked = true;
    isGenerating.value = true;
    final token = ++_requestToken;

    messages[index] = assistantMessage.copyWith(
      content: '',
      status: AiMessageStatus.thinking,
    );
    scrollToBottom();

    try {
      final response = await _aiRepository.regenerateMessage(
        sessionId: _currentSessionId!,
        assistantMessageId: assistantMessage.id,
      );
      if (token != _requestToken) return;

      messages[index] = AiMessage(
        id: response.messageId ?? assistantMessage.id,
        sessionId: response.sessionId,
        role: AiMessageRole.assistant,
        content: response.reply,
        status: AiMessageStatus.complete,
        createdAt: DateTime.now(),
      );
      await loadSessions();
      scrollToBottom();
    } catch (_) {
      if (token != _requestToken) return;
      messages[index] = assistantMessage;
      Get.snackbar(AppStrings.appName, 'Could not regenerate response');
    } finally {
      if (token == _requestToken) {
        isGenerating.value = false;
        _sendLocked = false;
      }
    }
  }

  Future<void> renameSession(AiSession session) async {
    final titleController = TextEditingController(text: session.title);
    final saved = await Get.dialog<String>(
      AlertDialog(
        title: const Text('Rename chat'),
        content: TextField(
          controller: titleController,
          autofocus: true,
          maxLength: 80,
          decoration: const InputDecoration(
            hintText: 'Chat title',
            labelText: 'Title',
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (value) {
            final title = value.trim();
            if (title.isEmpty) return;
            Get.back(result: title);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isEmpty) return;
              Get.back(result: title);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    titleController.dispose();
    if (saved == null || saved.isEmpty) return;
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
        title: const Text('Delete this chat?'),
        content: Text(
          '“${session.title}” and all its messages will be permanently deleted. This can’t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
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
    if (!_isNearBottom && messages.length > 2) return;
    if (!scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
      showJumpToLatest.value = false;
    });
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

  void _saveDraft() {
    final key = _currentSessionId ?? 'draft';
    final text = inputController.text;
    if (text.trim().isEmpty) {
      _drafts.remove(key);
    } else {
      _drafts[key] = text;
    }
  }

  Future<void> copyMessage(String content) async {
    await Clipboard.setData(ClipboardData(text: content));
    Get.snackbar(AppStrings.appName, 'Copied to clipboard');
  }

  Future<void> copyCodeBlock(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    Get.snackbar(AppStrings.appName, 'Code copied');
  }

  Future<void> shareMessage(String content) async {
    await Share.share(content, subject: 'Vithey AI response');
  }

  @override
  void onClose() {
    inputController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
