import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/assistant_thinking_indicator.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/markdown_message_body.dart';
import 'package:aub_connect_app/modules/chatbot/widgets/message_action_row.dart';

/// Flat ChatGPT-style assistant reply (no card / border / shadow).
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
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isThinking)
            const AssistantThinkingIndicator()
          else if (message.status == AiMessageStatus.failed)
            Text(
              message.content,
              style: TextStyle(
                color: context.scheme.error,
                fontSize: 16,
                height: 1.55,
              ),
            )
          else if (message.content.isNotEmpty)
            MarkdownMessageBody(
              content: message.content,
              onCodeCopied: onCodeCopied,
            ),
          if (showActions)
            Padding(
              padding: const EdgeInsets.only(top: 10),
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
