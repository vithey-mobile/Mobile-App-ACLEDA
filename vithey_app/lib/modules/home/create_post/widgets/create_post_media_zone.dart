import 'dart:io';

import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class CreatePostMediaZone extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isRemote = mediaPath?.startsWith('http://') == true ||
        mediaPath?.startsWith('https://') == true;
    return GestureDetector(
      onTap: isUploading ? null : onPick,
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
                    Icon(
                      Icons.add_photo_alternate_outlined,
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
                children: [
                  if (isVideo)
                    SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: ColoredBox(
                        color: Colors.black87,
                        child: Center(
                          child: Icon(
                            Icons.videocam,
                            size: 48,
                            color: context.scheme.onPrimary,
                          ),
                        ),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 440),
                      child: isRemote
                          ? Image.network(
                              mediaPath!,
                              width: double.infinity,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const SizedBox(
                                height: 180,
                                child: Center(
                                  child: Icon(Icons.broken_image_outlined),
                                ),
                              ),
                            )
                          : Image.file(
                              File(mediaPath!),
                              width: double.infinity,
                              fit: BoxFit.contain,
                            ),
                    ),
                  if (isUploading)
                    const Positioned.fill(
                      child: ColoredBox(
                        color: Colors.black45,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: IconButton.filled(
                      style:
                          IconButton.styleFrom(backgroundColor: Colors.black54),
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 18),
                      onPressed: isUploading ? null : onClear,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
