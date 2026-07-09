import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/utils/relative_time.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/core/widgets/shimmer_list_tile.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/modules/post_detail/post_detail_controller.dart';
import 'package:aub_connect_app/modules/post_detail/widgets/mention_user_box.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class CommentSection extends StatelessWidget {
  const CommentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostDetailController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text('Comments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        Obx(() {
          if (controller.isCommentsLoading.value && controller.comments.isEmpty) {
            return const Column(children: [ShimmerListTile(), ShimmerListTile()]);
          }
          if (controller.comments.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: EmptyStateWidget(
                title: 'No comments yet',
                subtitle: 'Be the first to comment.',
                icon: Icons.chat_bubble_outline,
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.comments.length,
            itemBuilder: (_, index) {
              final comment = controller.comments[index];
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserAvatar(name: comment.author.fullName, radius: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.appColors.inputFill,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.appColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(comment.author.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            _MentionText(text: comment.text),
                            const SizedBox(height: 6),
                            Text(
                              RelativeTime.format(comment.createdAt),
                              style: TextStyle(color: context.appColors.muted, fontSize: 11),
                            ),
                            if (comment.isFailed)
                              TextButton(
                                onPressed: controller.submitComment,
                                child: const Text('Retry'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
        const SizedBox(height: 8),
        Obx(() {
          if (!controller.showMentions.value) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: MentionUserBox(
              users: controller.filteredMentionUsers,
              onSelect: controller.mentionUser,
            ),
          );
        }),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + MediaQuery.viewInsetsOf(context).bottom),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.commentController,
                    focusNode: controller.commentFocus,
                    decoration: InputDecoration(
                      hintText: 'Write a comment…',
                      filled: true,
                      fillColor: context.appColors.inputFill,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => controller.submitComment(),
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() => IconButton(
                      onPressed: controller.isSending.value ? null : controller.submitComment,
                      icon: controller.isSending.value
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.send, color: AppColors.primary),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MentionText extends StatelessWidget {
  const _MentionText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'@\w+');
    var start = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
      ));
      start = match.end;
    }
    if (start < text.length) spans.add(TextSpan(text: text.substring(start)));

    return RichText(text: TextSpan(style: DefaultTextStyle.of(context).style, children: spans));
  }
}
