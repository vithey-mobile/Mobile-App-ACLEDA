import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class JumpToLatestButton extends StatelessWidget {
  const JumpToLatestButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return shad.Button.secondary(
      onPressed: onTap,
      leading: const Icon(Icons.arrow_downward, size: 16),
      child: const shad.Text('Jump to latest'),
    );
  }
}
