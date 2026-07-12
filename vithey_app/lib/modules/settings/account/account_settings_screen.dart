import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/modules/settings/account/account_settings_controller.dart';
import 'package:aub_connect_app/modules/settings/account/widgets/account_avatar_editor.dart';
import 'package:aub_connect_app/modules/settings/account/widgets/account_info_card.dart';
import 'package:aub_connect_app/modules/settings/account/widgets/account_skills_section.dart';
import 'package:aub_connect_app/modules/settings/account/widgets/account_stats_row.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_scaffold.dart';

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
            AccountAvatarEditor(
              fullName: profile.fullName,
              avatarUrl: profile.avatarUrl,
              isUploading: controller.isUploadingAvatar.value,
              onChangeAvatar: controller.changeAvatar,
              onEditInfo: controller.openEditInfo,
            ),
            const AccountSectionLabel(label: 'Basic Information'),
            AccountInfoCard(icon: Icons.person_outline, label: 'Full Name', value: profile.fullName),
            AccountInfoCard(icon: Icons.notes_outlined, label: 'Bio', value: profile.bio),
            AccountInfoCard(icon: Icons.email_outlined, label: 'Email', value: profile.email),
            AccountInfoCard(icon: Icons.phone_outlined, label: 'Phone', value: profile.phone),
            AccountInfoCard(
              icon: Icons.cake_outlined,
              label: 'Date of Birth',
              value: controller.formatDateOfBirth(profile.dateOfBirth),
            ),
            AccountInfoCard(icon: Icons.location_on_outlined, label: 'Location', value: profile.location),
            const AccountSectionLabel(label: 'Academic & Career'),
            AccountInfoCard(icon: Icons.school_outlined, label: 'University', value: profile.university),
            AccountInfoCard(icon: Icons.menu_book_outlined, label: 'Major', value: profile.major),
            AccountInfoCard(
              icon: Icons.calendar_today_outlined,
              label: 'Graduation Year',
              value: profile.graduationYear?.toString(),
            ),
            AccountListInfoCard(
              icon: Icons.history_edu_outlined,
              label: 'Education',
              items: profile.education,
            ),
            AccountInfoCard(icon: Icons.work_outline, label: 'Workplace', value: profile.workplace),
            AccountInfoCard(
              icon: Icons.verified_outlined,
              label: 'Student Verified',
              value: profile.isStudentVerified ? 'Verified student' : 'Not verified',
              trailing: profile.isStudentVerified
                  ? const Icon(Icons.verified, color: AppColors.primary, size: 18)
                  : null,
            ),
            const AccountSectionLabel(label: 'Social & Links'),
            AccountInfoCard(
              icon: Icons.send_outlined,
              label: 'Telegram Link',
              value: profile.telegramLink,
              onTap: () => controller.openLink(profile.telegramLink),
            ),
            AccountInfoCard(
              icon: Icons.facebook_outlined,
              label: 'Facebook Link',
              value: profile.facebookLink,
              onTap: () => controller.openLink(profile.facebookLink),
            ),
            AccountInfoCard(
              icon: Icons.language_outlined,
              label: 'Portfolio URL',
              value: profile.portfolioUrl,
              onTap: () => controller.openLink(profile.portfolioUrl),
            ),
            const AccountSectionLabel(label: 'Skills'),
            AccountSkillsSection(skills: profile.skills),
            const AccountSectionLabel(label: 'Stats'),
            AccountStatsRow(
              followerCount: profile.followerCount,
              followingCount: profile.followingCount,
              postCount: profile.postCount,
              likeCount: profile.likeCount,
            ),
          ],
        );
      }),
    );
  }
}
