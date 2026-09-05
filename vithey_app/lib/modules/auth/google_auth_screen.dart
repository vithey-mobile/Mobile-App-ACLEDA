import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_assets.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/app_logo.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/modules/auth/auth_controller.dart';

/// Mock accounts for the UI chooser (dev / demo).
const _mockGoogleAccounts = <GoogleAccountSummary>[
  GoogleAccountSummary(
    displayName: 'Molika Khorn',
    email: 'molika.ops@aub.edu.kh',
  ),
  GoogleAccountSummary(
    displayName: 'Username',
    email: 'email@edu.kh',
  ),
];

Color _secondaryText(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? const Color(0xFFB0B0BE) : const Color(0xFF5A5A68);
}

/// Google Auth Screen 1 — account chooser (white, match Auth Google Screen 1.png).
class GoogleAccountChooserScreen extends StatefulWidget {
  const GoogleAccountChooserScreen({super.key});

  @override
  State<GoogleAccountChooserScreen> createState() =>
      _GoogleAccountChooserScreenState();
}

class _GoogleAccountChooserScreenState extends State<GoogleAccountChooserScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeOut;
  late final Animation<double> _fadeAnim;
  final _controller = Get.find<AuthController>();
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _fadeOut = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeOut, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeOut.dispose();
    super.dispose();
  }

  void _clearFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> _goToConfirm(GoogleAccountSummary account) async {
    if (_leaving || _fadeOut.isAnimating) return;
    setState(() => _leaving = true);
    _clearFocus();
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    await _fadeOut.forward();
    await _controller.selectGoogleAccount(account);
    if (mounted) {
      _fadeOut.reset();
      setState(() => _leaving = false);
    }
  }

  Future<void> _onAddAccount() async {
    if (_leaving || _fadeOut.isAnimating) return;
    _clearFocus();
    await _controller.promptGoogleAccountAdded();
    final account = _controller.selectedGoogleAccount;
    if (account == null || !mounted) return;
    await _goToConfirm(account);
  }

  Future<void> _onPrimarySignIn() async {
    await _goToConfirm(_mockGoogleAccounts.first);
  }

  @override
  Widget build(BuildContext context) {
    final heading = context.appColors.heading;
    final secondary = _secondaryText(context);
    final border = context.appColors.border;
    final bg = context.appColors.bodyBackground;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Theme(
          data: Theme.of(context).copyWith(
            splashFactory: NoSplash.splashFactory,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            listTileTheme: const ListTileThemeData(
              selectedTileColor: Colors.transparent,
              selectedColor: null,
            ),
          ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 1, end: 0).animate(_fadeAnim),
            child: IgnorePointer(
              ignoring: _leaving,
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const AppLogo(size: 70, onWhiteCircle: true),
                              const SizedBox(height: 24),
                              Text(
                                'Sign in with Google',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: heading,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'To continue to Vithey',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: secondary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 28),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: border),
                                ),
                                child: Column(
                                  children: [
                                    for (var i = 0;
                                        i < _mockGoogleAccounts.length;
                                        i++) ...[
                                      if (i > 0)
                                        Divider(height: 1, color: border),
                                      _AccountTile(
                                        account: _mockGoogleAccounts[i],
                                        secondary: secondary,
                                        onTap: () => _goToConfirm(
                                          _mockGoogleAccounts[i],
                                        ),
                                      ),
                                    ],
                                    Divider(height: 1, color: border),
                                    _AddAccountRow(
                                      secondary: secondary,
                                      heading: heading,
                                      onTap: _onAddAccount,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),
                              SizedBox(
                                width: double.infinity,
                                child: CustomButton(
                                  label: 'Sign In',
                                  onPressed: _onPrimarySignIn,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomButton(
                                    label: 'Back',
                                    variant: CustomButtonVariant.ghost,
                                    foregroundColor: secondary,
                                    onPressed: _controller.cancelGoogleAuth,
                                  ),
                                  CustomButton(
                                    label: 'Sign In',
                                    variant: CustomButtonVariant.ghost,
                                    foregroundColor: AppColors.primary,
                                    onPressed: _controller.cancelGoogleAuth,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              Text(
                                'To continue, Google will share your name, email address, language preference, and profile picture with Vithey.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: secondary,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Text(
                      'Privacy Policy - Terms of Service',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: secondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Google Auth Screen 2 — confirmation (match Auth Google Screen 2.png).
class GoogleAuthConfirmationScreen extends GetView<AuthController> {
  const GoogleAuthConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final account = controller.selectedGoogleAccount;
    final heading = context.appColors.heading;
    final secondary = _secondaryText(context);
    final border = context.appColors.border;
    final firstName = account?.firstName ?? 'User';

    return Scaffold(
      backgroundColor: context.appColors.bodyBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: border),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        AppAssets.googleIcon,
                        width: 36,
                        height: 36,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Continue to Vithey',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: heading,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'To continue, Google will share your name, email address, and profile picture with Vithey.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: secondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),
                      UserAvatar(
                        name: account?.displayName,
                        imageUrl: account?.photoUrl,
                        radius: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        account?.displayName ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: heading,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        account?.email ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: secondary, fontSize: 14),
                      ),
                      const SizedBox(height: 28),
                      Obx(() {
                        final loading = controller.isGoogleLoading.value;
                        return SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            label: 'Continue as $firstName',
                            isLoading: loading,
                            onPressed:
                                loading ? null : controller.completeGoogleAuth,
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          label: AppStrings.cancel,
                          variant: CustomButtonVariant.outline,
                          onPressed: controller.backToGoogleChooser,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account. ',
                            style: TextStyle(color: secondary, fontSize: 13),
                          ),
                          CustomButton(
                            label: AppStrings.signIn,
                            variant: CustomButtonVariant.ghost,
                            foregroundColor: AppColors.primary,
                            onPressed: controller.cancelGoogleAuth,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.account,
    required this.secondary,
    required this.onTap,
  });

  final GoogleAccountSummary account;
  final Color secondary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            UserAvatar(
              name: account.displayName,
              imageUrl: account.photoUrl,
              radius: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: context.appColors.heading,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    account.email,
                    style: TextStyle(color: secondary, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddAccountRow extends StatelessWidget {
  const _AddAccountRow({
    required this.secondary,
    required this.heading,
    required this.onTap,
  });

  final Color secondary;
  final Color heading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: context.appColors.inputFill,
              child: Icon(Icons.add, color: secondary),
            ),
            const SizedBox(width: 12),
            Text(
              'Add another account',
              style: TextStyle(color: heading, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
