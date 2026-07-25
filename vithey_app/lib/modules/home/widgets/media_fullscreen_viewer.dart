import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:aub_connect_app/core/utils/relative_time.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/home/widgets/feed_action_bar.dart';

/// Opens poster image or video on a black fullscreen stage (same pattern as job poster).
Future<void> showMediaFullscreen(
  BuildContext context,
  FeedPost post, {
  VoidCallback? onLike,
  VoidCallback? onComment,
  VoidCallback? onShare,
}) {
  return Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: true,
      barrierColor: Colors.black,
      pageBuilder: (ctx, _, __) => MediaFullscreenViewer(
        post: post,
        onLike: onLike,
        onComment: onComment,
        onShare: onShare,
      ),
    ),
  );
}

class MediaFullscreenViewer extends StatefulWidget {
  const MediaFullscreenViewer({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
  });

  final FeedPost post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  @override
  State<MediaFullscreenViewer> createState() => _MediaFullscreenViewerState();
}

class _MediaFullscreenViewerState extends State<MediaFullscreenViewer> {
  late FeedPost _post;
  VideoPlayerController? _controller;
  bool _initializing = false;
  String? _error;

  bool get _isVideo => _post.type == PostType.video;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    if (_isVideo) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initPlayer());
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _toggleLike() {
    widget.onLike?.call();
    setState(() {
      final liked = !_post.userReacted;
      _post = _post.copyWith(
        userReacted: liked,
        reactionCount: (_post.reactionCount + (liked ? 1 : -1)).clamp(0, 1 << 30),
      );
    });
  }

  void _onComment() => widget.onComment?.call();

  void _onShare() {
    widget.onShare?.call();
    final title = _captionTitle ?? 'Vithey post';
    Share.share(title);
  }

  Future<void> _initPlayer() async {
    if (_controller != null || _initializing) return;
    final url = _post.mediaUrl;
    if (url == null || url.isEmpty) return;

    setState(() {
      _initializing = true;
      _error = null;
    });

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _initializing = false;
      });
      await controller.play();
      controller.addListener(() {
        if (mounted) setState(() {});
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _initializing = false;
          _error = 'Could not play video';
        });
      }
    }
  }

  String? get _captionTitle {
    final t = _post.jobMeta.title?.trim();
    if (t != null && t.isNotEmpty) return t;
    final c = _post.content.trim();
    if (c.isEmpty) return null;
    return c.length > 80 ? '${c.substring(0, 80)}…' : c;
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final title = _captionTitle;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_isVideo) _buildVideoStage() else _buildImageStage(),
          Positioned(
            top: topInset + 4,
            right: 4,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.close),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                    Colors.black.withValues(alpha: 0.92),
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(8, 28, 8, 8 + bottomInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          RelativeTime.format(_post.createdAt),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    FeedActionBar(
                      post: _post,
                      onLike: _toggleLike,
                      onComment: _onComment,
                      onShare: _onShare,
                      alignStart: true,
                      onDark: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageStage() {
    final url = _post.mediaUrl;
    return InteractiveViewer(
      minScale: 0.8,
      maxScale: 4,
      child: Center(child: _FullscreenImage(url: url, fit: BoxFit.contain)),
    );
  }

  Widget _buildVideoStage() {
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio == 0
              ? 16 / 9
              : controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(controller),
              IconButton(
                iconSize: 64,
                color: Colors.white70,
                icon: Icon(
                  controller.value.isPlaying
                      ? Icons.pause_circle
                      : Icons.play_circle,
                ),
                onPressed: () {
                  setState(() {
                    controller.value.isPlaying
                        ? controller.pause()
                        : controller.play();
                  });
                },
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: _FullscreenImage(
            url: _post.thumbnailUrl ?? _post.mediaUrl,
            fit: BoxFit.contain,
          ),
        ),
        Center(
          child: _initializing
              ? const CircularProgressIndicator(color: Colors.white)
              : IconButton(
                  iconSize: 64,
                  color: Colors.white70,
                  icon: const Icon(Icons.play_circle),
                  onPressed: _initPlayer,
                ),
        ),
        if (_error != null)
          Positioned(
            left: 20,
            right: 20,
            bottom: 100,
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
      ],
    );
  }
}

class _FullscreenImage extends StatelessWidget {
  const _FullscreenImage({required this.url, required this.fit});

  final String? url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const Icon(Icons.image_not_supported_outlined, color: Colors.white54, size: 48);
    }
    if (url!.startsWith('assets/')) {
      return Image.asset(url!, fit: fit);
    }
    return CachedNetworkImage(
      imageUrl: url!,
      fit: fit,
      placeholder: (_, __) => const Center(
        child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
      ),
      errorWidget: (_, __, ___) =>
          const Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48),
    );
  }
}
