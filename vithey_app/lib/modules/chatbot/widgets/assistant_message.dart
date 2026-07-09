import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/assistant_thinking_indicator.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/markdown_message_body.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/message_action_row.dart';

class AssistantMessage extends StatelessWidget {
  const AssistantMessage({
    super.key,
    required this.message,
    required this.onCopy,
    required this.onShare,
    this.onRegenerate,
    this.onCodeCopied,
  });

  final AiMessage message;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback? onRegenerate;
  final void Function(String code)? onCodeCopied;

  @override
  Widget build(BuildContext context) {
    final showActions = message.isTerminal && message.content.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isThinking)
            const AssistantThinkingIndicator()
          else if (message.status == AiMessageStatus.failed)
            _BubbleCard(
              child: Text(
                message.content,
                style: TextStyle(color: context.scheme.error),
              ),
            )
          else if (message.content.isNotEmpty)
            _BubbleCard(
              child: MarkdownMessageBody(
                content: message.content,
                onCodeCopied: onCodeCopied,
              ),
            ),
          if (showActions)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: MessageActionRow(
                message: message,
                onCopy: onCopy,
                onShare: onShare,
                onRegenerate: onRegenerate,
              ),
            ),
        ],
      ),
    );
  }
}

class _BubbleCard extends StatelessWidget {
  const _BubbleCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.92),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appColors.border),
          boxShadow: [
            BoxShadow(
              color: context.appColors.subtleShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
