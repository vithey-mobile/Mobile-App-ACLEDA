import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_assets.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

/// Official Vithey app logo (`assets/images/brand/app_logo.png`).
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 120,
    this.onWhiteCircle = false,
  });

  final double size;
  final bool onWhiteCircle;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      AppAssets.logoApp,
      width: onWhiteCircle ? size * 0.64 : size,
      height: onWhiteCircle ? size * 0.64 : size,
      fit: BoxFit.contain,
    );

    if (!onWhiteCircle) return image;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.scheme.surface,
        boxShadow: [
          BoxShadow(color: context.appColors.subtleShadow, blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      alignment: Alignment.center,
      child: image,
    );
  }
}
