import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';

class OnboardingSlide {
  const OnboardingSlide({
    required this.title,
    required this.description,
    this.imageAsset,
  });

  final String title;
  final String description;
  final String? imageAsset;
}

class OnboardingController extends GetxController {
  OnboardingController(this._localStorage);

  final LocalStorageService _localStorage;
  final pageController = PageController();
  final currentPage = 0.obs;

  static const totalPages = 3;

  final slides = const [
    OnboardingSlide(
      title: 'Connect with Your Campus Community',
      description:
          'Discover posts, connect with friends, and stay updated.',
      imageAsset: 'assets/images/onboarding/onboarding_1.png',
    ),
    OnboardingSlide(
      title: 'Jobs & Career Growth',
      description:
          'Discover job posts, apply with your CV, and connect with opportunities on campus.',
      imageAsset: 'assets/images/onboarding/onboarding_2.png',
    ),
    OnboardingSlide(
      title: 'Finance, Chat & AI Support',
      description:
          'Track tuition payments, chat privately, and get AI help for study and career.',
      imageAsset: 'assets/images/onboarding/onboarding_3.png',
    ),
  ];

  void onPageChanged(int index) => currentPage.value = index;

  void next() {
    if (currentPage.value < totalPages - 1) {
      pageController.nextPage(
          duration: 300.milliseconds, curve: Curves.easeInOut);
    } else {
      finish();
    }
  }

  void skip() => finish();

  Future<void> finish() async {
    await _localStorage.setOnboardingCompleted(true);
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
