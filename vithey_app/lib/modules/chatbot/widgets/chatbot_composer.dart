import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';

class ChatbotComposer extends StatelessWidget {
  const ChatbotComposer({
    super.key,
    required this.controller,
    required this.isGenerating,
    required this.onSend,
    required this.onStop,
  });

  final TextEditingController controller;
  final bool isGenerating;
  final VoidCallback onSend;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.authInputFill,
              child: IconButton(
                icon: const Icon(Icons.add, size: 20),
                tooltip: 'Attachments coming soon',
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Ask me anything…',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: isGenerating ? null : (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary,
              child: IconButton(
                icon: Icon(
                  isGenerating ? Icons.stop : Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
                tooltip: isGenerating ? 'Stop generating' : 'Send',
                onPressed: isGenerating ? onStop : onSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
