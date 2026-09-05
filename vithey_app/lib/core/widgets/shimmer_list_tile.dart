import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton tile for list loading states.
class ShimmerListTile extends StatelessWidget {
  const ShimmerListTile({super.key});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlight = Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: highlight, shape: BoxShape.circle)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: double.infinity, color: highlight),
                  const SizedBox(height: 8),
                  Container(height: 12, width: 120, color: highlight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
