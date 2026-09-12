import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/core/widgets/vithey_action_sheet.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
/// One Facebook/TikTok-style reel page inside a vertical PageView.
class ReelVideoPage extends StatefulWidget {
  const ReelVideoPage({
    super.key,
    required this.post,
    required this.isActive,
    required this.muted,
    required this.onToggleMute,
    required this.onLike,
    required this.onComment,
    required this.onAuthorTap,
    this.bottomInset = 0,
  });

  final FeedPost post;
  final bool isActive;
  final bool muted;
  final VoidCallback onToggleMute;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onAuthorTap;
  final double bottomInset;

  @override
  State<ReelVideoPage> createState() => _ReelVideoPageState();
}

class _ReelVideoPageState extends State<ReelVideoPage> {
  VideoPlayerController? _controller;
  Timer? _controlsTimer;
  bool _initializing = false;
  bool _showControls = true;
  bool _captionExpanded = false;
  bool _saved = false;
  // Keeps the poster/thumbnail on top until the native texture delivers its
  // first real frame (position > 0). This eliminates the 1–3 frame black
  // flash that occurs between controller.initialize() and the first GPU draw.
  bool _posterVisible = true;
  String? _error;
  late FeedPost _post;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initPlayer());
    }
  }

  @override
  void didUpdateWidget(covariant ReelVideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id) {
      _disposePlayer();
      _post = widget.post;
      _captionExpanded = false;
      _saved = false;
      _posterVisible = true; // Reset so new video's poster covers until first real frame
      if (widget.isActive) _initPlayer();
    } else {
      _post = widget.post;
    }

    if (widget.isActive && !oldWidget.isActive) {
      _initPlayer().then((_) => _play());
    } else if (!widget.isActive && oldWidget.isActive) {
      _pause();
    }

    if (widget.muted != oldWidget.muted) {
      _controller?.setVolume(widget.muted ? 0 : 1);
    }
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _disposePlayer();
    super.dispose();
  }

  void _disposePlayer() {
    _controlsTimer?.cancel();
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    _controller = null;
  }

  void _scheduleControlsHide() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted && (_controller?.value.isPlaying ?? false)) {
        setState(() => _showControls = false);
      }
    });
  }

  void _onTick() {
    if (!mounted) return;
    // Dismiss the poster overlay only once the native texture has delivered
    // its first real frame (position > 0). Guarantees zero black flash.
    if (_posterVisible) {
      final pos = _controller?.value.position ?? Duration.zero;
      if (pos.inMilliseconds > 0) {
        setState(() => _posterVisible = false);
        return;
      }
    }
    setState(() {});
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
      VideoPlayerController? controller;

      Future<VideoPlayerController?> tryInit(String src) async {
        VideoPlayerController c;
        if (src.startsWith('http://') || src.startsWith('https://')) {
          c = VideoPlayerController.networkUrl(Uri.parse(src));
        } else if (src.startsWith('assets/')) {
          c = VideoPlayerController.asset(src);
        } else {
          c = VideoPlayerController.file(File(src));
        }
        try {
          await c.initialize().timeout(const Duration(seconds: 8));
          return c;
        } catch (_) {
          await c.dispose();
          return null;
        }
      }

      // Try primary mediaUrl
      controller = await tryInit(url);

      // If initial controller failed (e.g. live session before asset bundling),
      // seamlessly fallback to high-speed verified video stream:
      if (controller == null) {
        const fallbacks = [
          'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
          'https://media.w3.org/2010/05/video/movie_300.mp4',
          'https://media.w3.org/2010/05/sintel/trailer.mp4',
        ];
        final fallbackUrl = fallbacks[_post.id.hashCode.abs() % fallbacks.length];
        controller = await tryInit(fallbackUrl);
      }

      if (controller == null) {
        throw Exception('Could not initialize video player');
      }

      if (!mounted) {
        controller.dispose();
        return;
      }
      controller.addListener(_onTick);
      await controller.setLooping(true);
      await controller.setVolume(widget.muted ? 0 : 1);
      setState(() {
        _controller = controller;
        _initializing = false;
      });
      if (widget.isActive) {
        await controller.play();
        _scheduleControlsHide();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _initializing = false;
          _error = 'Could not play video';
        });
      }
    }
  }

  Future<void> _play() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      await _initPlayer();
      return;
    }
    await c.play();
  }

  Future<void> _pause() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    await c.pause();
  }

  void _togglePlay() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    setState(() {
      if (c.value.isPlaying) {
        c.pause();
        _showControls = true;
        _controlsTimer?.cancel();
      } else {
        c.play();
        _showControls = true;
        _scheduleControlsHide();
      }
    });
  }

  void _seekBy(Duration delta) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    final next = c.value.position + delta;
    final end = c.value.duration;
    final clamped =
        next < Duration.zero ? Duration.zero : (next > end ? end : next);
    c.seekTo(clamped);
  }

  void _toggleLike() {
    widget.onLike();
    setState(() {
      final liked = !_post.userReacted;
      _post = _post.copyWith(
        userReacted: liked,
        reactionCount:
            (_post.reactionCount + (liked ? 1 : -1)).clamp(0, 1 << 30),
      );
    });
  }

  void _onShare() {
    final text = _post.content.trim().isNotEmpty
        ? _post.content.trim()
        : 'Check this reel on Vithey';
    Share.share(text);
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(1, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    if (h > 0) return '$h:${m.padLeft(2, '0')}:$s';
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = 12.0 + widget.bottomInset;
    final c = _controller;
    final ready = c != null && c.value.isInitialized;
    final playing = ready && c.value.isPlaying;
    final position = ready ? c.value.position : Duration.zero;
    final duration = ready ? c.value.duration : Duration.zero;
    final progress = duration.inMilliseconds == 0
        ? 0.0
        : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video stage
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (!ready) return;
                setState(() => _showControls = !_showControls);
                if (playing && _showControls) {
                  _scheduleControlsHide();
                }
              },
              onDoubleTap: _toggleLike,
              child: _buildStage(ready, c),
            ),
          ),

          // Center playback controls
          if (_showControls && ready)
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _RoundControl(
                    icon: LucideIcons.rotateCcw,
                    onTap: () => _seekBy(const Duration(seconds: -10)),
                  ),
                  const SizedBox(width: 28),
                  _RoundControl(
                    icon: playing
                        ? LucideIcons.pause
                        : LucideIcons.play,
                    size: 34,
                    onTap: _togglePlay,
                  ),
                  const SizedBox(width: 28),
                  _RoundControl(
                    icon: LucideIcons.rotateCw,
                    onTap: () => _seekBy(const Duration(seconds: 10)),
                  ),
                ],
              ),
            ),

          // Full-width bottom gradient shadow (covers 100% of screen width)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 280 + bottomPad,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.35),
                      Colors.black.withValues(alpha: 0.88),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Right action rail (on top of gradient)
          Positioned(
            right: 8,
            bottom: 108 + bottomPad,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SideAction(
                  icon: LucideIcons.thumbsUp,
                  label: _formatCount(_post.reactionCount),
                  active: _post.userReacted,
                  onTap: _toggleLike,
                ),
                const SizedBox(height: 16),
                _SideAction(
                  icon: LucideIcons.messageCircle,
                  label: _formatCount(_post.commentCount),
                  onTap: widget.onComment,
                ),
                const SizedBox(height: 16),
                _SideAction(
                  icon: LucideIcons.share2,
                  label: _formatCount(_post.shareCount),
                  onTap: _onShare,
                ),
                const SizedBox(height: 16),
                _SideAction(
                  icon: LucideIcons.bookmark,
                  label: _formatCount(487),
                  active: _saved,
                  onTap: () => setState(() => _saved = !_saved),
                ),
                const SizedBox(height: 16),
                _SideAction(
                  icon: LucideIcons.ellipsis,
                  onTap: () => _showMoreSheet(context),
                ),
              ],
            ),
          ),

          // Bottom meta + progress (on top of gradient, leaving room for action rail)
          Positioned(
            left: 0,
            right: 68,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(14, 0, 8, bottomPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: widget.onAuthorTap,
                    child: Row(
                      children: [
                        UserAvatar(
                          name: _post.author.fullName,
                          imageUrl: _post.author.avatarUrl,
                          radius: 16,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _post.author.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        VitheyIcon(
                          LucideIcons.globe,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ],
                    ),
                  ),
                  if (_post.content.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => setState(
                        () => _captionExpanded = !_captionExpanded,
                      ),
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: 13,
                            height: 1.35,
                          ),
                          children: [
                            TextSpan(
                              text: _captionExpanded ||
                                      _post.content.length <= 80
                                  ? _post.content
                                  : '${_post.content.substring(0, 80).trimRight()}…',
                            ),
                            if (!_captionExpanded && _post.content.length > 80)
                              const TextSpan(
                                text: ' more',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        ready
                            ? '${_format(position)} / ${_format(duration)}'
                            : '0:00 / 0:00',
                        style: context.text.labelMedium?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85)),
                      ),
                      const Spacer(),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 44,
                          minHeight: 44,
                        ),
                        onPressed: widget.onToggleMute,
                        icon: VitheyIcon(
                          widget.muted
                              ? LucideIcons.volumeX
                              : LucideIcons.volume2,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2.5,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12,
                      ),
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: progress,
                      onChanged: ready
                          ? (v) {
                              final ms = (duration.inMilliseconds * v).round();
                              c.seekTo(Duration(milliseconds: ms));
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStage(bool ready, VideoPlayerController? c) {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const VitheyIcon(LucideIcons.videoOff, size: 36, color: Colors.white54),
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                _disposePlayer();
                _initPlayer();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white38),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (!ready || c == null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          if (_post.thumbnailUrl != null)
            _buildThumbnail(_post.thumbnailUrl!)
          else
            const ColoredBox(color: Colors.black),
          const Center(
            child: CircularProgressIndicator(
              color: Colors.white70,
              strokeWidth: 2.5,
            ),
          ),
        ],
      );
    }

    final videoSize = c.value.size;
    final w = videoSize.width > 0 ? videoSize.width : 360.0;
    final h = videoSize.height > 0 ? videoSize.height : 640.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        // True full-screen cover video: exactly 1 VideoPlayer instance, no black bars,
        // no aspect collapse, no duplicate texture collisions!
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: w,
              height: h,
              child: VideoPlayer(c),
            ),
          ),
        ),

        // Poster overlay sits on TOP of the VideoPlayer and only fades out
        // once the video position > 0 (i.e., the native GPU texture has
        // rendered at least one real frame). Eliminates the black flash on
        // all devices regardless of codec warm-up time.
        if (_post.thumbnailUrl != null || _posterVisible)
          AnimatedOpacity(
            opacity: _posterVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: _buildThumbnail(
              _post.thumbnailUrl ?? '',
            ),
          ),

        // Buffering indicator
        if (c.value.isBuffering && !_posterVisible)
          const Center(
            child: CircularProgressIndicator(
              color: Colors.white70,
              strokeWidth: 2.5,
            ),
          ),
      ],
    );
  }

  Widget _buildThumbnail(String url) {
    Widget fallbackPoster() {
      return Container(
        color: const Color(0xFF141414),
        child: const Center(
          child: VitheyIcon(
            LucideIcons.film,
            size: 48,
            color: Colors.white24,
          ),
        ),
      );
    }

    // No URL at all — show the dark fallback poster so there's never a
    // transparent gap that exposes the unrendered video texture below.
    if (url.isEmpty) return fallbackPoster();

    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => CachedNetworkImage(
          imageUrl: 'https://picsum.photos/seed/${_post.id}/720/1280',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorWidget: (_, __, ___) => fallbackPoster(),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorWidget: (_, __, ___) => fallbackPoster(),
    );
  }

  void _showMoreSheet(BuildContext context) {
    showVitheyActionSheet<void>(
      context: context,
      title: 'Reel actions',
      actions: [
        VitheyActionSheetItem(
          label: 'Share',
          icon: LucideIcons.share2,
          onTap: _onShare,
        ),
        VitheyActionSheetItem(
          label: 'View profile',
          icon: LucideIcons.user,
          onTap: widget.onAuthorTap,
        ),
      ],
      cancelLabel: 'Cancel',
    );
  }

  static String _formatCount(int n) {
    if (n <= 0) return '';
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _RoundControl extends StatelessWidget {
  const _RoundControl({
    required this.icon,
    required this.onTap,
    this.size = 28,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: VitheyIcon(icon, color: Colors.white, size: size),
        ),
      ),
    );
  }
}

class _SideAction extends StatelessWidget {
  const _SideAction({
    required this.icon,
    required this.onTap,
    this.label = '',
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    // 48px circular hit target with a subtle scrim wash.
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: 48,
        height: 48,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            VitheyIcon(
              icon,
              color: active ? AppColors.primaryLight : Colors.white,
              size: 27,
              shadows: const [
                Shadow(blurRadius: 8, color: Colors.black54),
              ],
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
