import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/modules/settings/help_center/help_center_controller.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_scaffold.dart';

class HelpCenterScreen extends GetView<HelpCenterController> {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'Help Center',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            onChanged: (v) => controller.query.value = v,
            decoration: InputDecoration(
              hintText: 'Search help topics',
              prefixIcon: const Icon(Icons.search, color: AppColors.authMuted),
              filled: true,
              fillColor: AppColors.authInputFill,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How can we help?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Find answers or contact support.', style: TextStyle(color: AppColors.authMuted)),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Contact Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                const Text('Need more help? Reach out to our support team.', style: TextStyle(color: AppColors.authMuted)),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.email_outlined, color: AppColors.primary),
                  title: const Text('Email Support'),
                  subtitle: const Text('support@vithey.app'),
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
    return Material(
      color: AppColors.lightSurface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.help_outline, color: AppColors.authMuted),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500))),
              const Icon(Icons.chevron_right, color: AppColors.authMuted),
            ],
          ),
        ),
      ),
    );
  }
}
