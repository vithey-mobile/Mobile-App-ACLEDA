import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';

class AuthNavigation {
  AuthNavigation._();

  static Future<void> goAfterAuth({bool isNewUser = false}) async {
    final localStorage = Get.find<LocalStorageService>();
    final startupDone = await localStorage.isStartupCompleted();
    if (!startupDone || isNewUser) {
      Get.offAllNamed(AppRoutes.startupSkills);
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }
}
