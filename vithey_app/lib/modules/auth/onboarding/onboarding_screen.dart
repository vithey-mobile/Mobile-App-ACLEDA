import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/modules/auth/onboarding/onboarding_controller.dart';
import 'package:aub_connect_app/modules/auth/onboarding/widgets/onboarding_background.dart';
import 'package:aub_connect_app/modules/auth/onboarding/widgets/onboarding_bottom_section.dart';
import 'package:aub_connect_app/modules/auth/onboarding/widgets/onboarding_top_section.dart';
import 'package:aub_connect_app/modules/auth/onboarding/widgets/wave_ribbon.dart';

/// Onboarding — each page is a full ribbon frame (wave + content) that slides L/R.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<OnboardingController>()) {
      return Scaffold(
        backgroundColor: context.appColors.cardSurface,
        body: const OnboardingBackground(profile: WaveRibbon.onboarding1),
      );
    }
    final controller = Get.find<OnboardingController>();

    return Scaffold(
      backgroundColor: context.appColors.cardSurface,
      body: Obx(() {
        if (!Get.isRegistered<OnboardingController>()) {
          return const OnboardingBackground(profile: WaveRibbon.onboarding1);
        }
        final opacity = controller.contentOpacity.value;
        final busy = controller.isBusy.value;

        return Opacity(
          opacity: opacity,
          child: IgnorePointer(
            ignoring: busy,
            child: PageView.builder(
              controller: controller.pageController,
              itemCount: OnboardingController.totalPages,
              onPageChanged: controller.onPageChanged,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, index) {
                final slide = controller.slides[index];
                final profile = WaveRibbon.onboardingPage(index);
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    OnboardingBackground(profile: profile),
                    Column(
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
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: Row(
                          children: [
                            CustomButton(
                              label: AppStrings.back,
                              variant: CustomButtonVariant.ghost,
                              foregroundColor: AppColors.accentLight,
                              onPressed: busy ? null : controller.back,
                            ),
                            const Spacer(),
                            CustomButton(
                              label: 'Skip',
                              variant: CustomButtonVariant.ghost,
                              foregroundColor: AppColors.accentLight,
                              onPressed: busy ? null : controller.skip,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: OnboardingBottomChrome(
                        currentPage: index + 1,
                        totalPages: OnboardingController.introDotCount,
                        onNext: controller.next,
                        isLastSlide:
                            index == OnboardingController.totalPages - 1,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
