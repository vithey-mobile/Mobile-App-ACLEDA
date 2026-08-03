import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:get/get.dart';

class ProfileWavyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 36)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height + 12,
        size.width * 0.5,
        size.height - 20,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height - 52,
        size.width,
        size.height - 28,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Profile home v1 cover: soft teal over scaffold (light/dark), decor slightly darker.
class ProfileWavyHeader extends StatelessWidget {
  const ProfileWavyHeader({
    super.key,
    required this.profile,
    this.showMenu = true,
    this.onMenuTap,
  });

  final UserProfileModel profile;
  final bool showMenu;
  final VoidCallback? onMenuTap;

  static const _avatarRadius = 56.0;

  /// Soft teal cover that follows scaffold + theme primary in light/dark.
  static Color coverColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = Theme.of(context).scaffoldBackgroundColor;
    return Color.alphaBlend(
      AppColors.authHeaderTeal.withValues(alpha: isDark ? 0.38 : 0.55),
      base,
    );
  }

  /// Decor slightly darker / stronger than [coverColor].
  static Color decorColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cover = coverColor(context);
    return Color.alphaBlend(
      (isDark ? Colors.white : Colors.black)
          .withValues(alpha: isDark ? 0.18 : 0.22),
      cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    final cover = coverColor(context);
    final decor = decorColor(context);
    // Chrome icons must contrast the soft teal cover (not colorScheme.onPrimary).
    final onCover = cover.computeLuminance() > 0.45
        ? const Color(0xFF1A1A2E)
        : Colors.white;
    final avatarRing = Theme.of(context).scaffoldBackgroundColor;
    final heading = context.appColors.heading;
    final muted = context.appColors.muted;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipPath(
              clipper: ProfileWavyClipper(),
              child: Container(
                height: 168,
                width: double.infinity,
                color: cover,
                child: Stack(
                  children: [
                    ..._decorIcons(context, decor, topPad),
                    if (showMenu)
                      Positioned(
                        top: topPad + 4,
                        left: 8,
                        child: IconButton(
                          icon: Icon(
                            Icons.settings_outlined,
                            color: onCover,
                          ),
                          tooltip: 'Settings',
                          onPressed: onMenuTap ??
                              () => Get.toNamed(AppRoutes.settings),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: -_avatarRadius + 8,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: avatarRing, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: context.appColors.subtleShadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: UserAvatar(
                    name: profile.fullName,
                    imageUrl: profile.avatarUrl,
                    radius: _avatarRadius,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 64),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            profile.fullName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: heading,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        if (profile.bio != null && profile.bio!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              profile.bio!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: muted,
                height: 1.35,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Floating decor: clear small vs big sizes, scattered slots + jitter.
  List<Widget> _decorIcons(
    BuildContext context,
    Color iconColor,
    double topPad,
  ) {
    final width = MediaQuery.sizeOf(context).width;
    // Fresh seed → new scatter each time we retune layout.
    final rng = math.Random(profile.id.hashCode ^ 0xA17C0DE7);

    const icons = <IconData>[
      Icons.code,
      Icons.casino_outlined,
      Icons.view_in_ar_outlined,
      Icons.chat_bubble_outline,
      Icons.star_outline,
      Icons.auto_awesome_outlined,
      Icons.bolt_outlined,
      Icons.favorite_border,
      Icons.lightbulb_outline,
      Icons.extension_outlined,
      Icons.sports_esports_outlined,
      Icons.brush_outlined,
      Icons.memory_outlined,
      Icons.cloud_outlined,
      Icons.rocket_launch_outlined,
      Icons.music_note_outlined,
      Icons.camera_alt_outlined,
      Icons.pets_outlined,
      Icons.diamond_outlined,
      Icons.public_outlined,
    ];

    const smallSizes = <double>[10, 12, 14];
    const bigSizes = <double>[30, 34, 38, 42];

    // Asymmetric anchors (not a grid) — denser top-right & lower-left.
    final slots = <(double nx, double ny)>[
      // Top / status area
      (0.18, 0.03),
      (0.40, 0.08),
      (0.58, 0.02),
      (0.78, 0.10),
      (0.94, 0.04),
      (0.30, 0.16),
      (0.68, 0.18),
      (0.88, 0.20),
      // Upper-mid
      (0.12, 0.28),
      (0.46, 0.26),
      (0.84, 0.32),
      (0.24, 0.38),
      (0.62, 0.40),
      // Mid-lower
      (0.06, 0.48),
      (0.38, 0.52),
      (0.72, 0.46),
      (0.96, 0.54),
      (0.20, 0.62),
      (0.54, 0.66),
      // Near wave
      (0.10, 0.78),
      (0.44, 0.84),
      (0.76, 0.72),
      (0.90, 0.80),
    ]..shuffle(rng);

    const coverH = 168.0;
    final widgets = <Widget>[];

    // </> drifts left-upper this pass (was mid-right).
    final codeSize = bigSizes[rng.nextInt(bigSizes.length)];
    widgets.add(
      Positioned(
        left:
            (width * (0.12 + rng.nextDouble() * 0.22)).clamp(60.0, width - 48),
        top: (8 + rng.nextDouble() * (topPad + 18)).clamp(4.0, 56.0),
        child: Opacity(
          opacity: 0.55 + rng.nextDouble() * 0.35,
          child: Transform.rotate(
            angle: (rng.nextDouble() - 0.5) * 0.9,
            child: Text(
              '</>',
              style: TextStyle(
                color: iconColor,
                fontSize: codeSize,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );

    for (final (nx, ny) in slots) {
      final useBig = rng.nextDouble() < 0.45;
      final size = useBig
          ? bigSizes[rng.nextInt(bigSizes.length)]
          : smallSizes[rng.nextInt(smallSizes.length)];

      // Wider jitter so clusters break up.
      final left = width * (nx + (rng.nextDouble() - 0.5) * 0.12);
      var top = coverH * (ny + (rng.nextDouble() - 0.5) * 0.12);
      // Pull top-band icons into the real status/header strip.
      if (ny < 0.22) {
        top = 2 + rng.nextDouble() * (topPad + 34);
      } else {
        top = topPad * 0.25 + top;
      }

      var clampedLeft = left;
      if (clampedLeft < 56 && top < topPad + 48) {
        clampedLeft = 58 + rng.nextDouble() * (width * 0.35);
      }

      widgets.add(
        Positioned(
          left: clampedLeft.clamp(4.0, width - size - 4),
          top: top.clamp(2.0, coverH - size - 8),
          child: Opacity(
            opacity: useBig
                ? 0.45 + rng.nextDouble() * 0.35
                : 0.55 + rng.nextDouble() * 0.4,
            child: Transform.rotate(
              angle: (rng.nextDouble() - 0.5) * 1.2,
              child: Icon(
                icons[rng.nextInt(icons.length)],
                color: iconColor,
                size: size,
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }
}
