import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/core/widgets/confirm_dialog.dart';

class SecuritySettingsController extends GetxController {
  SecuritySettingsController(this._localStorage);

  final LocalStorageService _localStorage;

  final twoFactorEnabled = false.obs;
  final biometricEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadBiometric();
  }

  Future<void> _loadBiometric() async {
    biometricEnabled.value = await _localStorage.readBiometricEnabled();
  }

  void openChangePassword() => Get.toNamed(AppRoutes.settingsChangePassword);

  void toggleTwoFactor(bool value) {
    // Feature not available yet — switch stays off.
  }

  Future<void> toggleBiometric(bool value) async {
    if (value) return;
    biometricEnabled.value = false;
    await _localStorage.saveBiometricEnabled(false);
  }

  Future<void> signOutAllDevices() async {
    final confirmed = await showConfirmDialog(
      context: Get.context!,
      title: 'Sign Out Everywhere',
      message: 'This will sign you out from all devices except this one. You will need to sign in again on other devices.',
      confirmLabel: 'Sign Out Everywhere',
      variant: ConfirmDialogVariant.destructive,
    );
    if (confirmed != true) return;
    Get.snackbar('Vithey', 'Sign out all devices is not available yet');
  }

  bool get twoFactorAvailable => false;
  bool get biometricAvailable => false;
  bool get signOutAllDevicesAvailable => false;
}
