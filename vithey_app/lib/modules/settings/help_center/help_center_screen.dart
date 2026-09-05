import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_text_field.dart';
import 'package:aub_connect_app/core/widgets/vithey_card.dart';
import 'package:aub_connect_app/core/widgets/vithey_list_tile.dart';
import 'package:aub_connect_app/modules/settings/help_center/help_center_controller.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HelpCenterScreen extends GetView<HelpCenterController> {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Help Center',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CustomTextField(
            controller: controller.searchController,
            hint: 'Search help topics',
            prefixIcon: Icons.search,
            onChanged: (v) {
              controller.query.value = v;
            },
          ),
          const SizedBox(height: 16),
          VitheyCard(
            bordered: true,
            elevated: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('How can we help?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Find answers or contact support.', style: TextStyle(color: context.appColors.muted)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final items = controller.filteredCategories;
            return Column(
              children: items
                  .map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _FaqTile(
                        title: c.title,
                        onTap: () => controller.openFaqCategory(c.id),
                      ),
                    ),
                  )
                  .toList(),
            );
          }),
          const SizedBox(height: 8),
          VitheyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Contact Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text('Need more help? Reach out to our support team.', style: TextStyle(color: context.appColors.muted)),
                const SizedBox(height: 12),
                VitheyListTile(
                  icon: Icons.email_outlined,
                  title: 'Email Support',
                  subtitle: 'support@vithey.app',
                  onTap: controller.contactSupport,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: VitheyListTile(
        icon: Icons.help_outline,
        title: title,
        onTap: onTap,
      ),
    );
  }
}
