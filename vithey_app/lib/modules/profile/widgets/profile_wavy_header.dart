import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:get/get.dart';

class ProfileWavyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 36)
      ..quadraticBezierTo(size.width * 0.25, size.height + 12, size.width * 0.5, size.height - 20)
      ..quadraticBezierTo(size.width * 0.75, size.height - 52, size.width, size.height - 28)
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class ProfileWavyHeader extends StatelessWidget {
  const ProfileWavyHeader({
    super.key,
    required this.profile,
    this.showMenu = true,
    this.onMenuTap,
    this.showCvPreview = false,
    this.onCvPreviewTap,
  });

  final UserProfileModel profile;
  final bool showMenu;
  final VoidCallback? onMenuTap;
  final bool showCvPreview;
  final VoidCallback? onCvPreviewTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipPath(
              clipper: ProfileWavyClipper(),
              child: Container(
                height: 150,
                width: double.infinity,
                color: AppColors.primary,
                child: Stack(
                  children: [
                    ..._decorIcons(),
                    if (showMenu)
                      Positioned(
                        top: MediaQuery.paddingOf(context).top + 4,
                        left: 8,
                        child: IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: onMenuTap ??
                              () => Get.toNamed(AppRoutes.settings),
                        ),
                      ),
                    if (showCvPreview)
                      Positioned(
                        top: MediaQuery.paddingOf(context).top + 4,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.description_outlined, color: Colors.white),
                          tooltip: 'View CV',
                          onPressed: onCvPreviewTap,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: -44,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: UserAvatar(
                    name: profile.fullName,
                    imageUrl: profile.avatarUrl,
                    radius: 48,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 52),
        Text(
          profile.fullName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        if (profile.bio != null && profile.bio!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              profile.bio!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                height: 1.35,
              ),
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _decorIcons() {
    const iconStyle = TextStyle(color: Colors.white24, fontSize: 22);
    return const [
      Positioned(left: 24, top: 48, child: Text('</>', style: iconStyle)),
      Positioned(right: 40, top: 36, child: Icon(Icons.casino_outlined, color: Colors.white24, size: 22)),
      Positioned(right: 90, top: 70, child: Icon(Icons.view_in_ar_outlined, color: Colors.white24, size: 22)),
      Positioned(left: 80, top: 28, child: Icon(Icons.chat_bubble_outline, color: Colors.white24, size: 20)),
      Positioned(right: 24, top: 88, child: Icon(Icons.star_outline, color: Colors.white24, size: 20)),
    ];
  }
}
