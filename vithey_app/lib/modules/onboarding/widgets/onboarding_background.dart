import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

/// Fixed intro backdrop: white base + light-teal rear wave + teal front wave.
///
/// [tealHeightFactor] and [lightHeightFactor] can differ so teal stays fixed while
/// white-50% (light wave) morphs (e.g. Select Language → Onboarding).
class OnboardingBackground extends StatelessWidget {
  const OnboardingBackground({
    super.key,
    this.waveHeightFactor = 1.0,
    double? tealHeightFactor,
    double? lightHeightFactor,
    this.authMorph = 0.0,
  })  : tealHeightFactor = tealHeightFactor ?? waveHeightFactor,
        lightHeightFactor = lightHeightFactor ?? waveHeightFactor;

  /// Convenience: sets both teal and light when separate factors are omitted.
  final double waveHeightFactor;

  /// Front teal wave depth (1.0 = onboarding default).
  final double tealHeightFactor;

  /// Rear white-50% / light-teal wave depth.
  final double lightHeightFactor;

  /// 0 = normal onboarding waves, 1 = solid auth teal (wave edge to bottom).
  final double authMorph;

  /// Select Language default (taller white body).
  static const languageFactor = 0.68;

  /// Onboarding default.
  static const onboardingFactor = 1.0;

  @override
  Widget build(BuildContext context) {
    final baseColor = context.appColors.cardSurface;
    final waveRearColor = AppColors.waveRearOn(baseColor);
    return SizedBox.expand(
      child: CustomPaint(
        painter: _OnboardingWavePainter(
          baseColor: baseColor,
          waveRearColor: waveRearColor,
          tealHeightFactor: tealHeightFactor,
          lightHeightFactor: lightHeightFactor,
          authMorph: authMorph.clamp(0.0, 1.0),
        ),
      ),
    );
  }
}

class _OnboardingWavePainter extends CustomPainter {
  const _OnboardingWavePainter({
    required this.baseColor,
    required this.waveRearColor,
    required this.tealHeightFactor,
    required this.lightHeightFactor,
    required this.authMorph,
  });

  final Color baseColor;
  final Color waveRearColor;
  final double tealHeightFactor;
  final double lightHeightFactor;
  final double authMorph;

  static const _tealX = [0.0, 0.20, 0.40, 0.50, 0.80, 1.0];
  static const _lightX = [0.0, 0.20, 0.40, 0.60, 0.75, 0.95, 1.0];
  static const _tealY = [0.510, 0.528, 0.485, 0.485, 0.525, 0.460];
  static const _lightY = [0.535, 0.575, 0.570, 0.535, 0.535, 0.580, 0.580];

  @override
  void paint(Canvas canvas, Size size) {
    if (authMorph >= 0.999) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = AppColors.primaryLight,
      );
      return;
    }

    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = baseColor,
    );

    final lightAlpha = (1.0 - authMorph).clamp(0.0, 1.0);
    if (lightAlpha > 0.01) {
      canvas.drawPath(
        _layerPath(size, _lightX, _lightY, lightHeightFactor, authMorph),
        Paint()..color = waveRearColor.withValues(alpha: lightAlpha),
      );
    }
    canvas.drawPath(
      _layerPath(size, _tealX, _tealY, tealHeightFactor, authMorph),
      Paint()..color = AppColors.primaryLight,
    );
  }

  Path _layerPath(
    Size size,
    List<double> xFrac,
    List<double> yFrac,
    double heightFactor,
    double morph,
  ) {
    assert(xFrac.length == yFrac.length);
    final yScale = heightFactor.clamp(0.35, 1.0);

    final pts = <Offset>[
      for (var i = 0; i < xFrac.length; i++)
        Offset(
          size.width * xFrac[i],
          size.height * (yFrac[i] * yScale * (1.0 - morph) + 1.0 * morph),
        ),
    ];

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(pts.last.dx, pts.last.dy);

    final edge = pts.reversed.toList();
    for (var i = 0; i < edge.length - 1; i++) {
      final p0 = i > 0 ? edge[i - 1] : edge[i];
      final p1 = edge[i];
      final p2 = edge[i + 1];
      final p3 = i + 2 < edge.length ? edge[i + 2] : edge[i + 1];

      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
      );
      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
      );
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _OnboardingWavePainter oldDelegate) {
    return baseColor != oldDelegate.baseColor ||
        waveRearColor != oldDelegate.waveRearColor ||
        tealHeightFactor != oldDelegate.tealHeightFactor ||
        lightHeightFactor != oldDelegate.lightHeightFactor ||
        authMorph != oldDelegate.authMorph;
  }
}
