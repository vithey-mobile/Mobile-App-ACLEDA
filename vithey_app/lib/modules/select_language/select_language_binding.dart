import 'package:get/get.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/modules/onboarding/intro_morph.dart';
import 'package:aub_connect_app/modules/select_language/select_language_controller.dart';

class SelectLanguageBinding extends Bindings {
  @override
  void dependencies() {
    final fromOnboarding = IntroMorph.fromOnboarding;
    IntroMorph.clear();

    if (Get.isRegistered<SelectLanguageController>()) {
      Get.delete<SelectLanguageController>(force: true);
    }
    Get.put(
      SelectLanguageController(
        Get.find<LocalStorageService>(),
        fromOnboarding: fromOnboarding,
      ),
    );
  }
}
