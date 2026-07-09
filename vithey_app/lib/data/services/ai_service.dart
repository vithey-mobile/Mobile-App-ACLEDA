import 'package:aub_connect_app/core/constants/api_endpoints.dart';
import 'package:aub_connect_app/core/network/api_service.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';

class AiService {
  AiService(this._api);

  final ApiService _api;

  Future<AiChatResponse> sendChat({
    required String message,
    String? sessionId,
    AiTopic? topic,
  }) async {
    final response = await _api.post<AiChatResponse>(
      ApiEndpoints.aiChat,
      data: {
        'message': message,
        if (sessionId != null) 'session_id': sessionId,
        if (topic != null) 'topic': topic.name.toUpperCase(),
      },
      fromJson: (json) {
        final data = json as Map<String, dynamic>;
        return AiChatResponse(
          sessionId: data['session_id']?.toString() ?? sessionId ?? '',
          reply: data['reply'] as String? ?? '',
          messageId: data['message_id']?.toString(),
          requestId: data['request_id']?.toString(),
        );
      },
    );
    if (!response.isSuccess || response.data == null) {
      throw AiServiceException(response.error?.message ?? 'AI request failed');
    }
    return response.data!;
  }

  Future<List<AiSession>> fetchSessions({required int page, int limit = 20}) async {
    final response = await _api.get<List<AiSession>>(
      ApiEndpoints.aiSessions,
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (json) {
        final list = json as List<dynamic>? ?? [];
        return list.map((item) => _parseSession(item as Map<String, dynamic>)).toList();
      },
    );
    if (!response.isSuccess || response.data == null) {
      throw AiServiceException(response.error?.message ?? 'Failed to load sessions');
    }
    return response.data!;
  }

  Future<List<AiMessage>> fetchMessages({
    required String sessionId,
    required int page,
    int limit = 100,
  }) async {
    final response = await _api.get<List<AiMessage>>(
      ApiEndpoints.aiSessionMessages(sessionId),
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (json) {
        final list = json as List<dynamic>? ?? [];
        return list.map((item) => _parseMessage(item as Map<String, dynamic>, sessionId)).toList();
      },
    );
    if (!response.isSuccess || response.data == null) {
      throw AiServiceException(response.error?.message ?? 'Failed to load messages');
    }
    return response.data!;
  }

  Future<void> deleteSession(String sessionId) async {
    final response = await _api.delete<void>(
      ApiEndpoints.aiSessionById(sessionId),
      fromJson: (_) {},
    );
    if (!response.isSuccess) {
      throw AiServiceException(response.error?.message ?? 'Failed to delete session');
    }
  }

  AiSession _parseSession(Map<String, dynamic> json) {
    return AiSession(
      id: json['session_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] as String? ?? 'Chat',
      topic: _parseTopic(json['topic'] as String?),
      isPinned: json['is_pinned'] as bool? ?? false,
      preview: json['preview'] as String? ?? '',
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  AiMessage _parseMessage(Map<String, dynamic> json, String sessionId) {
    return AiMessage(
      id: json['message_id']?.toString() ?? json['id']?.toString() ?? '',
      sessionId: sessionId,
      role: _parseRole(json['role']),
      content: json['content'] as String? ?? json['text'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  AiMessageRole _parseRole(dynamic raw) {
    final value = raw?.toString().toLowerCase() ?? '';
    return value == 'user' ? AiMessageRole.user : AiMessageRole.assistant;
  }

  AiTopic? _parseTopic(String? raw) {
    switch (raw?.toUpperCase()) {
      case 'CV':
        return AiTopic.cv;
      case 'JOB':
        return AiTopic.job;
      case 'INTERVIEW':
        return AiTopic.interview;
      case 'STUDENT':
        return AiTopic.student;
      case 'FINANCE':
        return AiTopic.finance;
      default:
        return null;
    }
  }
}

class AiServiceException implements Exception {
  AiServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
