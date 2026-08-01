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
              (item) => InkWell(
                onTap: () => onPromptTap(item.text),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: [
                      Icon(
                        item.icon,
                        size: 22,
                        color: context.appColors.muted,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: context.appColors.heading
                                .withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
