import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:aub_connect_app/core/utils/media_url_resolver.dart';
import 'package:aub_connect_app/core/widgets/vithey_media_image.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class PostDetailMedia extends StatefulWidget {
  const PostDetailMedia({super.key, required this.post});

  final FeedPost post;

  @override
  State<PostDetailMedia> createState() => _PostDetailMediaState();
}

class _PostDetailMediaState extends State<PostDetailMedia>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _initializing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      if (_controller != null && _controller!.value.isPlaying) {
        _controller!.pause();
        if (mounted) setState(() {});
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initPlayer() async {
    if (_controller != null || _initializing) return;
    final resolved = MediaUrlResolver.resolve(widget.post.mediaUrl);
    if (resolved.isEmpty) return;

    setState(() {
      _initializing = true;
      _error = null;
    });

    try {
      final controller = resolved.isLocalFile
          ? VideoPlayerController.file(File(resolved.url))
          : (resolved.isAsset
              ? VideoPlayerController.asset(resolved.url)
              : VideoPlayerController.networkUrl(
                  Uri.parse(resolved.url),
                  httpHeaders: resolved.headers ?? const {},
                ));
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
    } catch (e) {
      if (mounted) {
        setState(() {
          _initializing = false;
          _error = 'Could not play video';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.post.type) {
      case PostType.poster:
      case PostType.job:
        return _buildImageGallery(widget.post.displayMediaUrls);
      case PostType.video:
        return _buildVideo();
    }
  }

  Widget _buildImageGallery(List<String> urls) {
    if (urls.isEmpty) return _placeholder();
    if (urls.length == 1) return _buildImage(urls.first);

    return AspectRatio(
      aspectRatio: 1.04,
      child: _DetailImageCarousel(urls: urls, buildImage: _buildImage),
    );
  }

  Widget _buildImage(String? url) {
    if (url == null || url.isEmpty) {
      return _placeholder();
    }
    return VitheyMediaImage(
      url: url,
      width: double.infinity,
      fit: BoxFit.contain,
      errorWidget: _placeholder(),
      placeholder: _placeholder(loading: true),
    );
  }

  Widget _buildVideo() {
    if (_controller != null && _controller!.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller!),
            IconButton(
              iconSize: 56,
              color: Colors.white70,
              icon: VitheyIcon(_controller!.value.isPlaying
                  ? LucideIcons.circlePause
                  : LucideIcons.circlePlay),
              onPressed: () {
                setState(() {
                  _controller!.value.isPlaying
                      ? _controller!.pause()
                      : _controller!.play();
                });
              },
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _initPlayer,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildImage(widget.post.thumbnailUrl ?? widget.post.mediaUrl),
          if (_initializing)
            const CircularProgressIndicator(color: Colors.white)
          else
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                  color: context.scheme.onSurfaceVariant,
                  shape: BoxShape.circle),
              child:
                  const VitheyIcon(LucideIcons.play, color: Colors.white, size: 40),
            ),
          if (_error != null)
            Positioned(
              bottom: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: context.scheme.onSurfaceVariant,
                child:
                    Text(_error!, style: const TextStyle(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholder({bool loading = false}) {
    return Container(
      height: 240,
      color: context.appColors.inputFill,
      alignment: Alignment.center,
      child: loading
          ? const CircularProgressIndicator(strokeWidth: 2)
          : const VitheyIcon(LucideIcons.imageOff),
    );
  }
}

class _DetailImageCarousel extends StatefulWidget {
  const _DetailImageCarousel({
    required this.urls,
    required this.buildImage,
  });

  final List<String> urls;
  final Widget Function(String url) buildImage;

  @override
  State<_DetailImageCarousel> createState() => _DetailImageCarouselState();
}

class _DetailImageCarouselState extends State<_DetailImageCarousel> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final count = widget.urls.length;
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: count,
          onPageChanged: (index) => setState(() => _page = index),
          itemBuilder: (_, index) =>
              Center(child: widget.buildImage(widget.urls[index])),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(count, (index) {
              final active = index == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active
                      ? context.scheme.primary
                      : context.appColors.muted.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
