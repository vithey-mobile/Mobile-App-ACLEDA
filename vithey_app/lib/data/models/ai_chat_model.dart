enum AiTopic { cv, job, interview, student, finance }

enum AiMessageRole { user, assistant }

enum AiMessageStatus { sending, thinking, streaming, complete, failed, stopped }

class AiSession {
  AiSession({
    required this.id,
    required this.title,
    this.topic,
    this.isPinned = false,
    this.preview = '',
    required this.updatedAt,
  });

  final String id;
  final String title;
  final AiTopic? topic;
  final bool isPinned;
  final String preview;
  final DateTime updatedAt;

  AiSession copyWith({
    String? title,
    bool? isPinned,
    String? preview,
    DateTime? updatedAt,
  }) {
    return AiSession(
      id: id,
      title: title ?? this.title,
      topic: topic,
      isPinned: isPinned ?? this.isPinned,
      preview: preview ?? this.preview,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AiMessage {
  AiMessage({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    this.status = AiMessageStatus.complete,
    required this.createdAt,
    this.clientId,
  });

  final String id;
  final String sessionId;
  final AiMessageRole role;
  final String content;
  final AiMessageStatus status;
  final DateTime createdAt;
  final String? clientId;

  bool get isThinking => status == AiMessageStatus.thinking;

  AiMessage copyWith({
    String? id,
    String? content,
    AiMessageStatus? status,
  }) {
    return AiMessage(
      id: id ?? this.id,
      sessionId: sessionId,
      role: role,
      content: content ?? this.content,
      status: status ?? this.status,
      createdAt: createdAt,
      clientId: clientId,
    );
  }
}

class AiChatResponse {
  const AiChatResponse({
    required this.sessionId,
    required this.reply,
    this.messageId,
  });

  final String sessionId;
  final String reply;
  final String? messageId;
}
