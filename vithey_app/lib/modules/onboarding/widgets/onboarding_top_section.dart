import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';

class OnboardingWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height * 0.82)
      ..quadraticBezierTo(size.width * 0.5, size.height, size.width, size.height * 0.78)
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class OnboardingTopSection extends StatelessWidget {
  const OnboardingTopSection({
    super.key,
    required this.imageAsset,
    required this.onSkip,
  });

  final String? imageAsset;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: OnboardingWaveClipper(),
      child: Container(
        color: AppColors.onboardingTeal,
        child: Stack(
          children: [
            Positioned(
              top: 8,
              right: 8,
              child: TextButton(
                onPressed: onSkip,
                child: const Text('Skip', style: TextStyle(color: Colors.white)),
              ),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                decoration: BoxDecoration(
                  color: AppColors.onboardingPlaceholder,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: imageAsset != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          imageAsset!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.expand(),
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
