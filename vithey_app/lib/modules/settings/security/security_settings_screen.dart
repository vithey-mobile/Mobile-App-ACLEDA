import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/settings/security/security_settings_controller.dart';
import 'package:aub_connect_app/modules/settings/security/widgets/security_option_card.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_menu_tile.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_scaffold.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_section_label.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_tile_divider.dart';

class SecuritySettingsScreen extends GetView<SecuritySettingsController> {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Security',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 8),
        children: [
          const SettingsSectionLabel(label: 'Authentication'),
          _CardGroup(
            children: [
              SettingsMenuTile(
                icon: Icons.lock_outline,
                label: 'Change Password',
                subtitle: 'Update your account password',
                onTap: controller.openChangePassword,
              ),
              const SettingsTileDivider(),
              Obx(
                () => SecuritySwitchTile(
                  icon: Icons.vpn_key_outlined,
                  title: 'Two-Factor Authentication',
                  subtitle: 'Coming soon',
                  value: controller.twoFactorEnabled.value,
                  enabled: controller.twoFactorAvailable,
                  onChanged: controller.toggleTwoFactor,
                ),
              ),
              const SettingsTileDivider(),
              Obx(
                () => SecuritySwitchTile(
                  icon: Icons.fingerprint,
                  title: 'Biometric Login',
                  subtitle: 'Coming soon',
                  value: controller.biometricEnabled.value,
                  enabled: controller.biometricAvailable,
                  onChanged: controller.toggleBiometric,
                ),
              ),
            ],
          ),
          const SettingsSectionLabel(label: 'Sessions'),
          _CardGroup(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(
                      Icons.smartphone_outlined,
                      color: context.scheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Device',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: context.appColors.heading,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Last active: Just now',
                            style: TextStyle(
                              fontSize: 13,
                              color: context.appColors.muted,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: context.scheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Active',
                        style: TextStyle(
                          color: context.scheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardGroup extends StatelessWidget {
  const _CardGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? colors.cardSurface : Colors.white;

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
