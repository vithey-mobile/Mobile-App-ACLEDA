import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/modules/onboarding/onboarding_controller.dart';
import 'package:aub_connect_app/modules/onboarding/widgets/onboarding_bottom_section.dart';
import 'package:aub_connect_app/modules/onboarding/widgets/onboarding_top_section.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 55,
            child: PageView.builder(
              controller: controller.pageController,
              itemCount: OnboardingController.totalPages,
              onPageChanged: controller.onPageChanged,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (_, index) {
                final slide = controller.slides[index];
                return OnboardingTopSection(
                  imageAsset: slide.imageAsset,
                  onSkip: controller.skip,
                );
              },
            ),
          ),
          Expanded(
            flex: 45,
            child: Obx(() {
              final page = controller.currentPage.value;
              final slide = controller.slides[page];
              return OnboardingBottomSection(
                title: slide.title,
                description: slide.description,
                currentPage: page,
                totalPages: OnboardingController.totalPages,
                onNext: controller.next,
              );
            }),
          ),
        ],
      ),
    );
  }
}
