import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class TypingIndicatorBanner extends StatelessWidget {
  const TypingIndicatorBanner({super.key, required this.participantName});

  final String participantName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        '$participantName is typing…',
        style: TextStyle(
          fontSize: 13,
          fontStyle: FontStyle.italic,
          color: context.appColors.muted,
        ),
      ),
    );
  }
}
