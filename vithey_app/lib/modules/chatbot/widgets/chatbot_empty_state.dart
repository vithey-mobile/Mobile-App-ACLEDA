import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class ChatbotEmptyState extends StatelessWidget {
  const ChatbotEmptyState({
    super.key,
    required this.prompts,
    required this.onPromptTap,
  });

  final List<String> prompts;
  final ValueChanged<String> onPromptTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'How can I help you today?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask about CVs, jobs, interviews, student life, or Finance guidance.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.appColors.muted),
            ),
            const SizedBox(height: 28),
            ...prompts.map(
              (prompt) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => onPromptTap(prompt),
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    child: Text(prompt),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
