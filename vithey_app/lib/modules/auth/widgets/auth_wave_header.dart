import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/app_logo.dart';

class AuthWaveHeader extends StatelessWidget {
  const AuthWaveHeader({super.key, this.heightFactor = 0.38});

  final double heightFactor;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * heightFactor;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _AuthWavePainter()),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: AppLogo(size: 82, onWhiteCircle: true),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = AppColors.authHeaderTeal,
    );

    final rearWave = Path()
      ..moveTo(0, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.45, size.height * 0.75, size.width, size.height * 0.5)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(rearWave, Paint()..color = AppColors.authWaveRear);

    final frontWave = Path()
      ..moveTo(0, size.height * 0.62)
      ..quadraticBezierTo(size.width * 0.55, size.height * 0.9, size.width, size.height * 0.68)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(frontWave, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
