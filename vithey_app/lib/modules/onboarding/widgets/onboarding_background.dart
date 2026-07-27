import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

/// Fixed onboarding backdrop: white base + light-teal rear wave + teal front wave.
/// Must stay outside the [PageView] so it does not move on swipe / Next.
///
/// CANONICAL Vithey entry-screen wave style — reuse (or extract shared) for Auth:
/// colors `AppColors.authHeaderTeal` + `AppColors.authWaveRear`, staggered keyframes,
/// max ~10% height gap. See also `Prompt Frontend/COMMON_CONTEXT.md`
/// and `02-onboarding-prompt-version-2.md`.
///
/// Wave keyframes (% of width) — gap between teal bottom and light-teal bottom
/// is at most ~10% of screen height:
/// - 0%: small gap
/// - 20%: mid gap, both dip lower (then rise toward 40%)
/// - 40%: expanded gap
/// - close bend: light teal holds 60%→75%, teal at 80% (teal dipped a bit lower)
/// - light teal: lowest at 95%, then flat through 100% (no rise)
/// - 100%: teal risen up; light teal stable from 95%
class OnboardingBackground extends StatelessWidget {
  const OnboardingBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = context.appColors.cardSurface;
    final waveRearColor = AppColors.waveRearOn(baseColor);
    return SizedBox.expand(
      child: CustomPaint(
        painter: _OnboardingWavePainter(
          baseColor: baseColor,
          waveRearColor: waveRearColor,
        ),
      ),
    );
  }
}

class _OnboardingWavePainter extends CustomPainter {
  const _OnboardingWavePainter({
    required this.baseColor,
    required this.waveRearColor,
  });

  final Color baseColor;
  final Color waveRearColor;

  /// Teal width keyframes — hold the 40% peak until 50%, then fall toward 80%.
  static const _tealX = [0.0, 0.20, 0.40, 0.50, 0.80, 1.0];

  /// Light-teal width — hold close bend 60%→75%, fall from 75%, flat 95%→100%.
  static const _lightX = [0.0, 0.20, 0.40, 0.60, 0.75, 0.95, 1.0];

  /// Teal bottom-edge Y — 40%→50% stays up; falls from 50% toward 80%; 100% risen.
  static const _tealY = [0.510, 0.528, 0.485, 0.485, 0.525, 0.460];

  /// Light-teal bottom-edge Y — 60%→75% stays close/up; falls from 75%; 95%→100% flat.
  static const _lightY = [0.535, 0.575, 0.570, 0.535, 0.535, 0.580, 0.580];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = baseColor,
    );

    canvas.drawPath(
      _layerPath(size, _lightX, _lightY),
      Paint()..color = waveRearColor,
    );
    canvas.drawPath(
      _layerPath(size, _tealX, _tealY),
      Paint()..color = AppColors.authHeaderTeal,
    );
  }

  /// Filled band from the top of the screen down to a smooth wave edge.
  Path _layerPath(Size size, List<double> xFrac, List<double> yFrac) {
    assert(xFrac.length == yFrac.length);

    final pts = <Offset>[
      for (var i = 0; i < xFrac.length; i++)
        Offset(size.width * xFrac[i], size.height * yFrac[i]),
    ];

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(pts.last.dx, pts.last.dy);

    // Smooth edge from right → left through the keyframes.
    final edge = pts.reversed.toList();
    for (var i = 0; i < edge.length - 1; i++) {
      final p0 = i > 0 ? edge[i - 1] : edge[i];
      final p1 = edge[i];
      final p2 = edge[i + 1];
      final p3 = i + 2 < edge.length ? edge[i + 2] : edge[i + 1];

      // Catmull-Rom → cubic for a continuous wavy edge.
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
        waveRearColor != oldDelegate.waveRearColor;
  }
}
