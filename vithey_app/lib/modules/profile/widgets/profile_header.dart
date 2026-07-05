import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.profile});

  final UserProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 140,
          width: double.infinity,
          color: AppColors.onboardingPlaceholder,
          child: profile.coverUrl != null
              ? Image.network(profile.coverUrl!, fit: BoxFit.cover, width: double.infinity)
              : null,
        ),
        Transform.translate(
          offset: const Offset(0, -40),
          child: UserAvatar(name: profile.fullName, imageUrl: profile.avatarUrl, radius: 44),
        ),
        const SizedBox(height: 8),
        Text(profile.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        if (profile.bio != null && profile.bio!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(profile.bio!, textAlign: TextAlign.center),
          ),
        ],
      ],
    );
  }
}

class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key, required this.profile});

  final UserProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(label: 'Followers', value: '${profile.followerCount}'),
          _StatItem(label: 'Following', value: '${profile.followingCount}'),
          _StatItem(label: 'Posts', value: '${profile.postCount}'),
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
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: AppColors.authMuted, fontSize: 12)),
      ],
    );
  }
}

class ProfileActionRow extends StatelessWidget {
  const ProfileActionRow({
    super.key,
    required this.isOwnProfile,
    required this.isFollowing,
    required this.onFollow,
    required this.onMessage,
    required this.onEditProfile,
    required this.onPreviewCv,
  });

  final bool isOwnProfile;
  final bool isFollowing;
  final VoidCallback onFollow;
  final VoidCallback onMessage;
  final VoidCallback onEditProfile;
  final VoidCallback onPreviewCv;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (isOwnProfile) ...[
            Expanded(
              child: OutlinedButton(onPressed: onEditProfile, child: const Text('Edit Profile')),
            ),
            const SizedBox(width: 8),
            IconButton(onPressed: onPreviewCv, icon: const Icon(Icons.description_outlined), tooltip: 'View CV'),
          ] else ...[
            Expanded(
              child: ElevatedButton(
                onPressed: onFollow,
                child: Text(isFollowing ? 'Following' : 'Follow'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(onPressed: onMessage, child: const Text('Message')),
            ),
          ],
        ],
      ),
    );
  }
}
