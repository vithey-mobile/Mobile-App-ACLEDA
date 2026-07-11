import 'package:aub_connect_app/core/constants/mock_identities.dart';
import 'package:aub_connect_app/data/fixtures/mock_clock.dart';
import 'package:aub_connect_app/data/fixtures/mock_ids.dart';
import 'package:aub_connect_app/data/fixtures/user_fixtures.dart';
import 'package:aub_connect_app/data/models/chat_message_model.dart';
import 'package:aub_connect_app/data/models/chat_participant.dart';
import 'package:aub_connect_app/data/models/chat_shared_content_model.dart';

abstract final class ChatFixtures {
  static List<ConversationModel> buildConversations() {
    return [
      ConversationModel(
        id: MockIds.convMeas,
        participant: const ChatParticipant(id: MockIds.author5, fullName: 'Meas Lily', isOnline: true),
        lastMessagePreview: 'Are you free this afternoon?',
        updatedAt: MockClock.minutesAgo(2),
        unreadCount: 3,
        isTyping: true,
      ),
      ConversationModel(
        id: MockIds.convBora,
        participant: const ChatParticipant(id: MockIds.author6, fullName: 'Ponloeng Bora'),
        lastMessagePreview: "Hey! what's sub",
        updatedAt: MockClock.minutesAgo(2),
        unreadCount: 0,
        lastMessageIsOwn: true,
        lastMessageStatus: MessageDeliveryStatus.read,
      ),
      ConversationModel(
        id: MockIds.convHeng,
        participant: const ChatParticipant(id: MockIds.author1, fullName: 'Heng Liza', isOnline: true),
        lastMessagePreview: "I'm looking for a job",
        updatedAt: MockClock.minutesAgo(2),
        unreadCount: 0,
        lastMessageIsOwn: false,
      ),
      ConversationModel(
        id: MockIds.convMoeng,
        participant: const ChatParticipant(id: MockIds.author7, fullName: 'Moeng Kimheang'),
        lastMessagePreview: 'I checked it already nothing to modify on my side.',
        updatedAt: MockClock.minutesAgo(2),
        unreadCount: 0,
        lastMessageIsOwn: true,
        lastMessageStatus: MessageDeliveryStatus.read,
      ),
    ];
  }

  static Map<String, List<ChatMessage>> buildMessages({required String currentUserId}) {
    return {
      MockIds.convHeng: [
        ChatMessage(
          id: 'm1',
          conversationId: MockIds.convHeng,
          senderId: MockIds.author1,
          text: "I'm looking for a job position at your company.",
          createdAt: MockClock.hoursAgo(2),
        ),
        ChatMessage(
          id: 'm2',
          conversationId: MockIds.convHeng,
          senderId: currentUserId,
          text: 'Sure! Send me your CV when you are ready.',
          createdAt: MockClock.minutesAgo(35),
          isOwn: true,
          status: MessageDeliveryStatus.read,
        ),
        ChatMessage(
          id: 'm3',
          conversationId: MockIds.convHeng,
          senderId: MockIds.author1,
          text: "I'm looking for a job",
          createdAt: MockClock.minutesAgo(2),
        ),
      ],
      MockIds.convBora: [
        ChatMessage(
          id: 'm4',
          conversationId: MockIds.convBora,
          senderId: currentUserId,
          text: "Hey! what's sub",
          createdAt: MockClock.minutesAgo(2),
          isOwn: true,
          status: MessageDeliveryStatus.read,
        ),
      ],
      MockIds.convMoeng: [
        ChatMessage(
          id: 'm5',
          conversationId: MockIds.convMoeng,
          senderId: currentUserId,
          text: 'I checked it already nothing to modify on my side.',
          createdAt: MockClock.minutesAgo(2),
          isOwn: true,
          status: MessageDeliveryStatus.read,
        ),
      ],
      MockIds.convMeas: [
        ChatMessage(
          id: 'm6',
          conversationId: MockIds.convMeas,
          senderId: MockIds.author5,
          text: 'Are you free this afternoon?',
          createdAt: MockClock.minutesAgo(10),
        ),
      ],
    };
  }

  static List<MessageRequestModel> buildMessageRequests() {
    return [
      MessageRequestModel(
        id: 'req-1',
        requester: const ChatParticipant(
          id: MockIds.author4,
          fullName: 'Sreynich Chan',
          bio: 'Business student',
        ),
        initialMessage: 'Hi! I saw your post about the campus event.',
        createdAt: MockClock.hoursAgo(5),
      ),
    ];
  }

  static ChatSharedContent sharedContent() {
    return ChatSharedContent(
      imageUrls: List.generate(6, (i) => 'https://picsum.photos/seed/chat-media-$i/300/300'),
      videoUrls: List.generate(6, (i) => 'https://picsum.photos/seed/chat-video-$i/300/300'),
      files: [
        ChatSharedFile(
          name: 'Heng_Liza_CV.pdf',
          sizeLabel: '120 KB',
          sharedAt: DateTime(2025, 10, 26, 11, 14),
        ),
        ChatSharedFile(
          name: '${MockIdentities.mockUserFullName.replaceAll(' ', '_')}_CV.pdf',
          sizeLabel: '98 KB',
          sharedAt: DateTime(2025, 10, 26, 11, 14),
        ),
      ],
      links: [
        ChatSharedLink(
          url: 'https://t.me/acledarecruitment',
          sharedAt: DateTime(2026, 1, 12),
          title: 'ACLEDA Recruitment',
          description:
              "Please join ACLEDA recruitment's official Telegram channel to get more Job Announcement updates.",
        ),
      ],
    );
  }

  static List<ChatParticipant> recentContacts() => UserFixtures.recentContacts();
}
