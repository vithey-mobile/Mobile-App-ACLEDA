import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/data/models/startup_profile_draft.dart';

class StartupController extends GetxController {
  StartupController(this._localStorage);

  final LocalStorageService _localStorage;
  final draft = StartupProfileDraft();

  /// Zero-based step (0 skills, 1 interests, 2 discovery).
  final currentStep = 0.obs;
  final isContentAnimating = false.obs;

  static const int maxInterests = 5;

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
    } else if (draft.interestIds.length < maxInterests) {
      draft.interestIds.add(id);
    }
    update();
  }

  void selectDiscovery(String id) {
    draft.discoverySource = id;
    update();
  }

  void next() {
    if (isContentAnimating.value) return;
    if (currentStep.value < 2) {
      currentStep.value++;
    } else {
      finish();
    }
  }

  void back() {
    if (isContentAnimating.value) return;
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  Future<void> finish({bool skipped = false}) async {
    await _localStorage.setStartupCompleted(true);
    Get.offAllNamed(AppRoutes.home);
  }

  Future<void> skipAll() async => finish(skipped: true);
}
