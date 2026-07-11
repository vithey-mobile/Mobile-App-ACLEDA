import 'package:aub_connect_app/data/fixtures/mock_clock.dart';
import 'package:aub_connect_app/data/fixtures/mock_ids.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';

abstract final class AiFixtures {
  static List<AiSession> buildSessions() {
    return [
      AiSession(
        id: MockIds.aiSession1,
        title: 'CV review tips',
        topic: AiTopic.cv,
        isPinned: true,
        preview: 'Here are CV tips for AUB students…',
        updatedAt: MockClock.hoursAgo(2),
      ),
      AiSession(
        id: MockIds.aiSession2,
        title: 'Interview STAR method',
        topic: AiTopic.interview,
        preview: 'For interview practice, try the STAR method…',
        updatedAt: MockClock.daysAgo(1),
      ),
      AiSession(
        id: MockIds.aiSession3,
        title: 'Finance guidance',
        topic: AiTopic.finance,
        preview: 'I can explain how Vithey Finance works…',
        updatedAt: MockClock.daysAgo(2),
      ),
    ];
  }

  static Map<String, List<AiMessage>> buildMessages() {
    return {
      MockIds.aiSession1: [
        AiMessage(
          id: 'm1',
          sessionId: MockIds.aiSession1,
          role: AiMessageRole.user,
          content: 'How can I improve my CV?',
          createdAt: MockClock.hoursAgo(2),
        ),
        AiMessage(
          id: 'm2',
          sessionId: MockIds.aiSession1,
          role: AiMessageRole.assistant,
          content: mockReply('cv', AiTopic.cv),
          createdAt: MockClock.hoursAgo(2),
        ),
      ],
      MockIds.aiSession2: [
        AiMessage(
          id: 'm3',
          sessionId: MockIds.aiSession2,
          role: AiMessageRole.user,
          content: 'Help me prepare for interviews',
          createdAt: MockClock.daysAgo(1),
        ),
        AiMessage(
          id: 'm4',
          sessionId: MockIds.aiSession2,
          role: AiMessageRole.assistant,
          content: mockReply('interview', AiTopic.interview),
          createdAt: MockClock.daysAgo(1),
        ),
      ],
      MockIds.aiSession3: [
        AiMessage(
          id: 'm5',
          sessionId: MockIds.aiSession3,
          role: AiMessageRole.user,
          content: 'How do tuition payments work?',
          createdAt: MockClock.daysAgo(2),
        ),
        AiMessage(
          id: 'm6',
          sessionId: MockIds.aiSession3,
          role: AiMessageRole.assistant,
          content: mockReply('finance', AiTopic.finance),
          createdAt: MockClock.daysAgo(2),
        ),
      ],
    };
  }

  static String mockReply(String message, AiTopic? topic) {
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
          '- **Result** — share the outcome';
    }
    if (lower.contains('finance') || lower.contains('fee') || topic == AiTopic.finance) {
      return 'I can explain how Vithey Finance works, but I cannot access your actual balance or payment records.\n\n'
          'For real account details, open the Finance tab after student verification.';
    }
    return 'I\'m Vithey AI, your campus assistant. I can help with CVs, job applications, interview prep, student life, and general Finance guidance.';
  }

  static String mockRegenerateReply(String userMessage) {
    final lower = userMessage.toLowerCase();
    if (lower.contains('cv') || lower.contains('resume')) {
      return 'Here is an alternate CV outline:\n\n'
          'Contact | Summary | Education | Experience | Skills\n\n'
          '- Lead with measurable outcomes.\n'
          '- Use action verbs: designed, led, improved.';
    }
    return 'Here is another perspective:\n\n'
        '- Break the problem into smaller steps.\n'
        '- Validate assumptions with a quick checklist.';
  }
}
