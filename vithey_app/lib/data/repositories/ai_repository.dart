import 'package:aub_connect_app/core/config/feature_flags.dart';
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
      final reply = _mockReply(message, topic);
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
      final reply = _mockRegenerateReply(userMessage.content);
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

  String _mockReply(String message, AiTopic? topic) {
    final lower = message.toLowerCase();
    if (lower.contains('cv') || lower.contains('resume') || topic == AiTopic.cv) {
      return 'Here are CV tips for AUB students:\n\n'
          '1. Keep it to one page with clear sections.\n'
          '2. Highlight projects and campus leadership.\n'
          '3. Tailor keywords to each job posting.\n\n'
          'Would you like help reviewing a specific section?';
    }
    if (lower.contains('interview') || topic == AiTopic.interview) {
      return 'For interview practice, try the STAR method:\n\n'
          '- **Situation** — set the context\n'
          '- **Task** — explain your responsibility\n'
          '- **Action** — describe what you did\n'
          '- **Result** — share the outcome\n\n'
          'Example opener:\n\n'
          '```text\n'
          'Hi, I am Kimheang — a final-year CS student passionate about mobile apps.\n'
          '```\n\n'
          'Tell me the role and I can suggest sample questions.';
    }
    if (lower.contains('job') || lower.contains('apply') || topic == AiTopic.job) {
      return 'When applying for campus jobs on Vithey:\n\n'
          '• Read the full job description before submitting.\n'
          '• Upload a PDF CV under 10 MB.\n'
          '• Add a short note explaining your fit.\n\n'
          'I can help you draft an application message.';
    }
    if (lower.contains('finance') || lower.contains('fee') || topic == AiTopic.finance) {
      return 'I can explain how Vithey Finance works, but I cannot access your actual balance or payment records.\n\n'
          'For real account details, open the Finance tab after student verification.';
    }
    return 'I\'m Vithey AI, your campus assistant. I can help with CVs, job applications, interview prep, student life, and general Finance guidance.\n\n'
        'What would you like to explore?';
  }

  String _mockRegenerateReply(String userMessage) {
    final lower = userMessage.toLowerCase();
    if (lower.contains('cv') || lower.contains('resume')) {
      return 'Here is an alternate CV outline:\n\n'
          '```text\n'
          'Contact | Summary | Education | Experience | Skills\n'
          '```\n\n'
          '- Lead with **measurable outcomes** (%, revenue, users).\n'
          '- Use action verbs: *designed*, *led*, *improved*.\n'
          '- Keep formatting consistent across sections.';
    }
    if (lower.contains('interview')) {
      return 'Alternate interview prep:\n\n'
          '1. Research the company mission and recent news.\n'
          '2. Prepare 3 STAR stories.\n'
          '3. Practice a 60-second self-introduction.\n\n'
          'Want role-specific question drills?';
    }
    return 'Here is another perspective:\n\n'
        '- Break the problem into smaller steps.\n'
        '- Validate assumptions with a quick checklist.\n'
        '- Ask me to go deeper on any step.';
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
    _mockSessions.addAll([
      AiSession(
        id: 'ai-session-1',
        title: 'CV review tips',
        topic: AiTopic.cv,
        isPinned: true,
        preview: 'Here are CV tips for AUB students…',
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      AiSession(
        id: 'ai-session-2',
        title: 'Interview STAR method',
        topic: AiTopic.interview,
        preview: 'For interview practice, try the STAR method…',
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);
    _mockMessages['ai-session-1'] = [
      AiMessage(
        id: 'm1',
        sessionId: 'ai-session-1',
        role: AiMessageRole.user,
        content: 'How can I improve my CV?',
        createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 5)),
      ),
      AiMessage(
        id: 'm2',
        sessionId: 'ai-session-1',
        role: AiMessageRole.assistant,
        content: _mockReply('cv', AiTopic.cv),
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
    _mockMessages['ai-session-2'] = [
      AiMessage(
        id: 'm3',
        sessionId: 'ai-session-2',
        role: AiMessageRole.user,
        content: 'Help me prepare for interviews',
        createdAt: DateTime.now().subtract(const Duration(days: 1, minutes: 10)),
      ),
      AiMessage(
        id: 'm4',
        sessionId: 'ai-session-2',
        role: AiMessageRole.assistant,
        content: _mockReply('interview', AiTopic.interview),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
    _sessionCounter = 2;
  }
}
