import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/settings/security/security_settings_controller.dart';
import 'package:aub_connect_app/modules/settings/security/widgets/active_sessions_card.dart';
import 'package:aub_connect_app/modules/settings/security/widgets/security_option_card.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_menu_tile.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_scaffold.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_tile_divider.dart';

class SecuritySettingsScreen extends GetView<SecuritySettingsController> {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Security',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Security Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: context.appColors.heading,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage your account security and authentication',
            style: TextStyle(color: context.appColors.muted),
          ),
          const SizedBox(height: 20),
          SecurityOptionCard(
            children: [
              SettingsMenuTile(
                icon: Icons.lock_outline,
                label: 'Change Password',
                subtitle: 'Update your account password',
                onTap: controller.openChangePassword,
              ),
              const SettingsTileDivider(),
              Obx(() => SecuritySwitchTile(
                    icon: Icons.vpn_key_outlined,
                    title: 'Two-Factor Authentication',
                    subtitle: 'Coming soon',
                    value: false,
                    enabled: false,
                    onChanged: (_) {},
                  )),
              const SettingsTileDivider(),
              Obx(() => SecuritySwitchTile(
                    icon: Icons.fingerprint,
                    title: 'Biometric Login',
                    subtitle: 'Coming soon',
                    value: false,
                    enabled: false,
                    onChanged: (_) {},
                  )),
            ],
          ),
          const SizedBox(height: 16),
          const ActiveSessionsCard(),
        ],
      ),
    );
  }
}
