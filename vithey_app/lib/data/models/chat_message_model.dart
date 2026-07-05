import 'package:aub_connect_app/data/models/chat_participant.dart';

enum ConversationStatus { active, pending, blocked, declined }

enum MessageDeliveryStatus { sending, sent, delivered, read, failed }

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    this.status = MessageDeliveryStatus.sent,
    this.isOwn = false,
    this.clientId,
    this.isFailed = false,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final MessageDeliveryStatus status;
  final bool isOwn;
  final String? clientId;
  final bool isFailed;

  ChatMessage copyWith({
    String? id,
    MessageDeliveryStatus? status,
    bool? isFailed,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId,
      senderId: senderId,
      text: text,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      isOwn: isOwn,
      clientId: clientId,
      isFailed: isFailed ?? this.isFailed,
    );
  }
}

class ConversationModel {
  const ConversationModel({
    required this.id,
    required this.participant,
    required this.lastMessagePreview,
    required this.updatedAt,
    this.unreadCount = 0,
    this.status = ConversationStatus.active,
    this.lastMessageIsOwn = false,
    this.lastMessageStatus = MessageDeliveryStatus.sent,
  });

  final String id;
  final ChatParticipant participant;
  final String lastMessagePreview;
  final DateTime updatedAt;
  final int unreadCount;
  final ConversationStatus status;
  final bool lastMessageIsOwn;
  final MessageDeliveryStatus lastMessageStatus;

  ConversationModel copyWith({
    String? lastMessagePreview,
    DateTime? updatedAt,
    int? unreadCount,
    MessageDeliveryStatus? lastMessageStatus,
    bool? lastMessageIsOwn,
  }) {
    return ConversationModel(
      id: id,
      participant: participant,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
      status: status,
      lastMessageIsOwn: lastMessageIsOwn ?? this.lastMessageIsOwn,
      lastMessageStatus: lastMessageStatus ?? this.lastMessageStatus,
    );
  }
}

class MessageRequestModel {
  const MessageRequestModel({
    required this.id,
    required this.requester,
    required this.initialMessage,
    required this.createdAt,
  });

  final String id;
  final ChatParticipant requester;
  final String initialMessage;
  final DateTime createdAt;
}
