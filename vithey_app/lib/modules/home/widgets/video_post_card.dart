import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:aub_connect_app/core/utils/media_url_resolver.dart';
import 'package:aub_connect_app/core/widgets/vithey_media_image.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/home/home_controller.dart';
import 'package:aub_connect_app/modules/home/widgets/media_fullscreen_viewer.dart';
import 'package:aub_connect_app/modules/home/widgets/post_card.dart';
import 'package:aub_connect_app/modules/home/widgets/post_owner_actions.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/navigation/main_tab_navigation.dart';
import 'package:aub_connect_app/modules/home/shell/main_shell_screen.dart';
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

class _VideoPostCardState extends State<VideoPostCard> with WidgetsBindingObserver {
  VideoPlayerController? _playerController;
  bool _isPlayerInitialized = false;

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final videoUrl = widget.post.mediaUrl ?? widget.post.thumbnailUrl;
    if (videoUrl != null && videoUrl.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final controller = Get.find<HomeController>();
          final isHomeTabActive = !Get.isRegistered<MainShellController>() ||
              Get.find<MainShellController>().currentIndex.value ==
                  MainTabNavigation.home;
          final isPlaying = isHomeTabActive && controller.activeVideoId.value == widget.post.id;
          _initPlayer(videoUrl, autoPlay: isPlaying);
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _playerController?.pause();
      if (Get.isRegistered<HomeController>()) {
        final controller = Get.find<HomeController>();
        if (controller.activeVideoId.value == widget.post.id) {
          controller.setActiveVideo(null);
        }
      }
    }
  }

  @override
  void didUpdateWidget(covariant VideoPostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldUrl = oldWidget.post.mediaUrl ?? oldWidget.post.thumbnailUrl;
    final newUrl = widget.post.mediaUrl ?? widget.post.thumbnailUrl;
    if (oldUrl != newUrl) {
      if (newUrl != null && newUrl.isNotEmpty) {
        final controller = Get.find<HomeController>();
        final isPlaying = controller.activeVideoId.value == widget.post.id;
        _initPlayer(newUrl, autoPlay: isPlaying);
      } else {
        _disposePlayer();
      }
    }
  }

  void _initPlayer(String videoUrl, {bool autoPlay = false}) {
    _disposePlayer();
    final resolved = MediaUrlResolver.resolve(videoUrl);
    if (resolved.isEmpty) return;
    final controller = resolved.isAsset
        ? VideoPlayerController.asset(resolved.url)
        : resolved.isLocalFile
            ? VideoPlayerController.file(File(resolved.url))
            : VideoPlayerController.networkUrl(
                Uri.parse(resolved.url),
                httpHeaders: resolved.headers ?? const {},
              );

    _playerController = controller;
    controller.initialize().then((_) {
      if (mounted && _playerController == controller) {
        setState(() {
          _isPlayerInitialized = true;
        });
        controller.setLooping(true);
        if (Get.isRegistered<HomeController>()) {
          final homeCtrl = Get.find<HomeController>();
          controller.setVolume(homeCtrl.isVideoMuted.value ? 0 : 1);
        }
        if (autoPlay) {
          controller.play();
        }
      }
    }).catchError((err) {
      debugPrint('VideoPostCard init error: $err');
      if (mounted && _playerController == controller) {
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
    WidgetsBinding.instance.removeObserver(this);
    _disposePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final post = widget.post;

    return Obx(() {
      final isHomeTabActive = !Get.isRegistered<MainShellController>() ||
          Get.find<MainShellController>().currentIndex.value ==
              MainTabNavigation.home;
      final isPlaying = isHomeTabActive && controller.activeVideoId.value == post.id;
      final isMuted = controller.isVideoMuted.value;
      final videoUrl = post.mediaUrl ?? post.thumbnailUrl;

      if (_playerController == null && videoUrl != null && videoUrl.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _playerController == null) {
            _initPlayer(videoUrl, autoPlay: isPlaying);
          }
        });
      } else if (_isPlayerInitialized && _playerController != null) {
        _playerController!.setVolume(isMuted ? 0 : 1);
        if (isPlaying && !_playerController!.value.isPlaying) {
          _playerController!.play();
        } else if (!isPlaying && _playerController!.value.isPlaying) {
          _playerController!.pause();
        }
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
        // Full height based on video as before (defaulting to 9/16, or video's actual ratio)
        double videoRatio = 9 / 16;
        if (_isPlayerInitialized &&
            _playerController != null &&
            _playerController!.value.isInitialized) {
          final r = _playerController!.value.aspectRatio;
          if (r > 0 && !r.isNaN && !r.isInfinite) {
            videoRatio = r;
          }
        }

        body = AspectRatio(
          aspectRatio: videoRatio,
          child: Container(
            color: Colors.black,
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                if (_isPlayerInitialized && _playerController != null)
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
                else if (post.thumbnailUrl != null &&
                    post.thumbnailUrl!.isNotEmpty &&
                    FeedPost.looksLikeImageUrl(post.thumbnailUrl!))
                  VitheyMediaImage(
                    url: post.thumbnailUrl!,
                    fit: BoxFit.cover,
                    fallbackColor: Colors.black,
                    iconColor: Colors.white54,
                  )
                else
                  Container(
                    color: const Color(0xFF0F172A),
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ),

                // Tap handler to toggle play / pause inline
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (isPlaying) {
                        controller.setActiveVideo(null);
                      } else {
                        controller.setActiveVideo(post.id);
                      }
                    },
                  ),
                ),

                // Single Play / Pause Button Overlay (hidden when playing)
                if (!isPlaying)
                  IgnorePointer(
                    child: Center(
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: VitheyIcon(
                            LucideIcons.play,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Fullscreen button in top right
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
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
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const VitheyIcon(
                        LucideIcons.maximize2,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),

                // Duration Pill
                if (post.durationSeconds > 0)
                  Positioned(
                    left: 12,
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

                // Mute / Unmute Button in bottom right
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      controller.toggleVideoMute();
                      if (_playerController != null && _isPlayerInitialized) {
                        _playerController!.setVolume(controller.isVideoMuted.value ? 0 : 1);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: VitheyIcon(
                        isMuted ? LucideIcons.volumeX : LucideIcons.volume2,
                        color: Colors.white,
                        size: 16,
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
                color: post.isFollowingAuthor
                    ? context.scheme.surfaceContainerHighest
                    : context.scheme.primary,
                borderRadius: BorderRadius.circular(VitheyRadii.pill),
                child: InkWell(
                  onTap: widget.onFollow,
                  borderRadius: BorderRadius.circular(VitheyRadii.pill),
                  child: Container(
                    height: 28,
                    width: post.isFollowingAuthor ? 70 : 58,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(VitheyRadii.pill),
                      border: post.isFollowingAuthor
                          ? Border.all(color: context.scheme.outlineVariant)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        post.isFollowingAuthor ? 'Following' : 'Follow',
                        style: context.text.labelLarge?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: post.isFollowingAuthor
                              ? context.scheme.onSurfaceVariant
                              : context.scheme.onPrimary,
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
          controller.setActiveVideo(null);
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
}
