import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

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

  static const defaultItems = [
    ChatbotSuggestionItem(
      icon: Icons.description_outlined,
      text: 'Help me improve my CV for campus jobs',
    ),
    ChatbotSuggestionItem(
      icon: Icons.work_outline,
      text: 'What jobs can I apply to on Vithey?',
    ),
    ChatbotSuggestionItem(
      icon: Icons.record_voice_over_outlined,
      text: 'Practice interview questions for my major',
    ),
    ChatbotSuggestionItem(
      icon: Icons.school_outlined,
      text: 'What student services does AUB offer?',
    ),
    ChatbotSuggestionItem(
      icon: Icons.account_balance_wallet_outlined,
      text: 'How does Vithey Finance verification work?',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items
          .map(
            (item) => InkWell(
              onTap: () => onPromptTap(item.text),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(item.icon, size: 24, color: context.appColors.muted),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15, color: context.appColors.muted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
