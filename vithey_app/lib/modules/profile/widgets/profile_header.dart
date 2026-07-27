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
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            label: 'Likes',
            value: formatProfileCount(profile.likeCount),
          ),
          _StatItem(
            label: 'Followers',
            value: formatProfileCount(profile.followerCount),
          ),
          _StatItem(
            label: 'Following',
            value: formatProfileCount(profile.followingCount),
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
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: heading,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: muted,
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

  static const _buttonHeight = 40.0;
  static const _radius = 10.0;

  @override
  Widget build(BuildContext context) {
    final heading = context.appColors.heading;
    final verifyFill = context.appColors.inputFill;
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Row(
        children: [
          if (isOwnProfile) ...[
            Expanded(
              child: SizedBox(
                height: _buttonHeight,
                child: FilledButton.icon(
                  onPressed: onEditProfile,
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_radius),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text(
                    'Edit Profile Info',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: _buttonHeight,
                child: FilledButton.icon(
                  onPressed: onVerifyStudent,
                  style: FilledButton.styleFrom(
                    backgroundColor: verifyFill,
                    foregroundColor: heading,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_radius),
                    ),
                  ),
                  icon: Icon(
                    isStudentVerified
                        ? Icons.verified_outlined
                        : Icons.verified_user_outlined,
                    size: 16,
                  ),
                  label: Text(
                    isStudentVerified ? 'Review Verify' : 'Verify Student',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: SizedBox(
                height: _buttonHeight,
                child: isFollowing
                    ? OutlinedButton(
                        onPressed: onFollow,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primary,
                          side: BorderSide(color: primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(_radius),
                          ),
                        ),
                        child: const Text(
                          'Following',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      )
                    : FilledButton(
                        onPressed: onFollow,
                        style: FilledButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(_radius),
                          ),
                        ),
                        child: const Text(
                          'Follow',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: _buttonHeight,
                child: OutlinedButton(
                  onPressed: onMessage,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: BorderSide(color: primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_radius),
                    ),
                  ),
                  child: const Text(
                    'Message',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(width: 4),
          IconButton(
            onPressed: onShare,
            tooltip: 'Share',
            icon: const Icon(Icons.ios_share, size: 22),
            color: primary,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
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
