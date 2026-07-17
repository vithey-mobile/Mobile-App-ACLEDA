import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/home/home_controller.dart';
import 'package:aub_connect_app/modules/home/widgets/job_poster_card.dart';
import 'package:aub_connect_app/modules/home/widgets/poster_post_card.dart';
import 'package:aub_connect_app/modules/home/widgets/video_post_card.dart';

class MixedPostFeed extends StatelessWidget {
  const MixedPostFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      if (controller.isInitialLoading.value) {
        return ListView.builder(
          padding: const EdgeInsets.only(top: 5, bottom: 90),
          itemCount: 3,
          itemBuilder: (_, __) => const _FeedCardSkeleton(),
        );
      }

      if (controller.hasError.value && controller.posts.isEmpty) {
        return AppErrorWidget(
          message: controller.errorMessage.value,
          onRetry: controller.retryFeed,
        );
      }

      if (controller.posts.isEmpty) {
        return EmptyStateWidget(
          title: 'Nothing here yet',
          subtitle: 'Follow people or create your first post',
          actionLabel: 'Create Post',
          onAction: () => controller.openCreatePost(),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshFeed,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 5, bottom: 92),
          itemCount: controller.posts.length + 1,
          itemBuilder: (context, index) {
            if (index == controller.posts.length) {
              if (controller.isLoadingMore.value) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child:
                      Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              if (controller.paginationError.value) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Center(
                    child: TextButton.icon(
                      onPressed: controller.loadMore,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Retry'),
                    ),
                  ),
                );
              }
              if (controller.hasMore.value) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => controller.loadMore());
              }
              return const SizedBox.shrink();
            }

            final post = controller.posts[index];
            return _FeedPostItem(
              key: ValueKey(post.id),
              post: post,
              controller: controller,
            );
          },
        ),
      );
    });
  }
}

class _FeedPostItem extends StatelessWidget {
  const _FeedPostItem({
    super.key,
    required this.post,
    required this.controller,
  });

  final FeedPost post;
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final common = (
      onLike: () => controller.toggleReaction(post.id),
      onComment: () => controller.openComments(post.id),
      onShare: () => controller.openShareSheet(post.id),
      onOpen: () => controller.openPost(post.id),
      onAuthorTap: () => controller.openAuthorProfile(post.author.id),
    );

    switch (post.type) {
      case PostType.poster:
        return PosterPostCard(
          post: post,
          onLike: common.onLike,
          onComment: common.onComment,
          onShare: common.onShare,
          onFollow: () => controller.toggleFollow(post.author.id),
          onOpen: common.onOpen,
          onAuthorTap: common.onAuthorTap,
          onEdit: () => controller.editPost(post),
          onDelete: () => controller.deletePost(context, post),
        );
      case PostType.video:
        return VideoPostCard(
          post: post,
          onLike: common.onLike,
          onComment: common.onComment,
          onShare: common.onShare,
          onFollow: () => controller.toggleFollow(post.author.id),
          onOpen: common.onOpen,
          onAuthorTap: common.onAuthorTap,
          onEdit: () => controller.editPost(post),
          onDelete: () => controller.deletePost(context, post),
        );
      case PostType.job:
        return JobPosterCard(
          post: post,
          onLike: common.onLike,
          onComment: common.onComment,
          onShare: common.onShare,
          onApply: () => controller.openJobApplication(post.id),
          onOpen: common.onOpen,
          onAuthorTap: common.onAuthorTap,
          onEdit: () => controller.editPost(post),
          onDelete: () => controller.deletePost(context, post),
        );
    }
  }
}

class _FeedCardSkeleton extends StatelessWidget {
  const _FeedCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: context.appColors.cardSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: context.appColors.inputFill,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonLine(
                        width: 110,
                        color: context.appColors.inputFill,
                      ),
                      const SizedBox(height: 6),
                      _SkeletonLine(
                        width: 54,
                        color: context.appColors.inputFill,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 210,
            color: context.appColors.inputFill,
          ),
          const SizedBox(height: 42),
        ],
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width, required this.color});

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 9,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
