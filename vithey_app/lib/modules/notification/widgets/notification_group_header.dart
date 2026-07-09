import 'package:flutter/material.dart';

class NotificationGroupHeader extends StatelessWidget {
  const NotificationGroupHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
