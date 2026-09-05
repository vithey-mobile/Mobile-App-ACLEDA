import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aub_connect_app/data/models/chat_message_model.dart';
import 'package:aub_connect_app/data/models/chat_participant.dart';
import 'package:aub_connect_app/data/services/chat_service.dart';

class ChatRepository {
  ChatRepository(this._chatService);

  final ChatService _chatService;

  static const currentUserId = 'mock-user';

  bool get useMockApi => dotenv.env['USE_MOCK_API']?.toLowerCase() != 'false';

  final _mockMessages = <String, List<ChatMessage>>{};
  final _mockConversations = <ConversationModel>[];

  Future<List<ConversationModel>> fetchConversations({int page = 1}) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 450));
      _ensureMockSeed();
      return List<ConversationModel>.from(_mockConversations);
    }
    return _chatService.fetchConversations(page: page);
  }

  Future<List<MessageRequestModel>> fetchMessageRequests() async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return [
        MessageRequestModel(
          id: 'req-1',
          requester: const ChatParticipant(
            id: 'author-4',
            fullName: 'Sreynich Chan',
            bio: 'Business student',
          ),
          initialMessage: 'Hi! I saw your post about the campus event.',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
      ];
    }
    return [];
  }

  Future<List<ChatParticipant>> fetchRecentContacts() async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return const [
        ChatParticipant(id: 'author-1', fullName: 'Heng Liza'),
        ChatParticipant(id: 'author-2', fullName: 'Molika Khorn'),
        ChatParticipant(id: 'author-3', fullName: 'AUB Career Center'),
        ChatParticipant(id: 'author-4', fullName: 'Sreynich Chan'),
      ];
    }
    return [];
  }

  Future<List<ChatMessage>> fetchMessages({
    required String conversationId,
    int page = 1,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      _ensureMockSeed();
      return List<ChatMessage>.from(_mockMessages[conversationId] ?? []);
    }
    return _chatService.fetchMessages(conversationId: conversationId, page: page);
  }

  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String text,
    String? clientId,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final message = ChatMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        conversationId: conversationId,
        senderId: currentUserId,
        text: text,
        createdAt: DateTime.now(),
        status: MessageDeliveryStatus.sent,
        isOwn: true,
        clientId: clientId,
      );
      _mockMessages.putIfAbsent(conversationId, () => []).add(message);
      _updateConversationPreview(conversationId, text, isOwn: true);
      return message;
    }
    return _chatService.sendMessage(
      conversationId: conversationId,
      text: text,
      clientId: clientId,
    );
  }

  Future<ConversationModel?> getConversation(String conversationId) async {
    if (useMockApi) {
      _ensureMockSeed();
      try {
        return _mockConversations.firstWhere((c) => c.id == conversationId);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<ChatParticipant?> getParticipant({
    required String conversationId,
    required String participantId,
  }) async {
    final conversation = await getConversation(conversationId);
    if (conversation != null && conversation.participant.id == participantId) {
      final p = conversation.participant;
      return ChatParticipant(
        id: p.id,
        fullName: p.fullName,
        avatarUrl: p.avatarUrl,
        bio: _bioFor(p.id),
        location: p.id == 'author-1' ? 'Phnom Penh' : null,
        isOnline: p.isOnline,
      );
    }
    return null;
  }

  String? _bioFor(String id) {
    switch (id) {
      case 'author-1':
        return 'Graphic designer and campus event organizer.';
      case 'author-2':
        return 'Content creator sharing student life and career tips.';
      case 'author-3':
        return 'Official career opportunities for AUB students.';
      default:
        return null;
    }
  }

  Future<void> markConversationRead(String conversationId) async {
    if (useMockApi) {
      final index = _mockConversations.indexWhere((c) => c.id == conversationId);
      if (index >= 0) {
        _mockConversations[index] = _mockConversations[index].copyWith(unreadCount: 0);
      }
      return;
    }
  }

  Future<String> findOrCreateConversation(String participantId) async {
    if (useMockApi) {
      _ensureMockSeed();
      final existing = _mockConversations.where((c) => c.participant.id == participantId);
      if (existing.isNotEmpty) return existing.first.id;
      final contact = (await fetchRecentContacts()).firstWhere(
        (c) => c.id == participantId,
        orElse: () => ChatParticipant(id: participantId, fullName: 'New Contact'),
      );
      final id = 'conv-new-${DateTime.now().millisecondsSinceEpoch}';
      _mockConversations.insert(
        0,
        ConversationModel(
          id: id,
          participant: contact,
          lastMessagePreview: '',
          updatedAt: DateTime.now(),
        ),
      );
      _mockMessages[id] = [];
      return id;
    }
    return participantId;
  }

  Future<void> acceptMessageRequest(String requestId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  Future<void> declineMessageRequest(String requestId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  Future<void> blockConversation(String conversationId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (useMockApi) {
      _mockConversations.removeWhere((c) => c.id == conversationId);
    }
  }

  Future<void> reportUser(String userId, String reason) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  void _updateConversationPreview(String conversationId, String preview, {required bool isOwn}) {
    final index = _mockConversations.indexWhere((c) => c.id == conversationId);
    if (index >= 0) {
      _mockConversations[index] = _mockConversations[index].copyWith(
        lastMessagePreview: preview,
        updatedAt: DateTime.now(),
        lastMessageIsOwn: isOwn,
        lastMessageStatus: MessageDeliveryStatus.sent,
        unreadCount: 0,
      );
      final item = _mockConversations.removeAt(index);
      _mockConversations.insert(0, item);
    }
  }

  void _ensureMockSeed() {
    if (_mockConversations.isNotEmpty) return;

    _mockConversations.addAll([
      ConversationModel(
        id: 'conv-1',
        participant: const ChatParticipant(id: 'author-1', fullName: 'Heng Liza', isOnline: true),
        lastMessagePreview: 'See you at the workshop tomorrow!',
        updatedAt: DateTime.now().subtract(const Duration(minutes: 12)),
        unreadCount: 2,
        lastMessageIsOwn: false,
      ),
      ConversationModel(
        id: 'conv-2',
        participant: const ChatParticipant(id: 'author-2', fullName: 'Molika Khorn'),
        lastMessagePreview: 'Thanks for sharing the video tips.',
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        unreadCount: 0,
        lastMessageIsOwn: true,
        lastMessageStatus: MessageDeliveryStatus.read,
      ),
      ConversationModel(
        id: 'conv-3',
        participant: const ChatParticipant(id: 'author-3', fullName: 'AUB Career Center'),
        lastMessagePreview: 'Your application has been received.',
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 1,
        lastMessageIsOwn: false,
      ),
    ]);

    _mockMessages['conv-1'] = [
      ChatMessage(
        id: 'm1',
        conversationId: 'conv-1',
        senderId: 'author-1',
        text: 'Hey! Are you joining the design workshop?',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      ChatMessage(
        id: 'm2',
        conversationId: 'conv-1',
        senderId: currentUserId,
        text: 'Yes, I registered yesterday.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        isOwn: true,
        status: MessageDeliveryStatus.read,
      ),
      ChatMessage(
        id: 'm3',
        conversationId: 'conv-1',
        senderId: 'author-1',
        text: 'See you at the workshop tomorrow!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
    ];

    _mockMessages['conv-2'] = [
      ChatMessage(
        id: 'm4',
        conversationId: 'conv-2',
        senderId: currentUserId,
        text: 'Thanks for sharing the video tips.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isOwn: true,
        status: MessageDeliveryStatus.read,
      ),
      ChatMessage(
        id: 'm5',
        conversationId: 'conv-2',
        senderId: 'author-2',
        text: 'Happy to help! Let me know if you need more.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
      ),
    ];

    _mockMessages['conv-3'] = [
      ChatMessage(
        id: 'm6',
        conversationId: 'conv-3',
        senderId: 'author-3',
        text: 'Your application has been received.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}
