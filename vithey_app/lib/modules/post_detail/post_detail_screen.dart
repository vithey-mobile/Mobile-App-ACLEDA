import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/post_detail/post_detail_controller.dart';
import 'package:aub_connect_app/modules/post_detail/widgets/comment_section.dart';
import 'package:aub_connect_app/modules/post_detail/widgets/mention_user_box.dart';
import 'package:aub_connect_app/modules/post_detail/widgets/post_detail_header.dart';
import 'package:aub_connect_app/modules/post_detail/widgets/post_detail_media.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class PostDetailScreen extends GetView<PostDetailController> {
  const PostDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Get.back(result: controller.post.value);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: context.appColors.cardSurface,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 8,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: context.appColors.cardSurface,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'Back',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(result: controller.post.value),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: context.appColors.border),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const LoadingWidget(message: 'Loading post...');
          }
          if (controller.hasError.value) {
            return AppErrorWidget(
              message: controller.errorMessage.value,
              onRetry: controller.loadPost,
            );
          }

          final post = controller.post.value;
          if (post == null) {
            return const AppErrorWidget(message: 'Post unavailable');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PostDetailCard(
                  post: post,
                  onFollow: controller.toggleFollow,
                  onApply: controller.applyJob,
                  onEdit: controller.editPost,
                  onDelete: () => controller.deletePost(context),
                ),
                _DetailEngagementBar(
                  post: post,
                  onReact: controller.toggleLike,
                  onComment: () => controller.commentFocus.requestFocus(),
                ),
                const CommentSection(),
              ],
            ),
          );
        }),
        bottomNavigationBar: Obx(() {
          if (controller.isLoading.value ||
              controller.hasError.value ||
              controller.post.value == null) {
            return const SizedBox.shrink();
          }
          return const _CommentComposer();
        }),
      ),
    );
  }
}

class _PostDetailCard extends StatelessWidget {
  const _PostDetailCard({
    required this.post,
    required this.onFollow,
    required this.onApply,
    required this.onEdit,
    required this.onDelete,
  });

  final FeedPost post;
  final VoidCallback onFollow;
  final VoidCallback onApply;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final hasMedia = post.mediaUrl?.isNotEmpty == true ||
        post.thumbnailUrl?.isNotEmpty == true;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 1),
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
      decoration: BoxDecoration(
        color: context.appColors.cardSurface,
        border: Border.all(color: context.appColors.border),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostDetailHeader(
            post: post,
            onFollow: onFollow,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
          if (post.content.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              post.content,
              style: TextStyle(
                color: context.appColors.heading,
                fontSize: 13.5,
                height: 1.28,
              ),
            ),
          ],
          if (hasMedia) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: PostDetailMedia(post: post),
            ),
          ],
          if (post.type == PostType.job)
            _JobDetailBlock(post: post, onApply: onApply),
        ],
      ),
    );
  }
}

class _DetailEngagementBar extends StatelessWidget {
  const _DetailEngagementBar({
    required this.post,
    required this.onReact,
    required this.onComment,
  });

  final FeedPost post;
  final VoidCallback onReact;
  final VoidCallback onComment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
      child: Row(
        children: [
          _DetailAction(
            icon: post.userReacted
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            count: post.reactionCount,
            color: post.userReacted
                ? context.scheme.primary
                : context.appColors.muted,
            onTap: onReact,
          ),
          _DetailAction(
            icon: Icons.chat_bubble_outline_rounded,
            count: post.commentCount,
            onTap: onComment,
          ),
          _DetailAction(
            icon: Icons.bookmark_border_rounded,
            count: post.shareCount,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _DetailAction extends StatelessWidget {
  const _DetailAction({
    required this.icon,
    required this.count,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final int count;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? context.appColors.muted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 52, minHeight: 44),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: foreground),
            const SizedBox(width: 5),
            Text(
              '$count',
              style: TextStyle(color: foreground, fontSize: 12),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _CommentComposer extends StatelessWidget {
  const _CommentComposer();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostDetailController>();
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.cardSurface,
        border: Border(
          top: BorderSide(
            color: context.appColors.border.withValues(alpha: 0.7),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: context.appColors.subtleShadow,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                if (!controller.showMentions.value) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: MentionUserBox(
                    users: controller.filteredMentionUsers,
                    onSelect: controller.mentionUser,
                  ),
                );
              }),
              Obx(() {
                final editing = controller.editingComment.value;
                final target = controller.replyTarget.value;
                if (editing == null && target == null) {
                  return const SizedBox.shrink();
                }
                final label = editing != null
                    ? 'Editing comment'
                    : 'Replying to ${target!.author.fullName}';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: context.appColors.muted,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: editing != null
                            ? controller.cancelEdit
                            : controller.cancelReply,
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                );
              }),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: context.appColors.cardSurface,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: context.appColors.border,
                    width: 1,
                  ),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 50),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.commentController,
                          focusNode: controller.commentFocus,
                          minLines: 1,
                          maxLines: 3,
                          style: TextStyle(
                            color: context.appColors.heading,
                            fontSize: 15,
                          ),
                          cursorColor: context.scheme.primary,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => controller.submitComment(),
                          decoration: InputDecoration(
                            hintText: 'Amazing!',
                            hintStyle: TextStyle(
                              color: context.appColors.muted,
                              fontSize: 15,
                            ),
                            filled: false,
                            isDense: true,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.fromLTRB(
                              14,
                              15,
                              8,
                              14,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 4, 4, 4),
                        child: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: controller.commentController,
                          builder: (_, value, __) => Obx(
                            () {
                              final canSend = value.text.trim().isNotEmpty &&
                                  !controller.isSending.value;
                              return SizedBox(
                                width: 42,
                                height: 42,
                                child: IconButton(
                                  tooltip:
                                      controller.editingComment.value != null
                                          ? 'Save comment'
                                          : 'Send comment',
                                  onPressed:
                                      canSend ? controller.submitComment : null,
                                  style: IconButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    shape: const CircleBorder(),
                                    backgroundColor: context.scheme.primary,
                                    foregroundColor: context.scheme.onPrimary,
                                    disabledBackgroundColor:
                                        context.appColors.inputFill,
                                    disabledForegroundColor:
                                        context.appColors.muted,
                                  ),
                                  icon: controller.isSending.value
                                      ? SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: context.scheme.onPrimary,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.send_rounded,
                                          size: 20,
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JobDetailBlock extends StatelessWidget {
  const _JobDetailBlock({required this.post, required this.onApply});

  final FeedPost post;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final meta = post.jobMeta;
    final canApply = !post.isOwnPost &&
        post.lifecycleState == JobLifecycleState.open &&
        post.applicationState == JobApplicationState.notApplied;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (meta.title != null)
            Text(meta.title!,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (meta.description != null) ...[
            const SizedBox(height: 8),
            Text(meta.description!,
                style: TextStyle(color: context.appColors.muted)),
          ],
          if (meta.requirement != null) ...[
            const SizedBox(height: 8),
            Text('Requirements: ${meta.requirement}'),
          ],
          const SizedBox(height: 16),
          if (post.applicationState == JobApplicationState.applied)
            const Text('Applied',
                style: TextStyle(
                    color: AppColors.success, fontWeight: FontWeight.w600))
          else if (canApply)
            CustomButton(
                label: 'Apply CV',
                icon: Icons.description_outlined,
                onPressed: onApply)
          else if (!post.isOwnPost)
            Text('Applications closed',
                style: TextStyle(color: context.appColors.muted)),
        ],
      ),
    );
  }
}
