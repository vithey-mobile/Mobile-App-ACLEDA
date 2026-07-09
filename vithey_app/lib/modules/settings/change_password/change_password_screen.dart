import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/custom_text_field.dart';
import 'package:aub_connect_app/modules/settings/change_password/change_password_controller.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_scaffold.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class ChangePasswordScreen extends GetView<ChangePasswordController> {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Change Password',
      body: GetBuilder<ChangePasswordController>(
        builder: (_) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline, color: AppColors.primary, size: 32),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text('Update your password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Choose a strong password to keep your account safe',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.appColors.muted),
              ),
            ),
            const SizedBox(height: 24),
            Obx(() => _PasswordField(
                  label: 'Current Password',
                  controller: controller.currentPassword,
                  obscure: !controller.showCurrent.value,
                  onToggle: () => controller.showCurrent.value = !controller.showCurrent.value,
                )),
            const SizedBox(height: 12),
            Obx(() => _PasswordField(
                  label: 'New Password',
                  controller: controller.newPassword,
                  obscure: !controller.showNew.value,
                  onToggle: () => controller.showNew.value = !controller.showNew.value,
                )),
            const SizedBox(height: 12),
            Obx(() => _PasswordField(
                  label: 'Confirm New Password',
                  controller: controller.confirmPassword,
                  obscure: !controller.showConfirm.value,
                  onToggle: () => controller.showConfirm.value = !controller.showConfirm.value,
                )),
            const SizedBox(height: 20),
            _RequirementsCard(controller: controller),
            const SizedBox(height: 24),
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: 'Update Password',
                    isLoading: controller.isLoading.value,
                    onPressed: controller.canSubmit ? controller.updatePassword : null,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label,
      hint: label,
      prefixIcon: Icons.lock_outline,
      obscureText: obscure,
    );
  }
}

class _RequirementsCard extends StatelessWidget {
  const _RequirementsCard({required this.controller});

  final ChangePasswordController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Requirements', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _RequirementRow(met: controller.hasMinLength, text: 'At least 8 characters'),
          _RequirementRow(met: controller.hasUppercase, text: 'One uppercase letter'),
          _RequirementRow(met: controller.hasNumber, text: 'One number'),
          _RequirementRow(met: controller.hasSpecial, text: 'One special character'),
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.met, required this.text});

  final bool met;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: met ? AppColors.primary : context.appColors.muted),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(color: met ? AppColors.primary : context.appColors.muted)),
        ],
      ),
    );
  }
}
