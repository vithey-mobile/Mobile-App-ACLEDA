import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';

class OnboardingBottomSection extends StatelessWidget {
  const OnboardingBottomSection({
    super.key,
    required this.title,
    required this.description,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
  });

  final String title;
  final String description;
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isLast = currentPage == totalPages - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.onboardingTitle,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.onboardingBody, height: 1.4),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalPages, (index) {
              final active = index == currentPage;
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? AppColors.onboardingDotActive : AppColors.onboardingDotInactive,
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              label: isLast ? AppStrings.getStarted : AppStrings.next,
              icon: Icons.arrow_forward,
              onPressed: onNext,
            ),
          ),
        ],
      ),
    );
  }
}
