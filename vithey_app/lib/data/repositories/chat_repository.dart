import 'dart:async';

import 'package:get/get.dart';
import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/core/constants/mock_identities.dart';
import 'package:aub_connect_app/core/session/current_user_service.dart';
import 'package:aub_connect_app/data/local/isar/chat_isar_mapper.dart';
import 'package:aub_connect_app/data/local/isar/isar_service.dart';
import 'package:aub_connect_app/data/models/chat_message_model.dart';
import 'package:aub_connect_app/data/models/chat_participant.dart';
import 'package:aub_connect_app/data/models/chat_shared_content_model.dart';
import 'package:aub_connect_app/data/models/chat_stomp_payload.dart';
import 'package:aub_connect_app/data/services/chat_service.dart';
import 'package:aub_connect_app/data/services/chat_stomp_service.dart';

class ChatRepository {
  ChatRepository(
    this._chatService,
    this._isar,
    this._stomp,
    this._flags,
  );

  final ChatService _chatService;
  final IsarService _isar;
  final ChatStompService _stomp;
  final FeatureFlags _flags;

  static String get currentUserId {
    if (Get.isRegistered<CurrentUserService>()) {
      return Get.find<CurrentUserService>().userId;
    }
    return MockIdentities.mockUserId;
  }
  String? activeConversationId;

  bool get useMockApi => _flags.useMockChat;

  final _mockMessages = <String, List<ChatMessage>>{};
  final _mockConversations = <ConversationModel>[];

  Stream<List<ConversationModel>> watchConversations() {
    return _isar.watchConversations().map(
          (list) => list.map(ChatIsarMapper.fromLocalConversation).toList(),
        );
  }

  Stream<List<ChatMessage>> watchMessages(String conversationId) {
    return _isar.watchMessages(conversationId).map(
          (list) => list.map(ChatIsarMapper.fromLocalMessage).toList(),
        );
  }

  Future<void> connectRealtime({String? jwt}) async {
    await _stomp.connect(jwt: jwt);
  }

  void setActiveConversation(String? conversationId) {
    activeConversationId = conversationId;
    _stomp.setActiveConversation(conversationId);
  }

  Future<void> handleStompPayload(ChatStompPayload payload) async {
    switch (payload.type) {
      case ChatStompEventType.typing:
        if (payload.conversationId.isEmpty) return;
        await _isar.setTyping(payload.conversationId, payload.isTyping ?? false);
        return;
      case ChatStompEventType.readReceipt:
        if (payload.messageId == null) return;
        await _markMessageStatus(payload.messageId!, MessageDeliveryStatus.read);
        return;
      case ChatStompEventType.message:
        await _ingestInboundMessage(payload);
        return;
    }
  }

  Future<void> _ingestInboundMessage(ChatStompPayload payload) async {
    if (payload.conversationId.isEmpty || payload.messageId == null) return;
    final isOwn = payload.senderId == currentUserId;
    final message = ChatMessage(
      id: payload.messageId!,
      conversationId: payload.conversationId,
      senderId: payload.senderId ?? '',
      text: payload.text ?? '',
      createdAt: payload.createdAt ?? DateTime.now(),
      status: _parseStatus(payload.status),
      isOwn: isOwn,
    );
    await _isar.upsertMessage(ChatIsarMapper.toLocalMessage(message));
    await _upsertConversationPreview(
      payload.conversationId,
      preview: message.text,
      isOwn: isOwn,
      incrementUnread: !isOwn && _stomp.shouldIncrementUnread(payload.conversationId),
    );
  }

  MessageDeliveryStatus _parseStatus(String? raw) {
    return switch (raw?.toUpperCase()) {
      'READ' => MessageDeliveryStatus.read,
      'DELIVERED' => MessageDeliveryStatus.delivered,
      'SENT' => MessageDeliveryStatus.sent,
      _ => MessageDeliveryStatus.delivered,
    };
  }

  Future<void> _markMessageStatus(String messageId, MessageDeliveryStatus status) async {
    final messages = await _isar.findMessagesByMessageId(messageId);
    for (final local in messages) {
      local.status = status.name;
      await _isar.upsertMessage(local);
    }
  }

