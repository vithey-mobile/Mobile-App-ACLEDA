import 'package:aub_connect_app/core/widgets/vithey_list_tile.dart';
import 'package:flutter/material.dart';

/// Settings-home menu row. Thin alias over [VitheyListTile] so grouped
/// card lists keep a single kit row implementation.
class SettingsMenuTile extends StatelessWidget {
  const SettingsMenuTile({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return VitheyListTile(
      icon: icon,
      title: label,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}
