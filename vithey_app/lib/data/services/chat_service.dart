import 'package:aub_connect_app/core/constants/api_endpoints.dart';
import 'package:aub_connect_app/core/network/api_service.dart';
import 'package:aub_connect_app/data/models/chat_message_model.dart';
import 'package:aub_connect_app/data/models/chat_participant.dart';

class ChatService {
  ChatService(this._api);

  final ApiService _api;

  Future<List<ConversationModel>> fetchConversations({required int page, int limit = 20}) async {
    final response = await _api.get<List<ConversationModel>>(
      ApiEndpoints.conversations,
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (json) {
        final list = json as List<dynamic>? ?? [];
        return list.map((item) => _parseConversation(item as Map<String, dynamic>)).toList();
      },
    );
    if (!response.isSuccess || response.data == null) {
      throw ChatServiceException(response.error?.message ?? 'Failed to load conversations');
    }
    return response.data!;
  }

  Future<List<ChatMessage>> fetchMessages({
    required String conversationId,
    required int page,
    int limit = 30,
  }) async {
    final response = await _api.get<List<ChatMessage>>(
      ApiEndpoints.conversationMessages(conversationId),
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (json) {
        final list = json as List<dynamic>? ?? [];
        return list
            .map((item) => _parseMessage(item as Map<String, dynamic>, conversationId))
            .toList();
      },
    );
    if (!response.isSuccess || response.data == null) {
      throw ChatServiceException(response.error?.message ?? 'Failed to load messages');
    }
    return response.data!;
  }

  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String text,
    String? clientId,
    String? replyToMessageId,
  }) async {
    final response = await _api.post<ChatMessage>(
      ApiEndpoints.conversationMessages(conversationId),
      data: {
        'text': text,
        if (clientId != null) 'client_message_id': clientId,
        if (replyToMessageId != null) 'reply_to_message_id': replyToMessageId,
      },
      fromJson: (json) => _parseMessage(json as Map<String, dynamic>, conversationId, isOwn: true),
    );
    if (!response.isSuccess || response.data == null) {
      throw ChatServiceException(response.error?.message ?? 'Failed to send message');
    }
    return response.data!;
  }

  Future<void> markMessageRead(String messageId) async {
    final response = await _api.patch<void>(
      ApiEndpoints.messageRead(messageId),
      fromJson: (_) {},
    );
    if (!response.isSuccess) {
      throw ChatServiceException(response.error?.message ?? 'Failed to mark read');
    }
  }

  ConversationModel _parseConversation(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['conversation_id']?.toString() ?? json['id']?.toString() ?? '',
      participant: ChatParticipant.fromJson(json['participant'] as Map<String, dynamic>? ?? {}),
      lastMessagePreview: json['last_message_preview'] as String? ?? '',
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }

  ChatMessage _parseMessage(
    Map<String, dynamic> json,
    String conversationId, {
    bool isOwn = false,
  }) {
    return ChatMessage(
      id: json['message_id']?.toString() ?? json['id']?.toString() ?? '',
      conversationId: conversationId,
      senderId: json['sender_id']?.toString() ?? '',
      text: json['text'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      isOwn: isOwn || (json['is_own'] as bool? ?? false),
      replyToMessageId: json['reply_to_message_id']?.toString(),
      replyToPreview: (json['reply_to'] as Map<String, dynamic>?)?['text'] as String?,
      isDeleted: json['deleted_at'] != null,
    );
  }
}

class ChatServiceException implements Exception {
  ChatServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
