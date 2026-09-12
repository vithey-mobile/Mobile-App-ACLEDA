import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/home/home_controller.dart';
import 'package:aub_connect_app/modules/home/widgets/media_fullscreen_viewer.dart';
import 'package:aub_connect_app/modules/home/widgets/post_card.dart';
import 'package:aub_connect_app/modules/home/widgets/post_owner_actions.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/icons/vithey_icons.dart';

class VideoPostCard extends StatefulWidget {
  const VideoPostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onFollow,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    this.onReact,
    this.onAuthorTap,
  });

  final FeedPost post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onFollow;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<PostReactionType>? onReact;
  final VoidCallback? onAuthorTap;

  @override
  State<VideoPostCard> createState() => _VideoPostCardState();
}

class _VideoPostCardState extends State<VideoPostCard> {
  VideoPlayerController? _playerController;
  bool _isPlayerInitialized = false;

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _initPlayer(String videoUrl) {
    _disposePlayer();
    final controller = videoUrl.startsWith('http://') || videoUrl.startsWith('https://')
        ? VideoPlayerController.networkUrl(Uri.parse(videoUrl))
        : videoUrl.startsWith('assets/')
            ? VideoPlayerController.asset(videoUrl)
            : VideoPlayerController.file(File(videoUrl));

    _playerController = controller;
    controller.initialize().then((_) {
      if (mounted && _playerController == controller) {
        setState(() {
          _isPlayerInitialized = true;
        });
        controller.setLooping(true);
        controller.play();
      }
    }).catchError((_) {
      if (mounted) {
        setState(() {
          _isPlayerInitialized = false;
        });
      }
    });
  }

  void _disposePlayer() {
    _playerController?.pause();
    _playerController?.dispose();
    _playerController = null;
    _isPlayerInitialized = false;
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final post = widget.post;

    return Obx(() {
      final isPlaying = controller.activeVideoId.value == post.id;
      final videoUrl = post.mediaUrl ?? post.thumbnailUrl;

      if (isPlaying && videoUrl != null && videoUrl.isNotEmpty) {
        if (_playerController == null) {
          _initPlayer(videoUrl);
        } else if (_isPlayerInitialized && !_playerController!.value.isPlaying) {
          _playerController!.play();
        }
      } else if (!isPlaying && _playerController != null) {
        _disposePlayer();
      }

      final hasMedia = (post.thumbnailUrl?.isNotEmpty == true) ||
          (post.mediaUrl?.isNotEmpty == true);

      Widget? body;
      if (post.processingState == VideoProcessingState.processing) {
        body = Container(
          height: 360,
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
      } else if (hasMedia) {
        body = AspectRatio(
          aspectRatio: 9 / 16,
          child: Container(
            color: Colors.black,
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                if (isPlaying && _isPlayerInitialized && _playerController != null)
                  FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: _playerController!.value.size.width > 0
                          ? _playerController!.value.size.width
                          : 360,
                      height: _playerController!.value.size.height > 0
                          ? _playerController!.value.size.height
                          : 640,
                      child: VideoPlayer(_playerController!),
                    ),
                  )
                else
                  _buildPreviewImage(post.thumbnailUrl ?? post.mediaUrl),

                // Play / Pause Overlay Button
                Center(
                  child: GestureDetector(
                    onTap: () {
                      if (isPlaying) {
                        controller.setActiveVideo(null);
                      } else {
                        controller.setActiveVideo(post.id);
                      }
                    },
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: VitheyIcon(
                        isPlaying ? LucideIcons.pause : LucideIcons.play,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),

                // Duration Pill
                if (post.durationSeconds > 0)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(VitheyRadii.pill),
                      ),
                      child: Text(
                        _formatDuration(post.durationSeconds),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }

      return PostCard(
        post: post,
        headerTrailing: post.isOwnPost
            ? PostOwnerActions(onEdit: widget.onEdit, onDelete: widget.onDelete)
            : Material(
                color: context.scheme.primary,
                borderRadius: BorderRadius.circular(VitheyRadii.pill),
                child: InkWell(
                  onTap: widget.onFollow,
                  borderRadius: BorderRadius.circular(VitheyRadii.pill),
                  child: SizedBox(
                    height: 28,
                    width: post.isFollowingAuthor ? 70 : 58,
                    child: Center(
                      child: Text(
                        post.isFollowingAuthor ? 'Following' : 'Follow',
                        style: context.text.labelLarge?.copyWith(
                          fontSize: 12,
                          color: context.scheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        body: body,
        onLike: widget.onLike,
        onReact: widget.onReact,
        onComment: widget.onComment,
        onShare: widget.onShare,
        onBodyTap: () {
          final url = post.mediaUrl ?? post.thumbnailUrl;
          if (url == null || url.isEmpty) {
            widget.onOpen();
            return;
          }
          showMediaFullscreen(
            context,
            post,
            onLike: widget.onLike,
            onComment: widget.onComment,
            onShare: widget.onShare,
            onFollow: widget.onFollow,
            onAuthorTap: widget.onAuthorTap,
          );
        },
        onAuthorTap: widget.onAuthorTap,
      );
    });
  }

  Widget _buildPreviewImage(String? url) {
    if (url == null || url.isEmpty) {
      return const ColoredBox(
        color: Colors.black87,
        child: Center(child: VitheyIcon(LucideIcons.video, size: 48, color: Colors.white54)),
      );
    }
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => CachedNetworkImage(
          imageUrl: 'https://picsum.photos/seed/${widget.post.id}/720/1280',
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => const ColoredBox(
            color: Colors.black87,
            child: Center(child: VitheyIcon(LucideIcons.video, size: 48, color: Colors.white54)),
          ),
        ),
      );
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const ColoredBox(
          color: Colors.black87,
          child: Center(child: VitheyIcon(LucideIcons.video, size: 48, color: Colors.white54)),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => const ColoredBox(
        color: Colors.black87,
        child: Center(child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2)),
      ),
      errorWidget: (_, __, ___) => const ColoredBox(
        color: Colors.black87,
        child: Center(child: VitheyIcon(LucideIcons.video, size: 48, color: Colors.white54)),
      ),
    );
  }
}
