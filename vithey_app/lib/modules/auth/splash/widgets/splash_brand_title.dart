import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/widgets/app_logo.dart';

class SplashBrandTitle extends StatelessWidget {
  const SplashBrandTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 1.6,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentLight),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              AppStrings.loading,
              style: TextStyle(
                color: AppColors.accentLight.withValues(alpha: 0.9),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.appName.split(' ').first,
          style: const TextStyle(
            color: AppColors.accentLight,
            fontSize: 30,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class SplashLogo extends StatelessWidget {
  const SplashLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final circleSize = MediaQuery.sizeOf(context).width * 0.35;
    return AppLogo(size: circleSize, onWhiteCircle: true);
  }
}
