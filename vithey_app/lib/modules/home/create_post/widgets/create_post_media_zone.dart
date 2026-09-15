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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.appColors.inputFill,
      ),
      child: paths.isEmpty
          ? GestureDetector(
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
            )
          : widget.isVideo
              ? _buildVideoPreview(context, paths.first)
              : _buildImageGallery(context, paths),
    );
  }

  Widget _buildVideoPreview(BuildContext context, String mediaPath) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (_videoController != null && _videoController!.value.isInitialized)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio == 0
                  ? 16 / 9
                  : _videoController!.value.aspectRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_videoController!),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_videoController!.value.isPlaying) {
                          _videoController!.pause();
                        } else {
                          _videoController!.play();
                        }
                      });
                    },
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
                ],
              ),
            ),
          )
        else
          Container(
            height: 220,
            width: double.infinity,
            color: Colors.black87,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white70),
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
    );
  }

  Widget _buildImageGallery(BuildContext context, List<String> paths) {
    final count = paths.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 280,
          child: PageView.builder(
            itemCount: count,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, index) {
              final path = paths[index];
              final isRemote =
                  path.startsWith('http://') || path.startsWith('https://');
              return Stack(
                fit: StackFit.expand,
                children: [
                  isRemote
                      ? Image.network(
                          path,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: VitheyIcon(LucideIcons.imageOff),
                          ),
                        )
                      : Image.file(
                          File(path),
                          fit: BoxFit.cover,
                        ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _CircleIconButton(
                      icon: LucideIcons.x,
                      onPressed: widget.isUploading
                          ? null
                          : () => widget.onRemoveAt(index),
                    ),
                  ),
                  if (count > 1)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius:
                              BorderRadius.circular(VitheyRadii.pill),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: Text(
                            '${index + 1}/$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        if (widget.isUploading)
          const LinearProgressIndicator(minHeight: 2),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Row(
            children: [
              if (count > 1)
                Expanded(
                  child: Text(
                    '$count photos selected',
                    style: context.text.bodySmall?.copyWith(
                      color: context.appColors.muted,
                    ),
                  ),
                )
              else
                const Spacer(),
              TextButton.icon(
                onPressed: widget.isUploading ? null : widget.onPick,
                icon: const VitheyIcon(LucideIcons.imagePlus, size: 18),
                label: const Text('Add photos'),
              ),
            ],
          ),
        ),
      ],
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
      width: 36,
      height: 36,
      child: IconButton.filled(
        style: IconButton.styleFrom(
          backgroundColor: Colors.black54,
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        icon: VitheyIcon(icon, color: Colors.white, size: 18),
        onPressed: onPressed,
      ),
    );
  }
}
