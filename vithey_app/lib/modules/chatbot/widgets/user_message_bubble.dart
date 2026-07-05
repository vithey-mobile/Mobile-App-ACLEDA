import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';

class UserMessageBubble extends StatelessWidget {
  const UserMessageBubble({super.key, required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.authInputFill,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.authBorder),
              ),
              child: Text(content),
            ),
          ),
        ],
      ),
    );
  }
}
