import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/onboarding/onboarding_controller.dart';
import 'package:aub_connect_app/modules/onboarding/widgets/onboarding_background.dart';
import 'package:aub_connect_app/modules/onboarding/widgets/onboarding_bottom_section.dart';
import 'package:aub_connect_app/modules/onboarding/widgets/onboarding_top_section.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.cardSurface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fixed layered background (does not move with PageView).
          const OnboardingBackground(),

          // Changing content: illustration + title + subtitle.
          PageView.builder(
            controller: controller.pageController,
            itemCount: OnboardingController.totalPages,
            onPageChanged: controller.onPageChanged,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (_, index) {
              final slide = controller.slides[index];
              return Column(
                children: [
                  Expanded(
                    flex: 55,
                    child: OnboardingTopSection(imageAsset: slide.imageAsset),
                  ),
                  Expanded(
                    flex: 45,
                    child: Padding(
                      // Leave room for fixed dots + CTA overlay.
                      padding: const EdgeInsets.only(bottom: 112),
                      child: OnboardingBottomSection(
                        title: slide.title,
                        description: slide.description,
                        currentPage: index,
                        totalPages: OnboardingController.totalPages,
                        onNext: controller.next,
                        showChrome: false,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Fixed Skip (white) on teal header.
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: TextButton(
                onPressed: controller.skip,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  minimumSize: const Size(44, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // Fixed dots + Next / Get Started, centered in bottom section.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Obx(
              () => OnboardingBottomChrome(
                currentPage: controller.currentPage.value,
                totalPages: OnboardingController.totalPages,
                onNext: controller.next,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
