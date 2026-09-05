import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class AssistantMessage extends StatelessWidget {
  const AssistantMessage({
    super.key,
    required this.message,
    required this.onCopy,
  });

  final AiMessage message;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.isThinking)
                  const _ThinkingIndicator()
                else
                  _RichTextContent(content: message.content),
                if (!message.isThinking && message.content.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        tooltip: 'Copy',
                        onPressed: onCopy,
                        visualDensity: VisualDensity.compact,
                      ),
                      if (message.status == AiMessageStatus.stopped)
                        Text('Stopped', style: TextStyle(fontSize: 12, color: context.appColors.muted)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThinkingIndicator extends StatelessWidget {
  const _ThinkingIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _AnimatedDots(),
        const SizedBox(width: 8),
        Text('Thinking…', style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }
}

class _AnimatedDots extends StatefulWidget {
  const _AnimatedDots();

  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Row(
          children: List.generate(3, (i) {
            final opacity = ((_controller.value + i * 0.2) % 1.0) > 0.5 ? 1.0 : 0.3;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(opacity),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _RichTextContent extends StatelessWidget {
  const _RichTextContent({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    final lines = content.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.trim().isEmpty) return const SizedBox(height: 8);
        if (line.startsWith('```')) {
          return const SizedBox.shrink();
        }
        if (line.startsWith('- ') || line.startsWith('• ')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• '),
                Expanded(child: Text(_stripMarkdown(line.substring(2)))),
              ],
            ),
          );
        }
        if (RegExp(r'^\d+\.\s').hasMatch(line)) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(_stripMarkdown(line)),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(_stripMarkdown(line)),
        );
      }).toList(),
    );
  }

  String _stripMarkdown(String text) {
    return text.replaceAll('**', '').replaceAll('*', '').trim();
  }
}
