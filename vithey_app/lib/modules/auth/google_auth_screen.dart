import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/widgets/app_logo.dart';
import 'package:aub_connect_app/modules/auth/auth_controller.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class GoogleAccountChooserScreen extends GetView<AuthController> {
  const GoogleAccountChooserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              const AppLogo(size: 70, onWhiteCircle: true),
              const SizedBox(height: 24),
              Text(
                'Sign in with Google',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: context.appColors.heading),
              ),
              const SizedBox(height: 8),
              Text('To continue to Vithey', style: TextStyle(color: context.appColors.muted)),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: context.appColors.border),
                ),
                child: Column(
                  children: [
                    _AccountTile(
                      name: 'Demo User',
                      email: 'demo@aub.edu.kh',
                      onTap: () => controller.selectGoogleAccount(
                        const GoogleAccountSummary(displayName: 'Demo User', email: 'demo@aub.edu.kh'),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.add)),
                      title: const Text('Add another account'),
                      onTap: () => controller.selectGoogleAccount(
                        const GoogleAccountSummary(displayName: 'New User', email: 'new@aub.edu.kh'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Back to ', style: TextStyle(color: context.appColors.muted)),
                  GestureDetector(
                    onTap: controller.cancelGoogleAuth,
                    child: const Text(AppStrings.signIn, style: TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'To continue, Google will share your name, email address, language preference, and profile picture with Vithey.',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.appColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GoogleAuthConfirmationScreen extends GetView<AuthController> {
  const GoogleAuthConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final account = controller.selectedGoogleAccount;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        child: Text(
                          account?.displayName.substring(0, 1).toUpperCase() ?? '?',
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(account?.displayName ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(account?.email ?? '', style: TextStyle(color: context.appColors.muted)),
                      const SizedBox(height: 24),
                      const Text(
                        'Vithey wants to access your basic profile info',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Obx(() => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: controller.isGoogleLoading.value ? null : controller.completeGoogleAuth,
                              child: controller.isGoogleLoading.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text('Continue'),
                            ),
                          )),
                      TextButton(onPressed: controller.cancelGoogleAuth, child: const Text(AppStrings.cancel)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.name,
    required this.email,
    required this.onTap,
  });

  final String name;
  final String email;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(name.substring(0, 1))),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(email),
      onTap: onTap,
    );
  }
}
