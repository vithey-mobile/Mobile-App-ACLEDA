import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/modules/settings/settings_controller.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_logout_button.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_menu_tile.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_scaffold.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_section_label.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_switch_tile.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class SettingsHomeScreen extends GetView<SettingsController> {
  const SettingsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Settings',
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          children: [
            const SettingsSectionLabel(label: 'Preferences'),
            _CardGroup(
              children: [
                SettingsMenuTile(
                  icon: Icons.person_outline,
                  label: 'Account',
                  onTap: () => Get.toNamed(AppRoutes.settingsAccount),
                ),
                const Divider(height: 1),
                SettingsMenuTile(
                  icon: Icons.lock_outline,
                  label: 'Privacy',
                  onTap: () => Get.toNamed(AppRoutes.settingsPrivacy),
                ),
                const Divider(height: 1),
                SettingsMenuTile(
                  icon: Icons.language,
                  label: 'Language',
                  subtitle: controller.languageLabel,
                  onTap: controller.openLanguagePicker,
                ),
              ],
            ),
            const SettingsSectionLabel(label: 'System'),
            _CardGroup(
              children: [
                SettingsMenuTile(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  onTap: () => Get.toNamed(AppRoutes.notifications),
                ),
                const Divider(height: 1),
                SettingsMenuTile(
                  icon: Icons.security,
                  label: 'Security',
                  onTap: () => Get.toNamed(AppRoutes.settingsSecurity),
                ),
                const Divider(height: 1),
                SettingsSwitchTile(
                  icon: Icons.dark_mode_outlined,
                  label: 'Dark Mode',
                  value: controller.isDarkMode.value,
                  onChanged: controller.toggleDarkMode,
                ),
              ],
            ),
            const SettingsSectionLabel(label: 'Support'),
            _CardGroup(
              children: [
                SettingsMenuTile(
                  icon: Icons.help_outline,
                  label: 'Help Center',
                  onTap: () => Get.toNamed(AppRoutes.settingsHelpCenter),
                ),
                const Divider(height: 1),
                SettingsMenuTile(
                  icon: Icons.info_outline,
                  label: 'About',
                  onTap: () => Get.toNamed(AppRoutes.settingsAbout),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.appColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: context.appColors.subtleShadow, blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Column(children: children)),
      ),
    );
  }
}
