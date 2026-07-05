import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/modules/settings/security/security_settings_controller.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_menu_tile.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_scaffold.dart';

class SecuritySettingsScreen extends GetView<SecuritySettingsController> {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Security',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Security Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Manage your account security and authentication', style: TextStyle(color: AppColors.authMuted)),
          const SizedBox(height: 20),
          _Card(
            child: Column(
              children: [
                SettingsMenuTile(
                  icon: Icons.lock_outline,
                  label: 'Change Password',
                  onTap: controller.openChangePassword,
                ),
                const Divider(height: 1),
                Obx(() => _SecuritySwitchTile(
                      icon: Icons.vpn_key_outlined,
                      label: 'Two-Factor Authentication',
                      value: controller.twoFactorEnabled.value,
                      onChanged: controller.toggleTwoFactor,
                    )),
                const Divider(height: 1),
                Obx(() => _SecuritySwitchTile(
                      icon: Icons.fingerprint,
                      label: 'Biometric Login',
                      value: controller.biometricEnabled.value,
                      onChanged: controller.toggleBiometric,
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Active Sessions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Current Device', style: TextStyle(fontWeight: FontWeight.w600)),
                            SizedBox(height: 4),
                            Text('Last active: Just now', style: TextStyle(fontSize: 12, color: AppColors.authMuted)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Active', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.error, size: 20),
                        SizedBox(width: 8),
                        Text('Sign Out All Devices', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Manage your active sessions', style: TextStyle(color: AppColors.authMuted, fontSize: 13)),
                  const SizedBox(height: 8),
                  const Text('This will sign you out from all devices except this one.'),
                  const Text("You'll need to sign in again on other devices."),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: controller.signOutAllDevices,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Sign Out Everywhere'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(12), child: child),
    );
  }
}

class _SecuritySwitchTile extends StatelessWidget {
  const _SecuritySwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.authMuted, size: 22),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
          Switch.adaptive(value: value, onChanged: onChanged, activeColor: AppColors.primary),
        ],
      ),
    );
  }
}
