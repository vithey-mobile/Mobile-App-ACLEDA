import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';

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
            Text(
              'How can I help you today?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.appColors.heading,
              ),
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
                  child: CustomButton(
                    label: prompt,
                    onPressed: () => onPromptTap(prompt),
                    variant: CustomButtonVariant.outline,
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
