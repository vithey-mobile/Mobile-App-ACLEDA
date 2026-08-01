import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/onboarding/onboarding_controller.dart';
import 'package:aub_connect_app/modules/onboarding/widgets/onboarding_background.dart';
import 'package:aub_connect_app/modules/onboarding/widgets/onboarding_bottom_section.dart';
import 'package:aub_connect_app/modules/onboarding/widgets/onboarding_top_section.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<OnboardingController>()) {
      return Scaffold(
        backgroundColor: context.appColors.cardSurface,
        body: const OnboardingBackground(
          waveHeightFactor: OnboardingBackground.onboardingFactor,
          authMorph: 1,
        ),
      );
    }
    final controller = Get.find<OnboardingController>();

    return Scaffold(
      backgroundColor: context.appColors.cardSurface,
      body: Obx(() {
        if (!Get.isRegistered<OnboardingController>()) {
          return const OnboardingBackground(
            waveHeightFactor: OnboardingBackground.onboardingFactor,
            authMorph: 1,
          );
        }
        final wave = controller.waveFactor.value;
        final authMorph = controller.authMorph.value;
        final opacity = controller.contentOpacity.value;
        final busy = controller.isBusy.value;

        return Stack(
          fit: StackFit.expand,
          children: [
            OnboardingBackground(
              waveHeightFactor: wave,
              authMorph: authMorph,
            ),
            Opacity(
              opacity: opacity,
              child: IgnorePointer(
                ignoring: busy,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
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
                              child: OnboardingTopSection(
                                imageAsset: slide.imageAsset,
                              ),
                            ),
                            Expanded(
                              flex: 45,
                              child: Padding(
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
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: busy ? null : controller.back,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                minimumSize: const Size(44, 44),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text(
                                AppStrings.back,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: busy ? null : controller.skip,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                minimumSize: const Size(44, 44),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
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
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Obx(() {
                        if (!Get.isRegistered<OnboardingController>()) {
                          return const SizedBox.shrink();
                        }
                        return OnboardingBottomChrome(
                          currentPage: controller.currentPage.value + 1,
                          totalPages: OnboardingController.introDotCount,
                          onNext: controller.next,
                          isLastSlide: controller.currentPage.value ==
                              OnboardingController.totalPages - 1,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
