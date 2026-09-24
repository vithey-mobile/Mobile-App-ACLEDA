import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/chatbot_state_views.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/chatbot_suggestion_list.dart';

void main() {
  testWidgets('ChatbotEmptyHero inside SingleChildScrollView does not overflow even in small viewport',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 80,
            width: 300,
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: ChatbotEmptyHero(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Suggestion items are hidden when focused', (tester) async {
    final focusNode = FocusNode();
    bool showSuggestions(bool isFocused, double bottomInset) =>
        !isFocused && bottomInset <= 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListenableBuilder(
            listenable: focusNode,
            builder: (context, _) {
              final visible = showSuggestions(
                focusNode.hasFocus,
                MediaQuery.viewInsetsOf(context).bottom,
              );
              return Column(
                children: [
                  TextField(focusNode: focusNode),
                  if (visible)
                    ChatbotSuggestionList(
                      items: ChatbotSuggestionList.defaultItems,
                      onPromptTap: (_) {},
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Initially visible
    expect(find.text('Help me write a CV'), findsOneWidget);

    // Focus TextField
    focusNode.requestFocus();
    await tester.pumpAndSettle();

    // Hidden after focus
    expect(find.text('Help me write a CV'), findsNothing);

    // Unfocus
    focusNode.unfocus();
    await tester.pumpAndSettle();

    // Reappears
    expect(find.text('Help me write a CV'), findsOneWidget);

    focusNode.dispose();
  });
}
