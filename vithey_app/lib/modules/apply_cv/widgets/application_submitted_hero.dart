import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';

class ApplicationSubmittedHero extends StatelessWidget {
  const ApplicationSubmittedHero({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 24,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return Container(
                  width: 3,
                  height: 12.0 + i * 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ),
          Positioned(
            right: MediaQuery.sizeOf(context).width * 0.38,
            top: 20,
            child: Icon(
              Icons.description_outlined,
              size: 72,
              color: AppColors.info.withValues(alpha: 0.15),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.description, size: 88, color: AppColors.info.withValues(alpha: 0.85)),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
