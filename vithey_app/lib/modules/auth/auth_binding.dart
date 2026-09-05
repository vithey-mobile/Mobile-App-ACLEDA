import 'package:get/get.dart';
import 'package:aub_connect_app/data/repositories/auth_repository.dart';
import 'package:aub_connect_app/modules/auth/auth_controller.dart';
import 'package:aub_connect_app/modules/auth/onboarding/intro_morph.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    final fadeIn = IntroMorph.fadeContentIn;
    IntroMorph.clear();

    if (fadeIn) {
      if (Get.isRegistered<AuthController>()) {
        Get.delete<AuthController>(force: true);
      }
      Get.put(
        AuthController(
          Get.find<AuthRepository>(),
          fadeContentIn: true,
        ),
      );
      return;
    }

    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut<AuthController>(
        () => AuthController(Get.find<AuthRepository>()),
        fenix: true,
      );
    }
  }
}
