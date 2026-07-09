import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/utils/relative_time.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class MessageActionRow extends StatelessWidget {
  const MessageActionRow({
    super.key,
    required this.message,
    required this.onCopy,
    required this.onShare,
    this.onRegenerate,
  });

  final AiMessage message;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback? onRegenerate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          _ActionIcon(
            icon: Icons.copy,
            onPressed: onCopy,
          ),
          if (onRegenerate != null)
            _ActionIcon(
              icon: Icons.refresh,
              onPressed: onRegenerate!,
            ),
          _ActionIcon(
            icon: Icons.share_outlined,
            onPressed: onShare,
          ),
          if (message.status == AiMessageStatus.stopped) ...[
            const SizedBox(width: 4),
            Text('Stopped', style: TextStyle(fontSize: 12, color: context.appColors.muted)),
          ],
          const Spacer(),
          Text(
            _formatTimestamp(message.createdAt),
            style: TextStyle(fontSize: 11, color: context.appColors.muted),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inHours < 24 &&
        now.day == time.day &&
        now.month == time.month &&
        now.year == time.year) {
      return DateFormat('h:mm a').format(time);
    }
    return RelativeTime.format(time);
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return shad.IconButton.ghost(
      icon: Icon(icon, size: 18),
      onPressed: onPressed,
    );
  }
}
