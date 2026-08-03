import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:aub_connect_app/data/models/profile_skill_catalog.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

/// Resolves a skill logo / category icon for pickers and ring watermarks.
class SkillIcon extends StatelessWidget {
  const SkillIcon({
    super.key,
    this.skill,
    this.catalog,
    this.iconKey,
    this.iconPath,
    this.label,
    this.size = 28,
    this.opacity = 1,
    this.color,
  });

  final ProfileSkill? skill;
  final CatalogSkill? catalog;
  final String? iconKey;
  final String? iconPath;
  final String? label;
  final double size;
  final double opacity;
  final Color? color;

  factory SkillIcon.forSkill(
    ProfileSkill skill, {
    Key? key,
    double size = 28,
    double opacity = 1,
    Color? color,
  }) {
    return SkillIcon(
      key: key,
      skill: skill,
      size: size,
      opacity: opacity,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final path = iconPath ?? skill?.iconPath;
    if (path != null && path.trim().isNotEmpty) {
      final file = File(path);
      if (file.existsSync()) {
        return Opacity(
          opacity: opacity,
          child: Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _fallback(context),
          ),
        );
      }
    }

    final entry = catalog ??
        findCatalogSkill(
          iconKey: iconKey ?? skill?.iconKey,
          label: label ?? skill?.name,
        );

    if (entry?.iconUrl != null && entry!.iconUrl!.isNotEmpty) {
      return Opacity(
        opacity: opacity,
        child: CachedNetworkImage(
          imageUrl: entry.iconUrl!,
          width: size,
          height: size,
          fit: BoxFit.contain,
          fadeInDuration: Duration.zero,
          placeholder: (_, __) => SizedBox(width: size, height: size),
          errorWidget: (_, __, ___) => _material(
            context,
            entry.icon ?? Icons.code,
          ),
        ),
      );
    }

    final iconData = entry?.icon ?? Icons.auto_awesome_outlined;
    return Opacity(
      opacity: opacity,
      child: _material(context, iconData),
    );
  }

  Widget _fallback(BuildContext context) =>
      _material(context, Icons.auto_awesome_outlined);

  Widget _material(BuildContext context, IconData icon) {
    return Icon(
      icon,
      size: size,
      color: color ?? context.appColors.muted,
    );
  }
}
