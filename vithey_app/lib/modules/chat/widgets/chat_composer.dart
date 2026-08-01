import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';

class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.isSending,
    required this.onSend,
    required this.attachments,
    required this.onAddAttachment,
    required this.onRemoveAttachment,
    required this.showEmojiPanel,
    required this.onToggleEmoji,
    this.onTyping,
    this.onFocusText,
  });

  final TextEditingController controller;
  final RxBool isSending;
  final VoidCallback onSend;
  final List<ChatAttachment> attachments;
  final VoidCallback onAddAttachment;
  final ValueChanged<ChatAttachment> onRemoveAttachment;
  final bool showEmojiPanel;
  final VoidCallback onToggleEmoji;
  final ValueChanged<String>? onTyping;
  final VoidCallback? onFocusText;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            final hasText = value.text.trim().isNotEmpty;
            return Obx(() {
              final sending = isSending.value;
              final canSend =
                  (hasText || attachments.isNotEmpty) && !sending;

              return Container(
                decoration: BoxDecoration(
                  color: context.appColors.inputFill,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: context.appColors.border),
                ),
                padding: const EdgeInsets.fromLTRB(4, 6, 4, 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (attachments.isNotEmpty)
                      SizedBox(
                        height: 72,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
                          itemCount: attachments.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, index) {
                            final item = attachments[index];
                            return _AttachmentChip(
                              attachment: item,
                              onRemove: () => onRemoveAttachment(item),
                            );
                          },
                        ),
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: 'Add photo, video, or file',
                          onPressed: sending ? null : onAddAttachment,
                          icon: Icon(
                            Icons.add_rounded,
                            color: context.appColors.heading,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: controller,
                            minLines: 1,
                            maxLines: 4,
                            enabled: !sending,
                            onChanged: onTyping,
                            onTap: onFocusText,
                            decoration: InputDecoration(
                              hintText: AppStrings.chatComposerHint,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.fromLTRB(
                                4,
                                12,
                                8,
                                12,
                              ),
                              hintStyle: TextStyle(
                                color: context.appColors.muted,
                              ),
                            ),
                            textInputAction: TextInputAction.send,
                            onSubmitted: canSend ? (_) => onSend() : null,
                          ),
                        ),
                        IconButton(
                          tooltip: showEmojiPanel
                              ? 'Hide emoji'
                              : 'Emoji',
                          onPressed: sending ? null : onToggleEmoji,
                          icon: Icon(
                            showEmojiPanel
                                ? Icons.keyboard_rounded
                                : Icons.emoji_emotions_outlined,
                            color: showEmojiPanel
                                ? AppColors.primary
                                : context.appColors.heading,
                          ),
                        ),
                        Material(
                          color: canSend
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.35),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: canSend ? onSend : null,
                            child: SizedBox(
                              width: 44,
                              height: 44,
                              child: Center(
                                child: sending
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.send,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            });
          },
        ),
      ),
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  const _AttachmentChip({
    required this.attachment,
    required this.onRemove,
  });

  final ChatAttachment attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: context.appColors.cardSurface,
            borderRadius: BorderRadius.circular(14),
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
                          ? Icons.videocam_outlined
                          : Icons.insert_drive_file_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        attachment.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          color: context.appColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: Material(
            color: context.appColors.heading,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onRemove,
              child: const SizedBox(
                width: 20,
                height: 20,
                child: Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
