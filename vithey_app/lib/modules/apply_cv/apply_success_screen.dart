import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/modules/apply_cv/models/apply_success_args.dart';
import 'package:aub_connect_app/modules/apply_cv/models/application_status_args.dart';
import 'package:aub_connect_app/modules/apply_cv/widgets/application_submitted_hero.dart';

class ApplySuccessScreen extends StatelessWidget {
  const ApplySuccessScreen({super.key});

  ApplySuccessArgs get _args => ApplySuccessArgs.from(Get.arguments);

  @override
  Widget build(BuildContext context) {
    final args = _args;
    final body = args.result.jobPostId.isNotEmpty
        ? AppStrings.applicationSubmittedBody
        : AppStrings.applicationSubmittedBody;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Get.back(result: args.result);
      },
      child: Scaffold(
        backgroundColor: context.appColors.bodyBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(),
                const ApplicationSubmittedHero(),
                const SizedBox(height: 28),
                Text(
                  AppStrings.applicationSubmittedTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.appColors.heading,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.appColors.muted, height: 1.5),
                ),
                const Spacer(),
                CustomButton(
                  label: AppStrings.viewApplicationStatus,
                  variant: CustomButtonVariant.outline,
                  icon: Icons.visibility_outlined,
                  onPressed: () {
                    Get.toNamed(
                      AppRoutes.applicationStatus,
                      arguments: ApplicationStatusArgs(
                        applicationId: args.applicationId,
                        jobPostId: args.jobPostId,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
