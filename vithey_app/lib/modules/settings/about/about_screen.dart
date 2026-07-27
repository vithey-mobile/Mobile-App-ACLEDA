import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/modules/settings/about/about_controller.dart';
import 'package:aub_connect_app/modules/settings/about/widgets/about_contact_card.dart';
import 'package:aub_connect_app/modules/settings/about/widgets/about_feature_list_card.dart';
import 'package:aub_connect_app/modules/settings/about/widgets/about_header.dart';
import 'package:aub_connect_app/modules/settings/about/widgets/about_info_card.dart';
import 'package:aub_connect_app/modules/settings/widgets/settings_scaffold.dart';

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
            AboutHeader(
              version: controller.version.value,
              isLoading: controller.isLoading.value,
            ),
            const SizedBox(height: 24),
            const AboutInfoCard(
              title: 'About Vithey',
              body:
                  'Connect with students, apply for jobs with your CV, track finance, chat privately, and use AI support — all in one app built for the AUB community.',
            ),
            const SizedBox(height: 12),
            const AboutInfoCard(
              title: 'Mission',
              body:
                  'Empower AUB students to connect, grow their skills, and manage student life in one place.',
            ),
            const SizedBox(height: 12),
            const AboutFeatureListCard(
              features: [
                'Social Feed',
                'Career & Jobs',
                'Skill Tracking',
                'Learning Roadmap',
                'School Fee Tracking',
                'Private Chat',
                'AI Assistant',
              ],
            ),
            const SizedBox(height: 12),
            AboutContactCard(
              items: [
                AboutContactItem(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: AboutController.contactPhone,
                  onTap: controller.callPhone,
                ),
                AboutContactItem(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: AboutController.contactEmail,
                  onTap: controller.sendEmail,
                ),
                AboutContactItem(
                  icon: Icons.language_outlined,
                  label: 'Website',
                  value: AboutController.contactWebsite,
                  onTap: controller.openWebsite,
                ),
                const AboutContactItem(
                  icon: Icons.location_on_outlined,
                  label: 'Location',
                  value: AboutController.contactLocation,
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
