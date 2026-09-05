import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/modules/profile/utils/profile_format.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key, required this.profile});

  final UserProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              label: 'Likes',
              value: formatProfileCount(profile.likeCount),
            ),
          ),
          Expanded(
            child: _StatItem(
              label: 'Followers',
              value: formatProfileCount(profile.followerCount),
            ),
          ),
          Expanded(
            child: _StatItem(
              label: 'Following',
              value: formatProfileCount(profile.followingCount),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final heading = context.appColors.heading;
    final muted = context.appColors.muted;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: heading,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: muted,
            fontSize: 13,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class ProfileActionRow extends StatelessWidget {
  const ProfileActionRow({
    super.key,
    required this.isOwnProfile,
    required this.isFollowing,
    required this.isStudentVerified,
    required this.onFollow,
    required this.onMessage,
    required this.onEditProfile,
    required this.onVerifyStudent,
    required this.onShare,
  });

  final bool isOwnProfile;
  final bool isFollowing;
  final bool isStudentVerified;
  final VoidCallback onFollow;
  final VoidCallback onMessage;
  final VoidCallback onEditProfile;
  final VoidCallback onVerifyStudent;
  final VoidCallback onShare;

  static const _buttonGap = 16.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        if (isOwnProfile) ...[
          CustomButton(
            label: 'Edit Profile',
            onPressed: onEditProfile,
          ),
          const SizedBox(width: _buttonGap),
          CustomButton(
            label: isStudentVerified ? 'Review' : 'Verify',
            variant: CustomButtonVariant.outline,
            onPressed: onVerifyStudent,
          ),
        ] else ...[
          if (isFollowing)
            CustomButton(
              label: 'Unfollow',
              variant: CustomButtonVariant.outline,
              onPressed: onFollow,
            )
          else
            CustomButton(
              label: 'Follow',
              onPressed: onFollow,
            ),
          const SizedBox(width: _buttonGap),
          CustomButton(
            label: 'Message',
            variant: CustomButtonVariant.outline,
            onPressed: onMessage,
          ),
        ],
        const SizedBox(width: _buttonGap),
        IconButton(
          onPressed: onShare,
          color: AppColors.primary,
          icon: const Icon(Icons.ios_share, size: 18),
        ),
      ],
      ),
    );
  }
}

void shareProfileLink(String userId, String name) {
  Share.share('Check out $name on Vithey App');
}

void openVerifyStudent() => Get.toNamed(AppRoutes.studentVerification);
