import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/home/home_controller.dart';
import 'package:aub_connect_app/modules/home/widgets/post_card.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class VideoPostCard extends StatelessWidget {
  const VideoPostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onFollow,
    required this.onOpen,
    this.onAuthorTap,
  });

  final FeedPost post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onFollow;
  final VoidCallback onOpen;
  final VoidCallback? onAuthorTap;

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final isPlaying = controller.activeVideoId.value == post.id;

    Widget body;
    if (post.processingState == VideoProcessingState.processing) {
      body = Container(
        height: 220,
        color: context.appColors.inputFill,
        alignment: Alignment.center,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(strokeWidth: 2),
            SizedBox(height: 8),
            Text('Video is processing'),
          ],
        ),
      );
    } else {
      body = Stack(
        alignment: Alignment.center,
        children: [
          PostMediaImage(url: post.thumbnailUrl ?? post.mediaUrl, height: 220),
          GestureDetector(
            onTap: () {
              if (isPlaying) {
                controller.setActiveVideo(null);
              } else {
                controller.setActiveVideo(post.id);
              }
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: context.scheme.onSurfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 32),
            ),
          ),
          if (post.durationSeconds > 0)
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.scheme.onSurfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatDuration(post.durationSeconds),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      );
    }

    return PostCard(
      post: post,
      headerTrailing: post.isOwnPost
          ? null
          : TextButton(
              onPressed: onFollow,
              child: Text(post.isFollowingAuthor ? 'Following' : 'Follow'),
            ),
      body: body,
      onLike: onLike,
      onComment: onComment,
      onShare: onShare,
      onBodyTap: onOpen,
      onAuthorTap: onAuthorTap,
    );
  }
}
