import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Wave-edged clip: keeps the top [fraction] of the child, soft wave bottom edge.
/// Used so Splash peels upward into Select Language’s white body.
class SplashHandoffClipper extends CustomClipper<Path> {
  SplashHandoffClipper({required this.fraction});

  final double fraction;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final f = fraction.clamp(0.0, 1.0);

    // Full cover — no wave (avoids a white strip at the bottom).
    if (f >= 0.999) {
      return Path()..addRect(Offset.zero & size);
    }
    if (f <= 0.001) return Path();

    final baseY = h * f;
    final amp = h * 0.04;

    Offset point(double t) {
      // t: 0 at right → 1 at left.
      final x = w * (1.0 - t);
      final wave = math.sin(t * math.pi) * amp +
          math.sin(t * math.pi * 0.5 + 0.4) * amp * 0.35;
      final y = math.min(h, baseY + math.max(0.0, wave + amp * 0.3));
      return Offset(x, y);
    }

    final pts = <Offset>[for (var i = 0; i <= 6; i++) point(i / 6)];

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(pts.first.dx, pts.first.dy);

    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = i > 0 ? pts[i - 1] : pts[i];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = i + 2 < pts.length ? pts[i + 2] : pts[i + 1];
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
  bool shouldReclip(covariant SplashHandoffClipper oldClipper) {
    return oldClipper.fraction != fraction;
  }
}
