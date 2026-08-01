import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

/// Shared emoji sets for composer and message reactions.
class ChatEmojis {
  ChatEmojis._();

  static const quickReactions = ['👍', '❤️', '😂', '😮', '😢', '🙏', '🔥'];

  static const composer = [
    '😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣',
    '😊', '😇', '🙂', '😉', '😌', '😍', '🥰', '😘',
    '😗', '😙', '😚', '😋', '😜', '😝', '😛', '🤑',
    '🤗', '🤭', '🤫', '🤔', '🤐', '🤨', '😐', '😑',
    '😶', '😏', '😒', '🙄', '😬', '😮', '😯', '😲',
    '😳', '🥺', '😢', '😭', '😤', '😠', '😡', '🤬',
    '👍', '👎', '👏', '🙌', '🤝', '🙏', '💪', '✌️',
    '🤞', '🤟', '🤘', '👌', '🤌', '👆', '👇', '👉',
    '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍',
    '💔', '❣️', '💕', '💞', '💓', '💗', '💖', '💘',
    '🔥', '⭐', '✨', '💫', '🎉', '🎊', '💯', '✅',
    '❌', '❗', '❓', '💬', '👀', '👻', '🤖', '🎃',
  ];
}

class ChatEmojiPanel extends StatelessWidget {
  const ChatEmojiPanel({
    super.key,
    required this.onEmojiSelected,
    this.height = 220,
  });

  final ValueChanged<String> onEmojiSelected;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: context.appColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.border),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: ChatEmojis.composer.length,
        itemBuilder: (context, index) {
          final emoji = ChatEmojis.composer[index];
          return InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onEmojiSelected(emoji),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          );
        },
      ),
    );
  }
}

class QuickReactionBar extends StatelessWidget {
  const QuickReactionBar({
    super.key,
    required this.onSelected,
    this.selectedEmoji,
  });

  final ValueChanged<String> onSelected;
  final String? selectedEmoji;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ChatEmojis.quickReactions.map((emoji) {
          final selected = selectedEmoji == emoji;
          return Material(
            color: selected
                ? context.appColors.inputFill
                : Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => onSelected(emoji),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 26)),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
