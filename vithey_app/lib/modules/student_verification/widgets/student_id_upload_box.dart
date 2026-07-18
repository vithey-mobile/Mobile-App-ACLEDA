import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_assets.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

/// Empty dashed dropzone (Screen 1) or selected-file row (Screen 2).
class StudentIdUploadBox extends StatelessWidget {
  const StudentIdUploadBox({
    super.key,
    required this.fileName,
    required this.onPick,
    required this.onRemove,
    this.fileSizeBytes,
  });

  final String? fileName;
  final int? fileSizeBytes;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Student Document',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: context.appColors.heading,
          ),
        ),
        const SizedBox(height: 8),
        if (fileName == null) _EmptyUpload(onPick: onPick) else _SelectedFileRow(
          fileName: fileName!,
          fileSizeBytes: fileSizeBytes,
          onRemove: onRemove,
        ),
      ],
    );
  }
}

class _EmptyUpload extends StatelessWidget {
  const _EmptyUpload({required this.onPick});

  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: context.appColors.border,
            radius: 16,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            child: Column(
              children: [
                Image.asset(
                  AppAssets.uploadIcon,
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  gaplessPlayback: true,
                ),
                const SizedBox(height: 14),
                Text(
                  'Drag & drop your file here',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: context.appColors.heading,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'or tap to browse',
                  style: TextStyle(color: context.appColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Divider(height: 1, color: context.appColors.border),
                const SizedBox(height: 12),
                Text(
                  'JPG, PNG, or PDF (Max 5MB)',
                  style: TextStyle(color: context.appColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedFileRow extends StatelessWidget {
  const _SelectedFileRow({
    required this.fileName,
    required this.onRemove,
    this.fileSizeBytes,
  });

  final String fileName;
  final int? fileSizeBytes;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.appColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.appColors.border),
      ),
      child: Row(
        children: [
          Icon(_iconForName(fileName), color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: context.appColors.heading,
                  ),
                ),
                if (fileSizeBytes != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatBytes(fileSizeBytes!),
                    style: TextStyle(color: context.appColors.muted, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            tooltip: 'Remove',
            icon: Icon(Icons.cancel_outlined, color: context.appColors.muted),
          ),
        ],
      ),
    );
  }

  IconData _iconForName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.pdf')) return Icons.picture_as_pdf_outlined;
    if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      return Icons.description_outlined;
    }
    if (lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp')) {
      return Icons.image_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(kb < 10 ? 1 : 0)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ),
      );

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
