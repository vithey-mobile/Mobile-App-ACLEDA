import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

/// Moving light-teal + sheet wavy panel (Auth v2).
/// Sheet **hugs** [child] height; wave band ≈ 10% of screen height.
/// Teal behind is auto (remaining space above this sheet).
/// Sheet color follows light/dark via [AppSemanticColors.cardSurface].
class AuthMovingWaveSheet extends StatelessWidget {
  const AuthMovingWaveSheet({
    super.key,
    required this.child,
    this.waveHeightFactor = 0.10,
  });

  final Widget child;

  /// Portion of screen height used by the light-teal + sheet wave band.
  final double waveHeightFactor;

  @override
  Widget build(BuildContext context) {
    final waveBandHeight = MediaQuery.sizeOf(context).height * waveHeightFactor;
    final sheetColor = context.appColors.cardSurface;
    final waveRearColor = AppColors.waveRearOn(sheetColor);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: waveBandHeight,
          width: double.infinity,
          child: CustomPaint(
            painter: _AuthMovingWavePainter(
              waveRearColor: waveRearColor,
              sheetColor: sheetColor,
            ),
          ),
        ),
        ColoredBox(
          color: sheetColor,
          child: child,
        ),
      ],
    );
  }
}

class _AuthMovingWavePainter extends CustomPainter {
  const _AuthMovingWavePainter({
    required this.waveRearColor,
    required this.sheetColor,
  });

  final Color waveRearColor;
  final Color sheetColor;

  // Band Y: 0 = top (teal shows through above light edge), 1 = bottom.
  // Soft 2-wave rhythm; fewer extremes for smoother Catmull.

  static const _lightX = [
    0.0,
    0.12,
    0.28,
    0.40,
    0.55,
    0.70,
    0.85,
    1.0,
  ];
  static const _lightY = [
    0.00, // 0w  top
    0.22, // ease fall
    0.45, // fall
    0.55, // near sheet (~20h gap)
    0.28, // rise — gap opens
    0.08, // high
    0.22, // soft fall
    0.18, // gentle finish
  ];

  static const _whiteX = [
    0.0,
    0.12,
    0.28,
    0.40,
    0.55,
    0.70,
    0.85,
    1.0,
  ];
  static const _whiteY = [
    1.00, // 0w  low
    0.78, // round rise
    0.64, // first crest
    0.76, // trough
    0.58, // rise
    0.46, // second crest
    0.74, // trough
    0.66, // soft rise finish
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      _fillBetweenEdges(size, _lightX, _lightY, _whiteX, _whiteY),
      Paint()..color = waveRearColor,
    );

    canvas.drawPath(
      _fillFromBottomEdge(size, _whiteX, _whiteY),
      Paint()..color = sheetColor,
    );
  }

  Path _fillBetweenEdges(
    Size size,
    List<double> lightX,
    List<double> lightY,
    List<double> whiteX,
    List<double> whiteY,
  ) {
    final light = _points(size, lightX, lightY);
    final white = _points(size, whiteX, whiteY);
    final path = Path()..moveTo(light.first.dx, light.first.dy);
    _catmull(path, light);
    path.lineTo(white.last.dx, white.last.dy);
    _catmull(path, white.reversed.toList());
    path.close();
    return path;
  }

  Path _fillFromBottomEdge(Size size, List<double> xFrac, List<double> yFrac) {
    final pts = _points(size, xFrac, yFrac);
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    _catmull(path, pts);
    path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  List<Offset> _points(Size size, List<double> xFrac, List<double> yFrac) {
    assert(xFrac.length == yFrac.length);
    return [
      for (var i = 0; i < xFrac.length; i++)
        Offset(size.width * xFrac[i], size.height * yFrac[i]),
    ];
  }

  /// Softer Catmull-Rom (lower tension) for smoother rise/fall.
  void _catmull(Path path, List<Offset> edge) {
    for (var i = 0; i < edge.length - 1; i++) {
      final p0 = i > 0 ? edge[i - 1] : edge[i];
      final p1 = edge[i];
      final p2 = edge[i + 1];
      final p3 = i + 2 < edge.length ? edge[i + 2] : edge[i + 1];

      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 8,
        p1.dy + (p2.dy - p0.dy) / 8,
      );
      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 8,
        p2.dy - (p3.dy - p1.dy) / 8,
      );
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }
  }

  @override
  bool shouldRepaint(covariant _AuthMovingWavePainter oldDelegate) {
    return waveRearColor != oldDelegate.waveRearColor ||
        sheetColor != oldDelegate.sheetColor;
  }
}
