import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class CvUploadZone extends StatelessWidget {
  const CvUploadZone({
    super.key,
    required this.policyLabel,
    required this.enabled,
    required this.onTap,
    this.compact = false,
  });

  final String policyLabel;
  final bool enabled;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 20, vertical: compact ? 0 : 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: CustomPaint(
            painter: _DashedRectPainter(
              color: enabled ? context.appColors.border : context.appColors.border.withValues(alpha: 0.5),
              radius: 16,
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: compact ? 24 : 36, horizontal: 20),
              child: Column(
                children: [
                  _UploadIllustration(enabled: enabled),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.dragDropCv,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: enabled ? context.appColors.heading : context.appColors.muted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.orTapToBrowse,
                    style: TextStyle(color: context.appColors.muted, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: context.appColors.border, height: 1),
                  const SizedBox(height: 12),
                  Text(
                    policyLabel,
                    style: TextStyle(color: context.appColors.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UploadIllustration extends StatelessWidget {
  const _UploadIllustration({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final docColor = enabled ? context.appColors.muted : context.appColors.border;
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(72, 72),
            painter: _DashedCirclePainter(color: context.appColors.border),
          ),
          Icon(Icons.description_outlined, size: 28, color: docColor),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  _DashedRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)));
    _drawDashedPath(canvas, path, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    _drawDashedPath(canvas, path, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) => oldDelegate.color != color;
}

void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
  const dashWidth = 6.0;
  const dashSpace = 4.0;
  for (final metric in path.computeMetrics()) {
    var distance = 0.0;
    while (distance < metric.length) {
      final next = distance + dashWidth;
      final extractPath = metric.extractPath(distance, next.clamp(0, metric.length));
      canvas.drawPath(extractPath, paint);
      distance = next + dashSpace;
    }
  }
}
