import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
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

  static const _buttonPadding =
      EdgeInsets.symmetric(horizontal: 20, vertical: 10);
  static const _shareButtonPadding =
      EdgeInsets.symmetric(horizontal: 20, vertical: 10);
  static const _buttonGap = 16.0;
  static const _radius = 8.0;
  static const _labelStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 13,
    height: 1.1,
  );

  ButtonStyle _filledStyle(Color background, Color foreground) {
    return FilledButton.styleFrom(
      backgroundColor: background,
      foregroundColor: foreground,
      elevation: 0,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minimumSize: Size.zero,
      padding: _buttonPadding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
      ),
    );
  }

  ButtonStyle _outlinedStyle({
    required Color foreground,
    required Color border,
    Color? background,
  }) {
    return OutlinedButton.styleFrom(
      foregroundColor: foreground,
      backgroundColor: background,
      side: BorderSide(color: border),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minimumSize: Size.zero,
      padding: _buttonPadding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
      ),
    );
  }

  ButtonStyle _shareStyle(Color primary) {
    return OutlinedButton.styleFrom(
      foregroundColor: primary,
      side: BorderSide(color: primary),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minimumSize: Size.zero,
      padding: _shareButtonPadding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final heading = context.appColors.heading;
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final border = context.appColors.border;
    final sheet = Theme.of(context).scaffoldBackgroundColor;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        if (isOwnProfile) ...[
          FilledButton(
            onPressed: onEditProfile,
            style: _filledStyle(primary, onPrimary),
            child: const Text('Edit Profile', style: _labelStyle),
          ),
          const SizedBox(width: _buttonGap),
          OutlinedButton(
            onPressed: onVerifyStudent,
            style: _outlinedStyle(
              foreground: heading,
              border: border,
              background: sheet,
            ),
            child: Text(
              isStudentVerified ? 'Review' : 'Verify',
              style: _labelStyle,
            ),
          ),
        ] else ...[
          if (isFollowing)
            OutlinedButton(
              onPressed: onFollow,
              style: _outlinedStyle(foreground: primary, border: primary),
              child: const Text('Unfollow', style: _labelStyle),
            )
          else
            FilledButton(
              onPressed: onFollow,
              style: _filledStyle(primary, onPrimary),
              child: const Text('Follow', style: _labelStyle),
            ),
          const SizedBox(width: _buttonGap),
          OutlinedButton(
            onPressed: onMessage,
            style: _outlinedStyle(foreground: primary, border: primary),
            child: const Text('Message', style: _labelStyle),
          ),
        ],
        const SizedBox(width: _buttonGap),
        OutlinedButton(
          onPressed: onShare,
          style: _shareStyle(primary),
          child: const Icon(Icons.ios_share, size: 18),
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
