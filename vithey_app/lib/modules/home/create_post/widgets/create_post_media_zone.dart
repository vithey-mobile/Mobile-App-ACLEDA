import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/icons/vithey_icons.dart';

class CreatePostMediaZone extends StatefulWidget {
  const CreatePostMediaZone({
    super.key,
    required this.mediaPath,
    required this.isVideo,
    required this.isUploading,
    required this.onPick,
    required this.onClear,
  });

  final String? mediaPath;
  final bool isVideo;
  final bool isUploading;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  State<CreatePostMediaZone> createState() => _CreatePostMediaZoneState();
}

class _CreatePostMediaZoneState extends State<CreatePostMediaZone> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _initVideoIfNeeded();
  }

  @override
  void didUpdateWidget(covariant CreatePostMediaZone oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaPath != widget.mediaPath || oldWidget.isVideo != widget.isVideo) {
      _disposeVideo();
      _initVideoIfNeeded();
    }
  }

  void _initVideoIfNeeded() {
    final path = widget.mediaPath;
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
    final mediaPath = widget.mediaPath;
    final isRemote = mediaPath?.startsWith('http://') == true ||
        mediaPath?.startsWith('https://') == true;

    return GestureDetector(
      onTap: widget.isUploading ? null : widget.onPick,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.appColors.inputFill,
        ),
        child: mediaPath == null
            ? SizedBox(
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
                      'Tap to add photo or video',
                      style: TextStyle(color: context.appColors.muted),
                    ),
                  ],
                ),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.isVideo)
                    _videoController != null && _videoController!.value.isInitialized
                        ? ClipRRect(
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
                        : Container(
                            height: 220,
                            width: double.infinity,
                            color: Colors.black87,
                            child: const Center(
                              child: CircularProgressIndicator(color: Colors.white70),
                            ),
                          )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 440),
                      child: isRemote
                          ? Image.network(
                              mediaPath,
                              width: double.infinity,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const SizedBox(
                                height: 180,
                                child: Center(
                                  child: VitheyIcon(LucideIcons.imageOff),
                                ),
                              ),
                            )
                          : Image.file(
                              File(mediaPath),
                              width: double.infinity,
                              fit: BoxFit.contain,
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
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                        ),
                        icon: const VitheyIcon(LucideIcons.x,
                            color: Colors.white, size: 18),
                        onPressed: widget.isUploading ? null : widget.onClear,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
