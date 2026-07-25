import 'package:get/get.dart';
import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/data/push/fcm_service.dart';
import 'package:aub_connect_app/data/repositories/notification_repository.dart';

class AuthNavigation {
  AuthNavigation._();

  static Future<void> goAfterAuth({bool isNewUser = false}) async {
    final localStorage = Get.find<LocalStorageService>();
    final flags =
        Get.isRegistered<FeatureFlags>() ? Get.find<FeatureFlags>() : null;
    final forceStartup =
        flags != null && (flags.forceDevFunnel || flags.forceShowStartup);
    final startupDone = await localStorage.isStartupCompleted();
    await _bootstrapNotifications();
    if (forceStartup || !startupDone || isNewUser) {
      Get.offAllNamed(AppRoutes.startupSkills);
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  static Future<void> bootstrapNotificationsIfNeeded() => _bootstrapNotifications();

  static Future<void> _bootstrapNotifications() async {
    if (!Get.isRegistered<NotificationRepository>()) return;
    final repository = Get.find<NotificationRepository>();
    await repository.onUserAuthenticated();
    if (Get.isRegistered<FcmService>()) {
      await Get.find<FcmService>().registerToken();
    }
  }
}
