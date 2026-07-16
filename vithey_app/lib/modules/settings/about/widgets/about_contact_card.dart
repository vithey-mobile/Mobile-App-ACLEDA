import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/settings/about/widgets/about_info_card.dart';

class AboutContactItem {
  const AboutContactItem({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
}

class AboutContactCard extends StatelessWidget {
  const AboutContactCard({super.key, required this.items});

  final List<AboutContactItem> items;

  @override
  Widget build(BuildContext context) {
    return AboutSectionCard(
      title: 'Contact',
      child: Column(
        children: [
          for (final item in items)
            InkWell(
              onTap: item.onTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(item.icon, color: context.scheme.primary, size: 22),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: TextStyle(fontSize: 12, color: context.appColors.muted),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.value,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: item.onTap != null
                                  ? context.scheme.primary
                                  : context.appColors.heading,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
