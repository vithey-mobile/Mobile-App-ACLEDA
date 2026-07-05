import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/widgets/app_logo.dart';

class SplashBrandTitle extends StatelessWidget {
  const SplashBrandTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      AppStrings.appName.split(' ').first,
      style: const TextStyle(
        color: AppColors.splashTextWhite,
        fontSize: 30,
        fontWeight: FontWeight.w600,
      ),
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
