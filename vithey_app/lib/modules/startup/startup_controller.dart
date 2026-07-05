import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/data/models/startup_profile_draft.dart';

class StartupController extends GetxController {
  StartupController(this._localStorage);

  final LocalStorageService _localStorage;
  final draft = StartupProfileDraft();
  final currentStep = 1.obs;

  void toggleSkill(String id) {
    if (draft.skillIds.contains(id)) {
      draft.skillIds.remove(id);
    } else {
      draft.skillIds.add(id);
    }
    update();
  }

  void toggleInterest(String id) {
    if (draft.interestIds.contains(id)) {
      draft.interestIds.remove(id);
    } else if (draft.interestIds.length < 5) {
      draft.interestIds.add(id);
    }
    update();
  }

  void selectDiscovery(String id) {
    draft.discoverySource = id;
    update();
  }

  void goToStep(int step) => currentStep.value = step;

  void nextFromSkills() {
    currentStep.value = 2;
    Get.toNamed(AppRoutes.startupInterests);
  }

  void nextFromInterests() {
    currentStep.value = 3;
    Get.toNamed(AppRoutes.startupDiscovery);
  }

  void backFromInterests() => Get.back();

  void backFromDiscovery() => Get.back();

  Future<void> finish({bool skipped = false}) async {
    await _localStorage.setStartupCompleted(true);
    Get.offAllNamed(AppRoutes.home);
  }

  Future<void> skipAll() async => finish(skipped: true);
}

class StartupHeader extends StatelessWidget {
  const StartupHeader({super.key, required this.onSkip});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.authBorder)),
      ),
      child: Row(
        children: [
          Text(AppStrings.vitheyStartup, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          TextButton(onPressed: onSkip, child: const Text(AppStrings.skip, style: TextStyle(color: AppColors.primary))),
        ],
      ),
    );
  }
}

class StartupStepIndicator extends StatelessWidget {
  const StartupStepIndicator({super.key, required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final active = index + 1 == currentStep;
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.primary : AppColors.onboardingDotInactive,
          ),
        );
      }),
    );
  }
}

class StartupBottomNav extends StatelessWidget {
  const StartupBottomNav({
    super.key,
    required this.onBack,
    required this.onNext,
    this.nextLabel = AppStrings.next,
    this.showBack = true,
  });

  final VoidCallback? onBack;
  final VoidCallback onNext;
  final String nextLabel;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          if (showBack)
            TextButton(onPressed: onBack, child: const Text(AppStrings.back))
          else
            const SizedBox(width: 72),
          const Spacer(),
          ElevatedButton(onPressed: onNext, child: Text(nextLabel)),
        ],
      ),
    );
  }
}
