import 'dart:io';

import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/utils/relative_time.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';
import 'package:intl/intl.dart';

/// ChatGPT-style user bubble with optional photo / video / file previews.
class UserMessageBubble extends StatelessWidget {
  const UserMessageBubble({
    super.key,
    required this.content,
    required this.createdAt,
    this.attachments = const [],
  });

  final String content;
  final DateTime createdAt;
  final List<ChatAttachment> attachments;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleColor =
        isDark ? context.appColors.inputFill : const Color(0xFFF4F4F4);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (attachments.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: attachments
                    .map((a) => _SentAttachment(attachment: a))
                    .toList(),
              ),
            ),
          if (attachments.isNotEmpty && content.trim().isNotEmpty)
            const SizedBox(height: 8),
          if (content.trim().isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.78,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    content,
                    style: TextStyle(
                      color: context.appColors.heading,
                      fontSize: 16,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            _formatTimestamp(createdAt),
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

class _SentAttachment extends StatelessWidget {
  const _SentAttachment({required this.attachment});

  final ChatAttachment attachment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: context.appColors.inputFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.appColors.border.withValues(alpha: 0.7),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: attachment.isImage
          ? Image.file(
              File(attachment.path),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.broken_image_outlined,
                color: context.appColors.muted,
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  attachment.isVideo
                      ? Icons.videocam_rounded
                      : Icons.insert_drive_file_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    attachment.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.appColors.heading,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