  Future<List<ConversationModel>> fetchConversations({int page = 1}) async {
    List<ConversationModel> remote;
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      await _ensureMockSeed();
      remote = List<ConversationModel>.from(_mockConversations);
    } else {
      remote = await _chatService.fetchConversations(page: page);
    }
    await _isar.upsertConversations(remote.map(ChatIsarMapper.toLocalConversation).toList());
    return remote;
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
        ChatParticipant(id: 'author-1', fullName: 'Heng Liza', isOnline: true),
        ChatParticipant(id: 'author-5', fullName: 'Meas Lily', isOnline: true),
        ChatParticipant(id: 'author-7', fullName: 'Moeng Kimheang', isOnline: true),
        ChatParticipant(id: 'author-6', fullName: 'Ponloeng Bora'),
      ];
    }
    return [];
  }

  Future<List<ChatMessage>> fetchMessages({
    required String conversationId,
    int page = 1,
  }) async {
    List<ChatMessage> remote;
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await _ensureMockSeed();
      remote = List<ChatMessage>.from(_mockMessages[conversationId] ?? []);
    } else {
      remote = await _chatService.fetchMessages(conversationId: conversationId, page: page);
    }
    await _isar.upsertMessages(remote.map(ChatIsarMapper.toLocalMessage).toList());
    return remote;
  }

  Future<ChatMessage> sendMessage({
    required String conversationId,
    required String text,
    String? clientId,
    String? replyToMessageId,
    String? replyToPreview,
  }) async {
    final cid = clientId ?? 'client-${DateTime.now().millisecondsSinceEpoch}';
    await _isar.enqueueOutbox(
      ChatIsarMapper.toOutbox(
        clientId: cid,
        conversationId: conversationId,
        text: text,
        replyToMessageId: replyToMessageId,
      ),
    );

    ChatMessage saved;
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      saved = ChatMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        conversationId: conversationId,
        senderId: currentUserId,
        text: text,
        createdAt: DateTime.now(),
        status: MessageDeliveryStatus.sent,
        isOwn: true,
        clientId: cid,
        replyToMessageId: replyToMessageId,
        replyToPreview: replyToPreview,
      );
      _mockMessages.putIfAbsent(conversationId, () => []).add(saved);
      _updateMockConversationPreview(conversationId, text, isOwn: true);
      _simulateMockReply(conversationId);
    } else {
      saved = await _chatService.sendMessage(
        conversationId: conversationId,
        text: text,
        clientId: cid,
        replyToMessageId: replyToMessageId,
      );
      _stomp.sendMessage(
        conversationId: conversationId,
        text: text,
        clientMessageId: cid,
        replyToMessageId: replyToMessageId,
      );
    }

    await _isar.upsertMessage(ChatIsarMapper.toLocalMessage(saved));
    await _isar.removeOutbox(cid);
    await _upsertConversationPreview(conversationId, preview: text, isOwn: true);
    return saved;
  }

  void _simulateMockReply(String conversationId) {
    final conv = _mockConversations.where((c) => c.id == conversationId).toList();
    if (conv.isEmpty) return;
    final participant = conv.first.participant;
    _stomp.simulateTyping(
      conversationId: conversationId,
      userId: participant.id,
      isTyping: true,
    );
    Future<void>.delayed(const Duration(seconds: 2), () async {
      _stomp.simulateTyping(
        conversationId: conversationId,
        userId: participant.id,
        isTyping: false,
      );
      final replyText = 'Thanks for your message! I will get back to you soon.';
      final reply = ChatMessage(
        id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
        conversationId: conversationId,
        senderId: participant.id,
        text: replyText,
        createdAt: DateTime.now(),
        status: MessageDeliveryStatus.delivered,
      );
      _mockMessages.putIfAbsent(conversationId, () => []).add(reply);
      _updateMockConversationPreview(conversationId, replyText, isOwn: false);
      _stomp.simulateInbound(
        ChatStompPayload(
          type: ChatStompEventType.message,
          conversationId: conversationId,
          messageId: reply.id,
          senderId: participant.id,
          text: replyText,
          status: 'DELIVERED',
          createdAt: reply.createdAt,
        ),
      );
    });
  }

  Future<void> deleteMessage(String messageId) async {
    await _isar.markMessageDeleted(messageId);
    if (useMockApi) {
      for (final list in _mockMessages.values) {
        final index = list.indexWhere((m) => m.id == messageId);
        if (index >= 0) {
          list[index] = list[index].copyWith(isDeleted: true, text: '');
        }
      }
    }
  }

  Future<void> markMessageRead(String messageId) async {
    await _markMessageStatus(messageId, MessageDeliveryStatus.read);
    if (!useMockApi) {
      await _chatService.markMessageRead(messageId);
    }
  }

  Future<ConversationModel?> getConversation(String conversationId) async {
    if (useMockApi) {
      await _ensureMockSeed();
      try {
        return _mockConversations.firstWhere((c) => c.id == conversationId);
      } catch (_) {
        return null;
      }
    }
    final local = await _isar.getConversationById(conversationId);
    if (local != null) return ChatIsarMapper.fromLocalConversation(local);
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
        phone: _phoneFor(p.id),
        location: p.id == 'author-1' ? 'Phnom Penh' : null,
        isOnline: p.isOnline,
      );
    }
    return null;
  }

  String? _bioFor(String id) {
    switch (id) {
      case 'author-1':
        return 'Main character of my life is no one else but me.';
      case 'author-5':
        return 'Business student at AUB.';
      case 'author-6':
        return 'Software engineering student.';
      case 'author-7':
        return 'Campus ambassador and event volunteer.';
      default:
        return null;
    }
  }

  String? _phoneFor(String id) {
    if (id == 'author-1') return '+855 123 4442';
    return null;
  }

  Future<void> markConversationRead(String conversationId) async {
    await _isar.setUnreadCount(conversationId, 0);
    if (useMockApi) {
      final index = _mockConversations.indexWhere((c) => c.id == conversationId);
      if (index >= 0) {
        _mockConversations[index] = _mockConversations[index].copyWith(unreadCount: 0);
      }
    }
  }

  Future<String> findOrCreateConversation(String participantId) async {
    if (useMockApi) {
      await _ensureMockSeed();
      final existing = _mockConversations.where((c) => c.participant.id == participantId);
      if (existing.isNotEmpty) return existing.first.id;
      final contact = (await fetchRecentContacts()).firstWhere(
        (c) => c.id == participantId,
        orElse: () => ChatParticipant(id: participantId, fullName: 'New Contact'),
      );
      final id = 'conv-new-${DateTime.now().millisecondsSinceEpoch}';
      final conv = ConversationModel(
        id: id,
        participant: contact,
        lastMessagePreview: '',
        updatedAt: DateTime.now(),
      );
      _mockConversations.insert(0, conv);
      _mockMessages[id] = [];
      await _isar.upsertConversation(ChatIsarMapper.toLocalConversation(conv));
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

  Future<void> clearCache() => _isar.clearAll();

  Future<void> _upsertConversationPreview(
    String conversationId, {
    required String preview,
    required bool isOwn,
    bool incrementUnread = false,
  }) async {
    final existing = await _isar.getConversationById(conversationId);
    if (existing != null) {
      existing.lastMessagePreview = preview;
      existing.updatedAt = DateTime.now();
      existing.lastMessageIsOwn = isOwn;
      existing.lastMessageStatus = isOwn ? MessageDeliveryStatus.sent.name : MessageDeliveryStatus.delivered.name;
      existing.isTyping = false;
      if (incrementUnread) existing.unreadCount += 1;
      await _isar.upsertConversation(existing);
      return;
    }
    if (useMockApi) {
      _updateMockConversationPreview(conversationId, preview, isOwn: isOwn);
    }
  }

  void _updateMockConversationPreview(String conversationId, String preview, {required bool isOwn}) {
    final index = _mockConversations.indexWhere((c) => c.id == conversationId);
    if (index >= 0) {
      _mockConversations[index] = _mockConversations[index].copyWith(
        lastMessagePreview: preview,
        updatedAt: DateTime.now(),
        lastMessageIsOwn: isOwn,
        lastMessageStatus: MessageDeliveryStatus.sent,
        unreadCount: isOwn ? 0 : _mockConversations[index].unreadCount,
      );
      final item = _mockConversations.removeAt(index);
      _mockConversations.insert(0, item);
    }
  }

  Future<void> _ensureMockSeed() async {
    if (_mockConversations.isNotEmpty) return;

    _mockConversations.addAll([
      ConversationModel(
        id: 'conv-meas',
        participant: const ChatParticipant(id: 'author-5', fullName: 'Meas Lily', isOnline: true),
        lastMessagePreview: '',
        updatedAt: DateTime.now().subtract(const Duration(minutes: 2)),
        unreadCount: 3,
        isTyping: true,
      ),
      ConversationModel(
        id: 'conv-bora',
        participant: const ChatParticipant(id: 'author-6', fullName: 'Ponloeng Bora'),
        lastMessagePreview: "Hey! what's sub",
        updatedAt: DateTime.now().subtract(const Duration(minutes: 2)),
        unreadCount: 0,
        lastMessageIsOwn: true,
        lastMessageStatus: MessageDeliveryStatus.read,
      ),
      ConversationModel(
        id: 'conv-heng',
        participant: const ChatParticipant(id: 'author-1', fullName: 'Heng Liza', isOnline: true),
        lastMessagePreview: "I'm looking for a job",
        updatedAt: DateTime.now().subtract(const Duration(minutes: 2)),
        unreadCount: 0,
        lastMessageIsOwn: false,
      ),
      ConversationModel(
        id: 'conv-moeng',
        participant: const ChatParticipant(id: 'author-7', fullName: 'Moeng Kimheang'),
        lastMessagePreview: 'I checked it already nothing to modify on my side.',
        updatedAt: DateTime.now().subtract(const Duration(minutes: 2)),
        unreadCount: 0,
        lastMessageIsOwn: true,
        lastMessageStatus: MessageDeliveryStatus.read,
      ),
    ]);

    _mockMessages['conv-heng'] = [
      ChatMessage(
        id: 'm1',
        conversationId: 'conv-heng',
        senderId: 'author-1',
        text: "I'm looking for a job position at your company.",
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ChatMessage(
        id: 'm2',
        conversationId: 'conv-heng',
        senderId: currentUserId,
        text: 'Sure! Send me your CV when you are ready.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 35)),
        isOwn: true,
        status: MessageDeliveryStatus.read,
      ),
      ChatMessage(
        id: 'm3',
        conversationId: 'conv-heng',
        senderId: 'author-1',
        text: "I'm looking for a job",
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    ];

    _mockMessages['conv-bora'] = [
      ChatMessage(
        id: 'm4',
        conversationId: 'conv-bora',
        senderId: currentUserId,
        text: "Hey! what's sub",
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        isOwn: true,
        status: MessageDeliveryStatus.read,
      ),
    ];

    _mockMessages['conv-moeng'] = [
      ChatMessage(
        id: 'm5',
        conversationId: 'conv-moeng',
        senderId: currentUserId,
        text: 'I checked it already nothing to modify on my side.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        isOwn: true,
        status: MessageDeliveryStatus.read,
      ),
    ];

    _mockMessages['conv-meas'] = [
      ChatMessage(
        id: 'm6',
        conversationId: 'conv-meas',
        senderId: 'author-5',
        text: 'Are you free this afternoon?',
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
    ];

    // Seed Isar from mock
    await _isar.upsertConversations(
      _mockConversations.map(ChatIsarMapper.toLocalConversation).toList(),
    );
    for (final entry in _mockMessages.entries) {
      await _isar.upsertMessages(entry.value.map(ChatIsarMapper.toLocalMessage).toList());
    }
  }

  Future<ChatSharedContent> fetchSharedContent(String conversationId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      final parsed = _parseSharedContentFromMessages(
        List<ChatMessage>.from(_mockMessages[conversationId] ?? []),
      );
      if (_hasSharedItems(parsed)) return parsed;
      return _mockSharedContent();
    }

    final messages = await fetchMessages(conversationId: conversationId);
    return _parseSharedContentFromMessages(messages);
  }

  bool _hasSharedItems(ChatSharedContent content) {
    return content.imageUrls.isNotEmpty ||
        content.videoUrls.isNotEmpty ||
        content.files.isNotEmpty ||
        content.links.isNotEmpty;
  }

  ChatSharedContent _mockSharedContent() {
    return ChatSharedContent(
      imageUrls: List.generate(6, (i) => 'https://picsum.photos/seed/chat-media-$i/300/300'),
      videoUrls: List.generate(6, (i) => 'https://picsum.photos/seed/chat-video-$i/300/300'),
      files: [
        ChatSharedFile(
          name: 'Heng_Liza_CV.pdf',
          sizeLabel: '120 KB',
          sharedAt: _mockFileDate,
        ),
        ChatSharedFile(
          name: 'Kim_John_CV.pdf',
          sizeLabel: '98 KB',
          sharedAt: _mockFileDate,
        ),
        ChatSharedFile(
          name: 'Patel_Sita_CV.pdf',
          sizeLabel: '110 KB',
          sharedAt: _mockFileDate,
        ),
      ],
      links: [
        ChatSharedLink(
          url: 'https://t.me/acledarecruitment',
          sharedAt: _mockLinkDateJan,
          title: 'ACLEDA Recruitment',
          description:
              "Please join ACLEDA recruitment's official Telegram channel to get more Job Announcement updates.",
        ),
        ChatSharedLink(
          url: 'https://t.me/acledarecruitment',
          sharedAt: _mockLinkDateFeb,
          title: 'ACLEDA Recruitment',
          description:
              "Please join ACLEDA recruitment's official Telegram channel to get more Job Announcement updates.",
        ),
      ],
    );
  }

  static final _mockFileDate = DateTime(2025, 10, 26, 11, 14);
  static final _mockLinkDateJan = DateTime(2026, 1, 12);
  static final _mockLinkDateFeb = DateTime(2026, 2, 3);

  ChatSharedContent _parseSharedContentFromMessages(List<ChatMessage> messages) {
    final imageUrls = <String>{};
    final videoUrls = <String>{};
    final files = <ChatSharedFile>[];
    final links = <ChatSharedLink>[];
    final urlPattern = RegExp(r'https?://[^\s]+', caseSensitive: false);

    for (final message in messages) {
      if (message.isDeleted || message.text.trim().isEmpty) continue;
      final text = message.text.trim();
      final matches = urlPattern.allMatches(text);
      if (matches.isEmpty) {
        if (text.toLowerCase().endsWith('.pdf')) {
          files.add(
            ChatSharedFile(
              name: text.split('/').last,
              sizeLabel: '—',
              sharedAt: message.createdAt,
            ),
          );
        }
        continue;
      }

      for (final match in matches) {
        final url = match.group(0)!.replaceAll(RegExp(r'[),.;]+$'), '');
        final lower = url.toLowerCase();
        if (_isImageUrl(lower)) {
          imageUrls.add(url);
        } else if (_isVideoUrl(lower)) {
          videoUrls.add(url);
        } else if (lower.contains('.pdf')) {
          files.add(
            ChatSharedFile(
              name: Uri.parse(url).pathSegments.isNotEmpty ? Uri.parse(url).pathSegments.last : 'document.pdf',
              sizeLabel: '—',
              sharedAt: message.createdAt,
              downloadUrl: url,
            ),
          );
        } else {
          links.add(
            ChatSharedLink(
              url: url,
              sharedAt: message.createdAt,
              title: Uri.tryParse(url)?.host ?? 'Link',
              description: text.length > url.length ? text.replaceAll(url, '').trim() : null,
            ),
          );
        }
      }
    }

    return ChatSharedContent(
      imageUrls: imageUrls.toList(),
      videoUrls: videoUrls.toList(),
      files: files,
      links: links,
    );
  }

  bool _isImageUrl(String lowerUrl) {
    return lowerUrl.contains('.png') ||
        lowerUrl.contains('.jpg') ||
        lowerUrl.contains('.jpeg') ||
        lowerUrl.contains('.webp') ||
        lowerUrl.contains('.gif');
  }

  bool _isVideoUrl(String lowerUrl) {
    return lowerUrl.contains('.mp4') ||
        lowerUrl.contains('.mov') ||
        lowerUrl.contains('youtube.com') ||
        lowerUrl.contains('youtu.be');
  }
}
