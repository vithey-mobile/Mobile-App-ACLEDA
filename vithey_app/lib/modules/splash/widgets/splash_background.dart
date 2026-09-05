import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';

class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SplashWavePainter(),
      size: Size.infinite,
    );
  }
}

class _SplashWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = AppColors.splashBaseTeal,
    );

    final darkWave = Path()
      ..moveTo(0, size.height * 0.15)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.05, size.width * 0.7, size.height * 0.2)
      ..quadraticBezierTo(size.width, size.height * 0.35, size.width, size.height * 0.45)
      ..lineTo(0, size.height * 0.55)
      ..close();
    canvas.drawPath(darkWave, Paint()..color = AppColors.splashWaveDark.withOpacity(0.55));

    final lightWave = Path()
      ..moveTo(0, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.75, size.width, size.height * 0.6)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(lightWave, Paint()..color = AppColors.splashWaveLight.withOpacity(0.7));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
