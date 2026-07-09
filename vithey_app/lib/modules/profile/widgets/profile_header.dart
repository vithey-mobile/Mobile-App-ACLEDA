import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/modules/profile/utils/profile_format.dart';
import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:share_plus/share_plus.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key, required this.profile});

  final UserProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(label: 'Likes', value: formatProfileCount(profile.likeCount)),
          _StatItem(label: 'Followers', value: formatProfileCount(profile.followerCount)),
          _StatItem(label: 'Following', value: formatProfileCount(profile.followingCount)),
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
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
            fontSize: 12,
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          if (isOwnProfile) ...[
            Expanded(
              flex: 3,
              child: shad.Button.primary(
                onPressed: onEditProfile,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_outlined, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    shad.Text('Edit profile info'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: shad.Button.outline(
                onPressed: isStudentVerified ? null : onVerifyStudent,
                child: shad.Text(isStudentVerified ? 'Verified' : 'Verify student'),
              ),
            ),
          ] else ...[
            Expanded(
              child: isFollowing
                  ? shad.Button.outline(onPressed: onFollow, child: const shad.Text('Following'))
                  : shad.Button.primary(onPressed: onFollow, child: const shad.Text('Follow')),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: shad.Button.outline(onPressed: onMessage, child: const shad.Text('Message')),
            ),
          ],
          const SizedBox(width: 8),
          _ShareButton(onShare: onShare),
        ],
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({required this.onShare});

  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onShare,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.share, color: AppColors.primary, size: 20),
        ),
      ),
    );
  }
}

void shareProfileLink(String userId, String name) {
  Share.share('Check out $name on Vithey App');
}

void openVerifyStudent() => Get.toNamed(AppRoutes.studentVerification);
