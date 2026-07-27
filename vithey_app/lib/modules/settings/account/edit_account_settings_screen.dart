import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/app_screen_body.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/modules/settings/account/edit_account_settings_controller.dart';
import 'package:aub_connect_app/modules/settings/account/widgets/account_avatar_editor.dart';
import 'package:aub_connect_app/modules/settings/account/widgets/account_info_card.dart';
import 'package:aub_connect_app/modules/settings/account/widgets/edit_account_date_field.dart';
import 'package:aub_connect_app/modules/settings/account/widgets/edit_account_field_card.dart';
import 'package:aub_connect_app/modules/settings/account/widgets/edit_account_save_button.dart';
import 'package:aub_connect_app/modules/settings/account/widgets/edit_account_skills_editor.dart';

class EditAccountSettingsScreen extends GetView<EditAccountSettingsController> {
  const EditAccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1),
        ),
      ),
      body: AppScreenBody(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const LoadingWidget(message: 'Loading account...');
          }
          if (controller.hasError.value) {
            return AppErrorWidget(message: controller.errorMessage.value, onRetry: controller.loadProfile);
          }
          final profile = controller.profile.value;
          if (profile == null) return const AppErrorWidget(message: 'Account unavailable');

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    AccountAvatarEditor(
                      fullName: profile.fullName,
                      avatarUrl: profile.avatarUrl,
                      isUploading: controller.isUploadingAvatar.value,
                      onChangeAvatar: controller.changeAvatar,
                      showEditAction: false,
                    ),
                    const SizedBox(height: 8),
                    const AccountSectionLabel(label: 'Basic Information'),
                    EditAccountFieldCard(
                      icon: Icons.person_outline,
                      label: 'Full Name',
                      controller: controller.fullNameController,
                    ),
                    EditAccountFieldCard(
                      icon: Icons.notes_outlined,
                      label: 'Bio',
                      controller: controller.bioController,
                      maxLines: 3,
                    ),
                    EditAccountFieldCard(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      controller: controller.emailController,
                      readOnly: true,
                    ),
                    EditAccountFieldCard(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    EditAccountDateField(
                      label: 'Date of Birth',
                      value: controller.dateOfBirth.value,
                      onTap: controller.pickDateOfBirth,
                    ),
                    EditAccountFieldCard(
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      controller: controller.locationController,
                    ),
                    const AccountSectionLabel(label: 'Academic & Career'),
                    EditAccountFieldCard(
                      icon: Icons.school_outlined,
                      label: 'University',
                      controller: controller.universityController,
                    ),
                    EditAccountFieldCard(
                      icon: Icons.menu_book_outlined,
                      label: 'Major',
                      controller: controller.majorController,
                    ),
                    EditAccountFieldCard(
                      icon: Icons.calendar_today_outlined,
                      label: 'Graduation Year',
                      controller: controller.graduationYearController,
                      keyboardType: TextInputType.number,
                    ),
                    EditAccountFieldCard(
                      icon: Icons.history_edu_outlined,
                      label: 'Education (one per line)',
                      controller: controller.educationController,
                      maxLines: 4,
                    ),
                    EditAccountFieldCard(
                      icon: Icons.work_outline,
                      label: 'Workplace',
                      controller: controller.workplaceController,
                    ),
                    AccountInfoCard(
                      icon: Icons.verified_outlined,
                      label: 'Student Verified',
                      value: profile.isStudentVerified ? 'Verified student' : 'Not verified',
                      trailing: profile.isStudentVerified
                          ? const Icon(Icons.verified, color: AppColors.primary, size: 18)
                          : null,
                    ),
                    const AccountSectionLabel(label: 'Social & Links'),
                    EditAccountFieldCard(
                      icon: Icons.send_outlined,
                      label: 'Telegram Link',
                      controller: controller.telegramController,
                      keyboardType: TextInputType.url,
                    ),
                    EditAccountFieldCard(
                      icon: Icons.facebook_outlined,
                      label: 'Facebook Link',
                      controller: controller.facebookController,
                      keyboardType: TextInputType.url,
                    ),
                    EditAccountFieldCard(
                      icon: Icons.language_outlined,
                      label: 'Portfolio URL',
                      controller: controller.portfolioController,
                      keyboardType: TextInputType.url,
                    ),
                    const AccountSectionLabel(label: 'Skills'),
                    Obx(
                      () => EditAccountSkillsEditor(
                        skills: controller.skills.toList(),
                        onAdd: controller.addSkill,
                        onRemove: controller.removeSkill,
                        onUpdate: controller.updateSkill,
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: EditAccountSaveButton(
                    isLoading: controller.isSaving.value,
                    onPressed: controller.isSaving.value ? null : controller.save,
                  ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
