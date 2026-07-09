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
    return GestureDetector(
      onTap: isUploading ? null : onPick,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.appColors.inputFill,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.appColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: mediaPath == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined, size: 40, color: context.appColors.muted),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to add photo or video',
                    style: TextStyle(color: context.appColors.muted),
                  ),
                ],
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  if (isVideo)
                    ColoredBox(
                      color: Colors.black87,
                      child: Center(
                        child: Icon(Icons.videocam, size: 48, color: context.scheme.onPrimary),
                      ),
                    )
                  else
                    Image.file(File(mediaPath!), fit: BoxFit.cover),
                  if (isUploading)
                    const ColoredBox(
                      color: Colors.black45,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton.filled(
                      style: IconButton.styleFrom(backgroundColor: Colors.black54),
                      icon: const Icon(Icons.close, color: Colors.white, size: 18),
                      onPressed: isUploading ? null : onClear,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
