import 'package:get/get.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/modules/onboarding/intro_morph.dart';
import 'package:aub_connect_app/modules/onboarding/onboarding_controller.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    final fromLanguage = IntroMorph.fromLanguage;
    final fromAuth = IntroMorph.fromAuth;
    final initialPage = IntroMorph.initialOnboardingPage
        .clamp(0, OnboardingController.totalPages - 1);
    IntroMorph.clear();

    if (Get.isRegistered<OnboardingController>()) {
      Get.delete<OnboardingController>(force: true);
    }
    Get.put(
      OnboardingController(
        Get.find<LocalStorageService>(),
        fromLanguage: fromLanguage,
        fromAuth: fromAuth,
        initialPage: initialPage,
      ),
    );
  }
}
