import 'dart:io';

import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/data/models/ai_chat_model.dart';

/// ChatGPT-style pill composer with photo / video / file attachments.
class ChatbotComposer extends StatelessWidget {
  const ChatbotComposer({
    super.key,
    required this.controller,
    required this.isGenerating,
    required this.onSend,
    required this.onStop,
    required this.attachments,
    required this.onAddAttachment,
    required this.onRemoveAttachment,
  });

  final TextEditingController controller;
  final bool isGenerating;
  final VoidCallback onSend;
  final VoidCallback onStop;
  final List<ChatAttachment> attachments;
  final VoidCallback onAddAttachment;
  final ValueChanged<ChatAttachment> onRemoveAttachment;

  static const _noBorder = InputBorder.none;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            final hasText = value.text.trim().isNotEmpty;
            final canSend =
                (hasText || attachments.isNotEmpty) && !isGenerating;

            return Container(
              decoration: BoxDecoration(
                color: context.appColors.cardSurface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: context.appColors.border.withValues(alpha: 0.7),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (attachments.isNotEmpty)
                    SizedBox(
                      height: 72,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
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
                      _RoundIcon(
                        icon: Icons.add_rounded,
                        color: context.appColors.heading,
                        onTap: isGenerating ? null : onAddAttachment,
                        tooltip: 'Add photo, video, or file',
                      ),
                      Expanded(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minHeight: 40,
                            maxHeight: 160,
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              inputDecorationTheme: const InputDecorationTheme(
                                border: _noBorder,
                                enabledBorder: _noBorder,
                                focusedBorder: _noBorder,
                                disabledBorder: _noBorder,
                                errorBorder: _noBorder,
                                focusedErrorBorder: _noBorder,
                                filled: false,
                              ),
                            ),
                            child: TextField(
                              controller: controller,
                              minLines: 1,
                              maxLines: 8,
                              enabled: !isGenerating,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              cursorColor: AppColors.primary,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.35,
                                color: context.appColors.heading,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                filled: false,
                                hintText: 'Ask Vithey AI',
                                hintStyle: TextStyle(
                                  color: context.appColors.muted,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                                border: _noBorder,
                                enabledBorder: _noBorder,
                                focusedBorder: _noBorder,
                                disabledBorder: _noBorder,
                                errorBorder: _noBorder,
                                focusedErrorBorder: _noBorder,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
                                ),
                              ),
                              onSubmitted: canSend ? (_) => onSend() : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      _ActionButton(
                        isGenerating: isGenerating,
                        enabled: canSend || isGenerating,
                        onTap: isGenerating
                            ? onStop
                            : (canSend ? onSend : null),
                      ),
                    ],
                  ),
                ],
              ),
            );
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
            color: context.appColors.inputFill,
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

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({
    required this.icon,
    required this.color,
    required this.tooltip,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 26, color: color),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.isGenerating,
    required this.enabled,
    required this.onTap,
  });

  final bool isGenerating;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isGenerating
        ? context.appColors.heading
        : (enabled
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.35));

    return Material(
      color: color,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            isGenerating ? Icons.stop_rounded : Icons.arrow_upward_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
