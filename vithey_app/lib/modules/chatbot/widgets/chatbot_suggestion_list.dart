import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';

class ChatbotSuggestionItem {
  const ChatbotSuggestionItem({required this.icon, required this.text});

  final IconData icon;
  final String text;
}

class ChatbotSuggestionList extends StatelessWidget {
  const ChatbotSuggestionList({
    super.key,
    required this.items,
    required this.onPromptTap,
  });

  final List<ChatbotSuggestionItem> items;
  final ValueChanged<String> onPromptTap;

  /// ChatGPT-style quick actions (Vithey-focused prompts).
  static const defaultItems = [
    ChatbotSuggestionItem(
      icon: Icons.image_outlined,
      text: 'Help me improve my CV for campus jobs',
    ),
    ChatbotSuggestionItem(
      icon: Icons.edit_outlined,
      text: 'Practice interview questions for my major',
    ),
    ChatbotSuggestionItem(
      icon: Icons.public_outlined,
      text: 'What jobs can I apply to on Vithey?',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CustomButton(
                  label: item.text,
                  icon: item.icon,
                  variant: CustomButtonVariant.outline,
                  onPressed: () => onPromptTap(item.text),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
