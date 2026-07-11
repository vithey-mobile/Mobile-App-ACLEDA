import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/data/fixtures/ai_fixtures.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';

import 'package:aub_connect_app/data/services/ai_service.dart';

class AiRepository {
  AiRepository(this._aiService, this._flags);

  final AiService _aiService;
  final FeatureFlags _flags;

  bool get useMockApi => _flags.useMockAi;

  final _mockSessions = <AiSession>[];
  final _mockMessages = <String, List<AiMessage>>{};
  int _sessionCounter = 0;

  Future<List<AiSession>> fetchSessions({int page = 1}) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      _ensureMockSeed();
      final sorted = List<AiSession>.from(_mockSessions)
        ..sort((a, b) {
          if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
          return b.updatedAt.compareTo(a.updatedAt);
        });
      return sorted;
    }
    return _aiService.fetchSessions(page: page);
  }

  Future<List<AiMessage>> fetchMessages({required String sessionId, int page = 1}) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      _ensureMockSeed();
      return List<AiMessage>.from(_mockMessages[sessionId] ?? []);
    }
    return _aiService.fetchMessages(sessionId: sessionId, page: page);
  }

  Future<AiChatResponse> sendMessage({
    required String message,
    String? sessionId,
    AiTopic? topic,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      final sid = sessionId ?? _createMockSession(message, topic);
      final userMsg = AiMessage(
        id: 'u-${DateTime.now().millisecondsSinceEpoch}',
        sessionId: sid,
        role: AiMessageRole.user,
        content: message,
        createdAt: DateTime.now(),
      );
      _mockMessages.putIfAbsent(sid, () => []).add(userMsg);
      final reply = AiFixtures.mockReply(message, topic);
      final assistantMsg = AiMessage(
        id: 'a-${DateTime.now().millisecondsSinceEpoch}',
        sessionId: sid,
        role: AiMessageRole.assistant,
        content: reply,
        createdAt: DateTime.now(),
      );
      _mockMessages[sid]!.add(assistantMsg);
      _updateSessionPreview(sid, message, reply);
      return AiChatResponse(sessionId: sid, reply: reply, messageId: assistantMsg.id);
    }
    return _aiService.sendChat(
      message: message,
      sessionId: sessionId,
      topic: topic ?? _inferTopic(message),
    );
  }

  Future<void> deleteSession(String sessionId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      _mockSessions.removeWhere((s) => s.id == sessionId);
      _mockMessages.remove(sessionId);
      return;
    }
    await _aiService.deleteSession(sessionId);
  }

  Future<void> renameSession(String sessionId, String title) async {
    if (useMockApi) {
      final index = _mockSessions.indexWhere((s) => s.id == sessionId);
      if (index >= 0) {
        _mockSessions[index] = _mockSessions[index].copyWith(title: title.trim());
      }
      return;
    }
  }

  Future<void> togglePinSession(String sessionId) async {
    if (useMockApi) {
      final index = _mockSessions.indexWhere((s) => s.id == sessionId);
      if (index >= 0) {
        _mockSessions[index] = _mockSessions[index].copyWith(
          isPinned: !_mockSessions[index].isPinned,
        );
      }
      return;
    }
  }

  Future<AiChatResponse> regenerateMessage({
    required String sessionId,
    required String assistantMessageId,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      final history = _mockMessages[sessionId];
      if (history == null) throw AiServiceException('Session not found');
      final index = history.indexWhere((m) => m.id == assistantMessageId);
      if (index < 0) throw AiServiceException('Message not found');
      AiMessage? userMessage;
      for (var i = index - 1; i >= 0; i--) {
        if (history[i].role == AiMessageRole.user) {
          userMessage = history[i];
          break;
        }
      }
      if (userMessage == null) throw AiServiceException('No user message to regenerate from');
      final reply = AiFixtures.mockRegenerateReply(userMessage.content);
      final assistantMsg = AiMessage(
        id: 'a-${DateTime.now().millisecondsSinceEpoch}',
        sessionId: sessionId,
        role: AiMessageRole.assistant,
        content: reply,
        createdAt: DateTime.now(),
      );
      history[index] = assistantMsg;
      _updateSessionPreview(sessionId, userMessage.content, reply);
      return AiChatResponse(sessionId: sessionId, reply: reply, messageId: assistantMsg.id);
    }
    throw AiServiceException('Regenerate is not available yet');
  }

  String _createMockSession(String firstMessage, AiTopic? topic) {
    _sessionCounter++;
    final id = 'ai-session-$_sessionCounter';
    final title = firstMessage.length > 40 ? '${firstMessage.substring(0, 40)}…' : firstMessage;
    _mockSessions.insert(
      0,
      AiSession(
        id: id,
        title: title.isEmpty ? 'New Chat' : title,
        topic: topic,
        updatedAt: DateTime.now(),
      ),
    );
    _mockMessages[id] = [];
    return id;
  }

  void _updateSessionPreview(String sessionId, String userText, String reply) {
    final index = _mockSessions.indexWhere((s) => s.id == sessionId);
    if (index >= 0) {
      _mockSessions[index] = _mockSessions[index].copyWith(
        preview: reply.length > 60 ? '${reply.substring(0, 60)}…' : reply,
        updatedAt: DateTime.now(),
      );
    }
  }

  AiTopic? _inferTopic(String message) {
    final lower = message.toLowerCase();
    if (RegExp(r'\b(cv|resume)\b').hasMatch(lower)) return AiTopic.cv;
    if (lower.contains('interview')) return AiTopic.interview;
    if (RegExp(r'\b(job|apply|application)\b').hasMatch(lower)) return AiTopic.job;
    if (RegExp(r'\b(finance|fee|payment|balance)\b').hasMatch(lower)) return AiTopic.finance;
    if (lower.contains('student')) return AiTopic.student;
    return null;
  }

  void _ensureMockSeed() {
    if (_mockSessions.isNotEmpty) return;
    _mockSessions.addAll(AiFixtures.buildSessions());
    _mockMessages.addAll(
      AiFixtures.buildMessages().map(
        (key, value) => MapEntry(key, List<AiMessage>.from(value)),
      ),
    );
    _sessionCounter = 3;
  }
}
