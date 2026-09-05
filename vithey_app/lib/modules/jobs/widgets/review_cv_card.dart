import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class ReviewCvCard extends StatelessWidget {
  const ReviewCvCard({
    super.key,
    required this.fileName,
    required this.sizeLabel,
    required this.enabled,
    required this.onRemove,
    this.onTap,
  });

  final String fileName;
  final String sizeLabel;
  final bool enabled;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.appColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: AppColors.error, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (sizeLabel.isNotEmpty)
                        Text(sizeLabel, style: TextStyle(fontSize: 12, color: context.appColors.muted)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Remove',
                  onPressed: enabled ? onRemove : null,
                  icon: Icon(Icons.close, color: context.appColors.muted, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: context.appColors.inputFill,
                    minimumSize: const Size(32, 32),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
