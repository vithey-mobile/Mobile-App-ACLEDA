import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';

class JumpToLatestButton extends StatelessWidget {
  const JumpToLatestButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_downward, size: 16, color: AppColors.primary),
              SizedBox(width: 4),
              Text('Jump to latest', style: TextStyle(color: AppColors.primary, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
