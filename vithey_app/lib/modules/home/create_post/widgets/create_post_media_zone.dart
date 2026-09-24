import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/icons/vithey_icons.dart';

class CreatePostMediaZone extends StatefulWidget {
  const CreatePostMediaZone({
    super.key,
    required this.mediaPaths,
    required this.isVideo,
    required this.isUploading,
    required this.onPick,
    required this.onClearAll,
    required this.onRemoveAt,
  });

  final List<String> mediaPaths;
  final bool isVideo;
  final bool isUploading;
  final VoidCallback onPick;
  final VoidCallback onClearAll;
  final ValueChanged<int> onRemoveAt;

  @override
  State<CreatePostMediaZone> createState() => _CreatePostMediaZoneState();
}

class _CreatePostMediaZoneState extends State<CreatePostMediaZone> {
  VideoPlayerController? _videoController;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _initVideoIfNeeded();
  }

  @override
  void didUpdateWidget(covariant CreatePostMediaZone oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldFirst =
        oldWidget.mediaPaths.isEmpty ? null : oldWidget.mediaPaths.first;
    final nextFirst =
        widget.mediaPaths.isEmpty ? null : widget.mediaPaths.first;
    if (oldFirst != nextFirst ||
        oldWidget.isVideo != widget.isVideo ||
        oldWidget.mediaPaths.length != widget.mediaPaths.length) {
      _disposeVideo();
      _initVideoIfNeeded();
      if (_page >= widget.mediaPaths.length) {
        _page = widget.mediaPaths.isEmpty ? 0 : widget.mediaPaths.length - 1;
      }
    }
  }

  void _initVideoIfNeeded() {
    final path =
        widget.mediaPaths.isEmpty ? null : widget.mediaPaths.first;
    if (widget.isVideo && path != null && path.isNotEmpty) {
      final isRemote = path.startsWith('http://') || path.startsWith('https://');
      final controller = isRemote
          ? VideoPlayerController.networkUrl(Uri.parse(path))
          : VideoPlayerController.file(File(path));

      controller.initialize().then((_) {
        if (mounted) {
          controller.setLooping(true);
          controller.play();
          setState(() {
            _videoController = controller;
          });
        }
      }).catchError((_) {});
    }
  }

  void _disposeVideo() {
    _videoController?.pause();
    _videoController?.dispose();
    _videoController = null;
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paths = widget.mediaPaths;

    if (paths.isEmpty) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.appColors.inputFill,
        ),
        child: GestureDetector(
          onTap: widget.isUploading ? null : widget.onPick,
          child: SizedBox(
            height: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                VitheyIcon(
                  LucideIcons.imagePlus,
                  size: 36,
                  color: context.appColors.muted,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.isVideo
                      ? 'Tap to add video'
                      : 'Tap to add photos',
                  style: TextStyle(color: context.appColors.muted),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.isVideo
        ? _buildVideoPreview(context, paths.first)
        : paths.length == 1
            ? _buildSingleImage(context, paths.first)
            : _buildImageGallery(context, paths);
  }

  Widget _buildSingleImage(BuildContext context, String path) {
    final isRemote = path.startsWith('http://') || path.startsWith('https://');
    return ClipRRect(
      borderRadius: BorderRadius.circular(VitheyRadii.media),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 460),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
              color: context.appColors.inputFill,
              child: isRemote
                  ? Image.network(
                      path,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Center(
                        child: VitheyIcon(
                          LucideIcons.imageOff,
                          color: context.appColors.muted,
                          size: 36,
                        ),
                      ),
                    )
                  : Image.file(
                      File(path),
                      fit: BoxFit.contain,
                    ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: _CircleIconButton(
                icon: LucideIcons.x,
                onPressed: widget.isUploading
                    ? null
                    : () => widget.onRemoveAt(0),
              ),
            ),
            if (widget.isUploading)
              Positioned.fill(
                child: Container(
                  color: Colors.black38,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPreview(BuildContext context, String mediaPath) {
    return AspectRatio(
      aspectRatio: (_videoController != null &&
              _videoController!.value.isInitialized &&
              _videoController!.value.aspectRatio > 0)
          ? _videoController!.value.aspectRatio
          : 16 / 9,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          if (_videoController != null && _videoController!.value.isInitialized)
            VideoPlayer(_videoController!)
          else
            Container(
              color: Colors.black87,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white70),
              ),
            ),
          if (_videoController != null && _videoController!.value.isInitialized)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  if (_videoController!.value.isPlaying) {
                    _videoController!.pause();
                  } else {
                    _videoController!.play();
                  }
                });
              },
              child: Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _videoController!.value.isPlaying ? 0 : 0.85,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.play,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          if (widget.isUploading)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black45,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          Positioned(
            top: 10,
            left: 10,
            child: _CircleIconButton(
              icon: LucideIcons.x,
              onPressed: widget.isUploading ? null : widget.onClearAll,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(BuildContext context, List<String> paths) {
    final count = paths.length;
    final activeIndex = _page.clamp(0, count - 1);

    return ClipRRect(
      borderRadius: BorderRadius.circular(VitheyRadii.media),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 460),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                itemCount: count,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) {
                  final path = paths[index];
                  final isRemote =
                      path.startsWith('http://') || path.startsWith('https://');
                  return ColoredBox(
                    color: context.appColors.inputFill,
                    child: isRemote
                        ? Image.network(
                            path,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Center(
                              child: VitheyIcon(
                                LucideIcons.imageOff,
                                color: context.appColors.muted,
                                size: 36,
                              ),
                            ),
                          )
                        : Image.file(
                            File(path),
                            fit: BoxFit.contain,
                          ),
                  );
                },
              ),
              // Delete / Close button for active image
              Positioned(
                top: 10,
                left: 10,
                child: _CircleIconButton(
                  icon: LucideIcons.x,
                  onPressed: widget.isUploading
                      ? null
                      : () => widget.onRemoveAt(activeIndex),
                ),
              ),
              // Page counter (e.g. 1/3)
              if (count > 1)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(VitheyRadii.pill),
                    ),
                    child: Text(
                      '${activeIndex + 1}/$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              // Pagination indicator dots
              if (count > 1)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(count, (i) {
                      final active = i == activeIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),
                ),
              // Uploading overlay scrim
              if (widget.isUploading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black38,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
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

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton.filled(
        style: IconButton.styleFrom(
          backgroundColor: Colors.black.withValues(alpha: 0.55),
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        icon: VitheyIcon(icon, color: Colors.white, size: 16),
        onPressed: onPressed,
      ),
    );
  }
}
