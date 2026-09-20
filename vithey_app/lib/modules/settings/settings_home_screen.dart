import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/settings/settings_controller.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_logout_button.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_menu_tile.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_scaffold.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_section_label.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_switch_tile.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

class SettingsHomeScreen extends GetView<SettingsController> {
  const SettingsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Settings'.tr,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.only(bottom: 8),
          children: [
            SettingsSectionLabel(label: 'Preferences'.tr),
            _CardGroup(
              children: [
                SettingsMenuTile(
                  icon: LucideIcons.user,
                  label: 'Account'.tr,
                  onTap: () => Get.toNamed(AppRoutes.settingsAccount),
                ),
                SettingsMenuTile(
                  icon: LucideIcons.lock,
                  label: 'Privacy'.tr,
                  onTap: () => Get.toNamed(AppRoutes.settingsPrivacy),
                ),
                SettingsMenuTile(
                  icon: LucideIcons.languages,
                  label: 'Language'.tr,
                  subtitle: controller.languageLabel,
                  onTap: controller.openLanguagePicker,
                ),
              ],
            ),
            SettingsSectionLabel(label: 'System'.tr),
            _CardGroup(
              children: [
                SettingsMenuTile(
                  icon: LucideIcons.bell,
                  label: 'Notifications'.tr,
                  onTap: () => Get.toNamed(AppRoutes.settingsNotifications),
                ),
                SettingsMenuTile(
                  icon: LucideIcons.shield,
                  label: 'Security'.tr,
                  onTap: () => Get.toNamed(AppRoutes.settingsSecurity),
                ),
                SettingsSwitchTile(
                  icon: LucideIcons.moon,
                  label: 'Dark Mode'.tr,
                  value: controller.isDarkMode.value,
                  onChanged: controller.toggleDarkMode,
                ),
              ],
            ),
            SettingsSectionLabel(label: 'Support'.tr),
            _CardGroup(
              children: [
                SettingsMenuTile(
                  icon: LucideIcons.circleHelp,
                  label: 'Help Center'.tr,
                  onTap: () => Get.toNamed(AppRoutes.settingsHelpCenter),
                ),
                SettingsMenuTile(
                  icon: LucideIcons.info,
                  label: 'About'.tr,
                  onTap: () => Get.toNamed(AppRoutes.settingsAbout),
                ),
              ],
            ),
            SettingsSectionLabel(label: 'General'.tr),
            _CardGroup(
              children: [
                SettingsMenuTile(
                  icon: LucideIcons.database,
                  label: 'Data & storage'.tr,
                  onTap: () => Get.snackbar(
                    'Settings'.tr,
                    'Data & storage is coming soon',
                  ),
                ),
                SettingsMenuTile(
                  icon: LucideIcons.accessibility,
                  label: 'Accessibility'.tr,
                  onTap: () => Get.snackbar(
                    'Settings'.tr,
                    'Accessibility is coming soon',
                  ),
                ),
              ],
            ),
            SettingsLogoutButton(onPressed: controller.logout),
          ],
        );
      }),
    );
  }
}

class _CardGroup extends StatelessWidget {
  const _CardGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cardColor = context.appColors.cardSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(children: children),
        ),
      ),
    );
  }
}
