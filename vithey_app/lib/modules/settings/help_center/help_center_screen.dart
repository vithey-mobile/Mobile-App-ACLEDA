import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/settings/help_center/help_center_controller.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_menu_tile.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_scaffold.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_section_label.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_tile_divider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HelpCenterScreen extends GetView<HelpCenterController> {
  const HelpCenterScreen({super.key});

  static IconData _iconFor(String categoryId) {
    return switch (categoryId) {
      'account' => Icons.person_outline,
      'verification' => Icons.verified_outlined,
      'finance' => Icons.account_balance_wallet_outlined,
      'jobs' => Icons.work_outline,
      'chat' => Icons.chat_bubble_outline,
      'ai' => Icons.auto_awesome_outlined,
      _ => Icons.help_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SettingsScaffold(
      title: 'Help Center',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: _SearchField(
              controller: controller.searchController,
              onChanged: (v) => controller.query.value = v,
            ),
          ),
          const SettingsSectionLabel(label: 'Topics'),
          Obx(() {
            final items = controller.filteredCategories;
            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  'No topics match your search.',
                  style: TextStyle(color: colors.muted, fontSize: 14),
                ),
              );
            }
            return _CardGroup(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SettingsTileDivider(),
                  SettingsMenuTile(
                    icon: _iconFor(items[i].id),
                    label: items[i].title,
                    subtitle: '${items[i].topics.length} articles',
                    onTap: () => controller.openFaqCategory(items[i].id),
                  ),
                ],
              ],
            );
          }),
          const SettingsSectionLabel(label: 'Support'),
          _CardGroup(
            children: [
              SettingsMenuTile(
                icon: Icons.email_outlined,
                label: 'Email Support',
                subtitle: 'support@vithey.app',
                onTap: controller.contactSupport,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? colors.cardSurface : Colors.white;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: TextStyle(
          fontSize: 15,
          color: colors.heading,
        ),
        decoration: InputDecoration(
          hintText: 'Search help topics',
          hintStyle: TextStyle(color: colors.muted, fontSize: 15),
          prefixIcon: Icon(Icons.search, color: colors.muted, size: 22),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _CardGroup extends StatelessWidget {
  const _CardGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? colors.cardSurface : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(children: children),
        ),
      ),
    );
  }
}
