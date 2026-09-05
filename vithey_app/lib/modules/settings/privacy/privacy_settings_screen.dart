import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/modules/settings/privacy/privacy_settings_controller.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_scaffold.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

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
            const Text('Privacy Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              'Control how your data is used and shared',
              style: TextStyle(color: context.appColors.muted),
            ),
            const SizedBox(height: 20),
            _SwitchCard(
              children: [
                _PrivacySwitchTile(
                  icon: Icons.visibility_outlined,
                  title: 'Profile Visibility',
                  subtitle: 'Allow others to view your profile',
                  value: controller.privacy.value.profileVisible,
                  onChanged: controller.toggleProfileVisibility,
                ),
                const Divider(height: 1),
                _PrivacySwitchTile(
                  icon: Icons.share_outlined,
                  title: 'Data Sharing',
                  subtitle: 'Share anonymized usage data to improve Vithey',
                  value: controller.privacy.value.dataSharing,
                  onChanged: controller.toggleDataSharing,
                ),
                const Divider(height: 1),
                _PrivacySwitchTile(
                  icon: Icons.track_changes_outlined,
                  title: 'Activity Tracking',
                  subtitle: 'Track in-app activity for personalized features',
                  value: controller.privacy.value.activityTracking,
                  onChanged: controller.toggleActivityTracking,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.appColors.cardSurface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: context.appColors.subtleShadow, blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Data Protection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your data is encrypted and securely stored. We never share your personal information with third parties without your consent.',
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: controller.openPrivacyPractices,
                    child: const Text(
                      'Learn more about our privacy practices →',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _SwitchCard extends StatelessWidget {
  const _SwitchCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.appColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: context.appColors.subtleShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Column(children: children)),
    );
  }
}

class _PrivacySwitchTile extends StatelessWidget {
  const _PrivacySwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: context.appColors.muted, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: context.appColors.muted)),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged, activeColor: AppColors.primary),
        ],
      ),
    );
  }
}
