import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

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
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 16),
            const shad.Text('How can I help you today?').large().bold(),
            const SizedBox(height: 8),
            shad.Text(
              'Ask about CVs, jobs, interviews, student life, or Finance guidance.',
            ).muted().textCenter(),
            const SizedBox(height: 28),
            ...prompts.map(
              (prompt) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: shad.Button.outline(
                    onPressed: () => onPromptTap(prompt),
                    child: shad.Text(prompt),
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
