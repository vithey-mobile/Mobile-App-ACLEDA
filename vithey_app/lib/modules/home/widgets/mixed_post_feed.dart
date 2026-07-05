import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/core/widgets/shimmer_list_tile.dart';
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
          itemCount: 4,
          itemBuilder: (_, __) => const Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ShimmerListTile(),
          ),
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
          itemCount: controller.posts.length + 1,
          itemBuilder: (context, index) {
            if (index == controller.posts.length) {
              if (controller.isLoadingMore.value) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              if (controller.hasMore.value) {
                WidgetsBinding.instance.addPostFrameCallback((_) => controller.loadMore());
              }
              return const SizedBox(height: 80);
            }

            final post = controller.posts[index];
            return _FeedPostItem(post: post, controller: controller);
          },
        ),
      );
    });
  }
}

class _FeedPostItem extends StatelessWidget {
  const _FeedPostItem({required this.post, required this.controller});

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
        );
    }
  }
}
