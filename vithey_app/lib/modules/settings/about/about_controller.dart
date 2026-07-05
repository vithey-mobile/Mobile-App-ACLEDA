import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutController extends GetxController {
  final version = ''.obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadPackageInfo();
  }

  Future<void> loadPackageInfo() async {
    isLoading.value = true;
    try {
      final info = await PackageInfo.fromPlatform();
      version.value = 'Version ${info.version} (${info.buildNumber})';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Vithey', 'Could not open link');
    }
  }

  void openPrivacyPolicy() => openUrl('https://vithey.app/privacy');
  void openTerms() => openUrl('https://vithey.app/terms');
  void openCompetitionRules() => openUrl('https://www.acledabank.com.kh');
  void contactSupport() => openUrl('mailto:support@vithey.app');

  void showLicenses() {
    showLicensePage(
      context: Get.context!,
      applicationName: 'Vithey',
      applicationVersion: version.value,
    );
  }
}
