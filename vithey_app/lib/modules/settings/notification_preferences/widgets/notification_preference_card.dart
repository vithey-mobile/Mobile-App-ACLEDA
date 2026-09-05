import 'package:aub_connect_app/core/widgets/vithey_card.dart';
import 'package:flutter/material.dart';

class NotificationPreferenceCard extends StatelessWidget {
  const NotificationPreferenceCard({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return VitheyCard(
      bordered: true,
      borderRadius: 16,
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}
