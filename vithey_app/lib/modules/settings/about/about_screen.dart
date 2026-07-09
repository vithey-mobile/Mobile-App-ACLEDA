import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/app_logo.dart';
import 'package:aub_connect_app/modules/settings/about/about_controller.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_menu_tile.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_scaffold.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class AboutScreen extends GetView<AboutController> {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScaffold(
      title: 'About',
      body: Obx(() {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Center(child: AppLogo(size: 80, onWhiteCircle: true)),
            const SizedBox(height: 12),
            const Center(child: Text('Vithey', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
            const SizedBox(height: 4),
            Center(child: Text('AUB student community app', style: TextStyle(color: context.appColors.muted))),
            const SizedBox(height: 8),
            Center(
              child: controller.isLoading.value
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(controller.version.value, style: TextStyle(color: context.appColors.muted, fontSize: 13)),
            ),
            const SizedBox(height: 24),
            const _InfoCard(
              title: 'About Vithey',
              body: 'Connect with students, apply for jobs with your CV, track finance, chat privately, and use AI support — all in one app built for the AUB community.',
            ),
            const SizedBox(height: 12),
            _InfoCard(
              title: 'ACLEDA Bank AUB App Competition',
              body: 'Vithey was created for the ACLEDA Bank AUB App Competition.',
              linkLabel: 'View competition details →',
              onLinkTap: controller.openCompetitionRules,
            ),
            const SizedBox(height: 12),
            _LinkGroup(
              children: [
                SettingsMenuTile(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', onTap: controller.openPrivacyPolicy),
                const Divider(height: 1),
                SettingsMenuTile(icon: Icons.description_outlined, label: 'Terms of Service', onTap: controller.openTerms),
                const Divider(height: 1),
                SettingsMenuTile(icon: Icons.article_outlined, label: 'Licenses', onTap: controller.showLicenses),
                const Divider(height: 1),
                SettingsMenuTile(icon: Icons.support_agent_outlined, label: 'Contact Support', onTap: controller.contactSupport),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.body, this.linkLabel, this.onLinkTap});

  final String title;
  final String body;
  final String? linkLabel;
  final VoidCallback? onLinkTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: context.appColors.subtleShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(body, style: TextStyle(color: context.appColors.heading, height: 1.4)),
          if (linkLabel != null && onLinkTap != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onLinkTap,
              child: Text(linkLabel!, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
            ),
          ],
        ],
      ),
    );
  }
}

class _LinkGroup extends StatelessWidget {
  const _LinkGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.appColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: context.appColors.subtleShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Column(children: children)),
    );
  }
}
