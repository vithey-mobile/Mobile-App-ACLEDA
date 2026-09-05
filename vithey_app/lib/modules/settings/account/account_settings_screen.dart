import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/modules/settings/account/account_settings_controller.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_scaffold.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class AccountSettingsScreen extends GetView<AccountSettingsController> {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Account',
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Loading account...');
        }
        if (controller.hasError.value) {
          return AppErrorWidget(message: controller.errorMessage.value, onRetry: controller.loadAccount);
        }
        final profile = controller.profile.value;
        if (profile == null) return const AppErrorWidget(message: 'Account unavailable');

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  UserAvatar(name: profile.fullName, imageUrl: profile.avatarUrl, radius: 48),
                  if (controller.isUploadingAvatar.value)
                    const Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                        child: Center(child: CircularProgressIndicator(color: Colors.white)),
                      ),
                    ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: controller.changeAvatar,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: controller.openEditInfo,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit Info'),
              ),
            ),
            const SizedBox(height: 16),
            _InfoCard(icon: Icons.person_outline, label: 'Full Name', value: profile.fullName),
            _InfoCard(icon: Icons.email_outlined, label: 'Email', value: controller.email.value),
            _InfoCard(icon: Icons.phone_outlined, label: 'Phone', value: controller.phone.value),
            _InfoCard(icon: Icons.school_outlined, label: 'Academic Info', value: controller.academicInfo),
          ],
        );
      }),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: context.appColors.subtleShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: context.appColors.muted),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: context.appColors.muted, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
