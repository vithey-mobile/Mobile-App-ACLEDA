import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/settings/privacy/privacy_settings_controller.dart';
import 'package:aub_connect_app/modules/settings/privacy/widgets/data_protection_card.dart';
import 'package:aub_connect_app/modules/settings/privacy/widgets/privacy_switch_card.dart';
import 'package:aub_connect_app/modules/settings/privacy/widgets/privacy_switch_tile.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_scaffold.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_tile_divider.dart';

class PrivacySettingsScreen extends GetView<PrivacySettingsController> {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Privacy',
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Privacy Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.appColors.heading,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Control how your data is used and shared',
              style: TextStyle(color: context.appColors.muted),
            ),
            const SizedBox(height: 20),
            PrivacySwitchCard(
              children: [
                PrivacySwitchTile(
                  icon: Icons.visibility_outlined,
                  title: 'Profile Visibility',
                  subtitle: 'Allow others to view your profile',
                  value: controller.privacy.value.profileVisible,
                  onChanged: controller.toggleProfileVisibility,
                ),
                const SettingsTileDivider(),
                PrivacySwitchTile(
                  icon: Icons.share_outlined,
                  title: 'Data Sharing',
                  subtitle: 'Share anonymized usage data to improve Vithey',
                  value: controller.privacy.value.dataSharing,
                  onChanged: controller.toggleDataSharing,
                ),
                const SettingsTileDivider(),
                PrivacySwitchTile(
                  icon: Icons.track_changes_outlined,
                  title: 'Activity Tracking',
                  subtitle: 'Track in-app activity for personalized features',
                  value: controller.privacy.value.activityTracking,
                  onChanged: controller.toggleActivityTracking,
                ),
              ],
            ),
            const SizedBox(height: 16),
            DataProtectionCard(onLearnMore: controller.openPrivacyPractices),
          ],
        );
      }),
    );
  }
}
