import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class ChatbotComposer extends StatelessWidget {
  const ChatbotComposer({
    super.key,
    required this.controller,
    required this.isGenerating,
    required this.onSend,
    required this.onStop,
    this.onAttachment,
  });

  final TextEditingController controller;
  final bool isGenerating;
  final VoidCallback onSend;
  final VoidCallback onStop;
  final VoidCallback? onAttachment;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        child: Container(
          decoration: BoxDecoration(
            color: context.appColors.inputFill,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.appColors.border),
          ),
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              shad.IconButton.ghost(
                icon: const Icon(Icons.add, size: 20),
                onPressed: onAttachment,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Ask me anything…',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  ),
                  textInputAction: TextInputAction.newline,
                  onSubmitted: isGenerating ? null : (_) => onSend(),
                ),
              ),
              isGenerating
                  ? shad.IconButton.destructive(
                      icon: const Icon(Icons.stop, size: 20),
                      onPressed: onStop,
                    )
                  : shad.IconButton.primary(
                      icon: const Icon(Icons.send, size: 18),
                      onPressed: onSend,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
