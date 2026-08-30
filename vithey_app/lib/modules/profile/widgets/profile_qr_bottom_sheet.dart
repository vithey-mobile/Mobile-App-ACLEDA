import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_assets.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/profile/widgets/edit_profile_bottom_sheet.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_header.dart';
import 'package:get/get.dart';

Future<void> showProfileQrBottomSheet({
  required BuildContext context,
  required String userId,
  required String userName,
}) {
  return showEditProfileSheet<void>(
    context: context,
    title: 'QR Code',
    builder: (sheetContext) {
      return _ProfileQrSheetBody(
        userId: userId,
        userName: userName,
      );
    },
  );
}

class _ProfileQrSheetBody extends StatelessWidget {
  const _ProfileQrSheetBody({
    required this.userId,
    required this.userName,
  });

  final String userId;
  final String userName;

  static const _buttonPadding =
      EdgeInsets.symmetric(horizontal: 20, vertical: 10);
  static const _buttonGap = 16.0;
  static const _radius = 8.0;
  static const _labelStyle = TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 13,
    height: 1.1,
  );

  ButtonStyle _filledStyle(Color background, Color foreground) {
    return FilledButton.styleFrom(
      backgroundColor: background,
      foregroundColor: foreground,
      elevation: 0,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minimumSize: Size.zero,
      padding: _buttonPadding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
      ),
    );
  }

  ButtonStyle _outlinedStyle({
    required Color foreground,
    required Color border,
    Color? background,
  }) {
    return OutlinedButton.styleFrom(
      foregroundColor: foreground,
      backgroundColor: background,
      side: BorderSide(color: border),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minimumSize: Size.zero,
      padding: _buttonPadding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
      ),
    );
  }

  void _onScanQrCode(BuildContext context) {
    Navigator.of(context).pop();
    Get.toNamed(AppRoutes.scanQr);
  }

  void _onShareQrCode() {
    shareProfileLink(userId, userName);
  }

  @override
  Widget build(BuildContext context) {
    final heading = context.appColors.heading;
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final border = context.appColors.border;
    final sheet = Theme.of(context).scaffoldBackgroundColor;
    final qrSize = MediaQuery.sizeOf(context).width * 0.62;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              AppAssets.profileQrCode,
              width: qrSize,
              height: qrSize,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: () => _onScanQrCode(context),
                style: _filledStyle(primary, onPrimary),
                child: const Text('Scan QR Code', style: _labelStyle),
              ),
              const SizedBox(width: _buttonGap),
              OutlinedButton(
                onPressed: _onShareQrCode,
                style: _outlinedStyle(
                  foreground: heading,
                  border: border,
                  background: sheet,
                ),
                child: const Text('Share QR Code', style: _labelStyle),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
