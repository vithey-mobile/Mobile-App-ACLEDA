import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';
import 'package:aub_connect_app/modules/chat/widgets/chat_emoji_panel.dart';

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
    this.onEmojiSelected,
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
  final ValueChanged<String>? onEmojiSelected;
  final ValueChanged<String>? onTyping;
  final VoidCallback? onFocusText;

  static const int _maxInputLines = 6;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.cardSurface,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(height: 1, color: colors.border),
            Padding(
              padding: EdgeInsets.fromLTRB(8, 8, 8, showEmojiPanel ? 6 : 8),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  final hasText = value.text.trim().isNotEmpty;
                  return Obx(() {
                    final sending = isSending.value;
                    final canSend =
                        (hasText || attachments.isNotEmpty) && !sending;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: colors.inputFill,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: colors.border),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (attachments.isNotEmpty)
                                  SizedBox(
                                    height: 72,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.fromLTRB(
                                        12,
                                        8,
                                        12,
                                        4,
                                      ),
                                      itemCount: attachments.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(width: 8),
                                      itemBuilder: (_, index) {
                                        final item = attachments[index];
                                        return _AttachmentChip(
                                          attachment: item,
                                          onRemove: () =>
                                              onRemoveAttachment(item),
                                        );
                                      },
                                    ),
                                  ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    _ComposerIconButton(
                                      tooltip: 'Add photo, video, or file',
                                      onPressed:
                                          sending ? null : onAddAttachment,
                                      icon: Icons.add_rounded,
                                      color: colors.heading,
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: controller,
                                        minLines: 1,
                                        maxLines: _maxInputLines,
                                        enabled: !sending,
                                        keyboardType: TextInputType.multiline,
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        textInputAction:
                                            TextInputAction.newline,
                                        onChanged: onTyping,
                                        onTap: onFocusText,
                                        style: TextStyle(
                                          color: colors.heading,
                                          fontSize: 16,
                                          height: 1.35,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: AppStrings.chatComposerHint,
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                            0,
                                            10,
                                            4,
                                            10,
                                          ),
                                          hintStyle: TextStyle(
                                            color: colors.muted,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    _ComposerIconButton(
                                      tooltip: showEmojiPanel
                                          ? 'Hide emoji'
                                          : 'Emoji',
                                      onPressed:
                                          sending ? null : onToggleEmoji,
                                      icon: showEmojiPanel
                                          ? Icons.keyboard_rounded
                                          : Icons.emoji_emotions_outlined,
                                      color: showEmojiPanel
                                          ? AppColors.primary
                                          : colors.heading,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _SendButton(
                          canSend: canSend,
                          sending: sending,
                          onSend: onSend,
                        ),
                      ],
                    );
                  });
                },
              ),
            ),
            if (showEmojiPanel && onEmojiSelected != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: ChatEmojiPanel(onEmojiSelected: onEmojiSelected!),
              ),
          ],
        ),
      ),
    );
  }
}

class _ComposerIconButton extends StatelessWidget {
  const _ComposerIconButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    required this.color,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 40, minHeight: 44),
      icon: Icon(icon, color: color, size: 24),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.canSend,
    required this.sending,
    required this.onSend,
  });

  final bool canSend;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: canSend
          ? AppColors.primary
          : AppColors.primary.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: canSend ? onSend : null,
        child: SizedBox(
          width: 46,
          height: 46,
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
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
          ),
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
