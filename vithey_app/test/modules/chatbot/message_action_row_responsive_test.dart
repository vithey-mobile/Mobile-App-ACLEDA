import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/message_action_row.dart';

void main() {
  Widget buildTestWidget({
    required double width,
    required AiMessage message,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: MessageActionRow(
              message: message,
              onCopy: () {},
              onShare: () {},
              onRegenerate: () {},
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('MessageActionRow does not overflow on 390px viewport',
      (tester) async {
    final message = AiMessage(
      id: 'msg_1',
      sessionId: 'session_1',
      role: AiMessageRole.assistant,
      content: 'Here is the assistant response.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      status: AiMessageStatus.complete,
    );

    await tester.pumpWidget(buildTestWidget(width: 390, message: message));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(MessageActionRow), findsOneWidget);
    expect(find.byTooltip('Copy'), findsOneWidget);
    expect(find.byTooltip('Regenerate'), findsOneWidget);
    expect(find.byTooltip('Share'), findsOneWidget);
    expect(find.byTooltip('Like'), findsOneWidget);
    expect(find.byTooltip('Unlike'), findsOneWidget);
    expect(find.byTooltip('Sources'), findsOneWidget);
  });

  testWidgets('MessageActionRow does not overflow on narrow 360px viewport',
      (tester) async {
    final message = AiMessage(
      id: 'msg_2',
      sessionId: 'session_1',
      role: AiMessageRole.assistant,
      content: 'Here is another response.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      status: AiMessageStatus.complete,
    );

    await tester.pumpWidget(buildTestWidget(width: 360, message: message));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('MessageActionRow does not overflow on compact 320px viewport',
      (tester) async {
    final message = AiMessage(
      id: 'msg_3',
      sessionId: 'session_1',
      role: AiMessageRole.assistant,
      content: 'Here is a response on very compact device.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      status: AiMessageStatus.complete,
    );

    await tester.pumpWidget(buildTestWidget(width: 320, message: message));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
