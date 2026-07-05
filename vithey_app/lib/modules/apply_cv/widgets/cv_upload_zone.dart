import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';

class CvUploadZone extends StatelessWidget {
  const CvUploadZone({
    super.key,
    required this.policyLabel,
    required this.enabled,
    required this.onTap,
    required this.onUpdateDefault,
  });

  final String policyLabel;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback onUpdateDefault;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? onTap : null,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.authBorder, width: 1.5, style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 48, color: enabled ? AppColors.authMuted : AppColors.authBorder),
                    const SizedBox(height: 12),
                    Text(
                      'Tap to upload',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: enabled ? AppColors.authHeading : AppColors.authMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(policyLabel, style: const TextStyle(color: AppColors.authMuted, fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: enabled ? onUpdateDefault : null,
              child: const Text('Update my default CV'),
            ),
          ),
        ],
      ),
    );
  }
}
