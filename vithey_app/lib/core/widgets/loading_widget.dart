import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';

/// Centered loading indicator.
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!.tr, style: Theme.of(context).textTheme.bodyMedium),
          ] else ...[
            const SizedBox(height: 16),
            Text(AppStrings.loading.tr, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
