import 'package:get/get.dart';
import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/core/storage/secure_storage_service.dart';
import 'package:aub_connect_app/modules/auth/auth_binding.dart';
import 'package:aub_connect_app/modules/auth/forgot_password_screen.dart';
import 'package:aub_connect_app/modules/auth/google_auth_screen.dart';
import 'package:aub_connect_app/modules/auth/login_screen.dart';
import 'package:aub_connect_app/modules/create_post/create_post_screen.dart';
import 'package:aub_connect_app/modules/shell/main_shell_screen.dart';
import 'package:aub_connect_app/modules/reels/reels_binding.dart';
import 'package:aub_connect_app/modules/reels/reels_screen.dart';
import 'package:aub_connect_app/modules/apply_cv/apply_cv_binding.dart';
import 'package:aub_connect_app/modules/apply_cv/apply_cv_screen.dart';
import 'package:aub_connect_app/modules/apply_cv/apply_success_screen.dart';
import 'package:aub_connect_app/modules/apply_cv/application_status_screen.dart';
import 'package:aub_connect_app/modules/post_detail/post_detail_binding.dart';
import 'package:aub_connect_app/modules/post_detail/post_detail_screen.dart';
import 'package:aub_connect_app/modules/profile/applicant_detail_screen.dart';
import 'package:aub_connect_app/modules/profile/cv_screens.dart';
import 'package:aub_connect_app/modules/profile/edit_profile_screen.dart';
import 'package:aub_connect_app/modules/profile/job_applicants_screen.dart';
import 'package:aub_connect_app/modules/profile/profile_binding.dart';
import 'package:aub_connect_app/modules/profile/profile_screen.dart';
import 'package:aub_connect_app/modules/profile/profile_view_binding.dart';
import 'package:aub_connect_app/modules/profile/profile_view_screen.dart';
import 'package:aub_connect_app/modules/profile/scan_qr_screen.dart';
import 'package:aub_connect_app/modules/onboarding/onboarding_binding.dart';
import 'package:aub_connect_app/modules/onboarding/onboarding_screen.dart';
import 'package:aub_connect_app/modules/select_language/select_language_binding.dart';
import 'package:aub_connect_app/modules/select_language/select_language_screen.dart';
import 'package:aub_connect_app/modules/splash/splash_controller.dart';
import 'package:aub_connect_app/modules/splash/splash_screen.dart';
import 'package:aub_connect_app/modules/chatbot/chatbot_binding.dart';
import 'package:aub_connect_app/modules/chatbot/chatbot_screen.dart';
import 'package:aub_connect_app/modules/notification/notification_binding.dart';
import 'package:aub_connect_app/modules/notification/notification_screen.dart';
import 'package:aub_connect_app/modules/search/search_binding.dart';
import 'package:aub_connect_app/modules/search/search_screen.dart';
import 'package:aub_connect_app/modules/search/search_see_all_screen.dart';
import 'package:aub_connect_app/modules/settings/about/about_binding.dart';
import 'package:aub_connect_app/modules/settings/about/about_screen.dart';
import 'package:aub_connect_app/modules/settings/account/account_settings_binding.dart';
import 'package:aub_connect_app/modules/settings/account/account_settings_screen.dart';
import 'package:aub_connect_app/modules/settings/account/edit_account_settings_binding.dart';
import 'package:aub_connect_app/modules/settings/account/edit_account_settings_screen.dart';
import 'package:aub_connect_app/modules/settings/change_password/change_password_binding.dart';
import 'package:aub_connect_app/modules/settings/change_password/change_password_screen.dart';
import 'package:aub_connect_app/modules/settings/help_center/help_center_binding.dart';
import 'package:aub_connect_app/modules/settings/help_center/help_center_screen.dart';
import 'package:aub_connect_app/modules/settings/notification_preferences/notification_preferences_binding.dart';
import 'package:aub_connect_app/modules/settings/notification_preferences/notification_preferences_screen.dart';
import 'package:aub_connect_app/modules/settings/privacy/privacy_settings_binding.dart';
import 'package:aub_connect_app/modules/settings/privacy/privacy_settings_screen.dart';
import 'package:aub_connect_app/modules/settings/privacy/privacy_practices_screen.dart';
import 'package:aub_connect_app/modules/settings/security/security_settings_binding.dart';
import 'package:aub_connect_app/modules/settings/security/security_settings_screen.dart';
import 'package:aub_connect_app/modules/settings/settings_binding.dart';
import 'package:aub_connect_app/modules/settings/settings_home_screen.dart';
import 'package:aub_connect_app/modules/chat/chat_binding.dart';
import 'package:aub_connect_app/modules/chat/chat_detail_screen.dart';
import 'package:aub_connect_app/modules/chat/chat_list_screen.dart';
import 'package:aub_connect_app/modules/chat/chat_profile_screen.dart';
import 'package:aub_connect_app/modules/finance/finance_binding.dart';
import 'package:aub_connect_app/modules/finance/finance_screen.dart';
import 'package:aub_connect_app/modules/student_verification/student_verification_binding.dart';
import 'package:aub_connect_app/modules/student_verification/student_verification_screen.dart';
import 'package:aub_connect_app/modules/student_verification/verification_status_screen.dart';
import 'package:aub_connect_app/modules/startup/startup_binding.dart';
import 'package:aub_connect_app/modules/startup/startup_screen.dart';
import 'package:aub_connect_app/modules/map/map_binding.dart';
import 'package:aub_connect_app/modules/map/map_screen.dart';
import 'package:aub_connect_app/modules/add_place/add_place_binding.dart';
import 'package:aub_connect_app/modules/add_place/add_place_screen.dart';
class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(
      SplashController(
        Get.find<SecureStorageService>(),
        Get.find<LocalStorageService>(),
        Get.find<FeatureFlags>(),
      ),
    );
  }
}

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.selectLanguage,
      page: () => const SelectLanguageScreen(),
      binding: SelectLanguageBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.auth,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.googleAccountChooser,
      page: () => const GoogleAccountChooserScreen(),
      binding: AuthBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 320),
    ),
    GetPage(
      name: AppRoutes.googleAuthConfirmation,
      page: () => const GoogleAuthConfirmationScreen(),
      binding: AuthBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 320),
    ),
    GetPage(
      name: AppRoutes.startupSkills,
      page: () => const StartupScreen(),
      binding: StartupBinding(),
    ),
    GetPage(
      name: AppRoutes.startupInterests,
      page: () => const StartupScreen(),
      binding: StartupBinding(),
    ),
    GetPage(
      name: AppRoutes.startupDiscovery,
      page: () => const StartupScreen(),
      binding: StartupBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const MainShellScreen(),
      binding: MainShellBinding(),
    ),
    GetPage(
      name: AppRoutes.reels,
      page: () => const ReelsScreen(),
      binding: ReelsBinding(),
    ),
    GetPage(
      name: AppRoutes.createPost,
      page: () => const CreatePostScreen(),
      binding: CreatePostBinding(),
    ),
    GetPage(
      name: AppRoutes.postDetail,
      page: () => const PostDetailScreen(),
      binding: PostDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.applyCv,
      page: () => const ApplyCvScreen(),
      binding: ApplyCvBinding(),
    ),
    GetPage(
      name: AppRoutes.applySuccess,
      page: () => const ApplySuccessScreen(),
    ),
    GetPage(
      name: AppRoutes.applicationStatus,
      page: () => const ApplicationStatusScreen(),
      binding: ApplicationStatusBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.profileView,
      page: () => const ProfileViewScreen(),
      binding: ProfileViewBinding(),
    ),
    GetPage(
      name: AppRoutes.scanQr,
      page: () => const ScanQrScreen(),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileScreen(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.jobApplicants,
      page: () => const JobApplicantsScreen(),
      binding: JobApplicantsBinding(),
    ),
    GetPage(
      name: AppRoutes.applicantDetail,
      page: () => const ApplicantDetailScreen(),
      binding: ApplicantDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.applicantCvPreview,
      page: () => const ApplicantCvScreen(),
      binding: ApplicantCvBinding(),
    ),
    GetPage(
      name: AppRoutes.previewOwnCv,
      page: () => const PreviewOwnCvScreen(),
    ),
    GetPage(
      name: AppRoutes.studentVerification,
      page: () => const StudentVerificationScreen(),
      binding: StudentVerificationBinding(),
    ),
    GetPage(
      name: AppRoutes.verificationStatus,
      page: () => const VerificationStatusScreen(),
      binding: VerificationStatusBinding(),
    ),
    GetPage(
      name: AppRoutes.finance,
      page: () => const FinanceScreen(),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatListScreen(),
      binding: ChatListBinding(),
    ),
    GetPage(
      name: AppRoutes.chatDetail,
      page: () => const ChatDetailScreen(),
      binding: ChatDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.chatProfile,
      page: () => const ChatProfileScreen(),
      binding: ChatProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.chatbot,
      page: () => const ChatbotScreen(),
      binding: ChatbotBinding(),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationScreen(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchScreen(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: AppRoutes.searchSeeAll,
      page: () => const SearchSeeAllScreen(),
      binding: SearchSeeAllBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsHomeScreen(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.settingsAccount,
      page: () => const AccountSettingsScreen(),
      binding: AccountSettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.settingsEditAccount,
      page: () => const EditAccountSettingsScreen(),
      binding: EditAccountSettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.settingsPrivacy,
      page: () => const PrivacySettingsScreen(),
      binding: PrivacySettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.settingsPrivacyPractices,
      page: () => const PrivacyPracticesScreen(),
    ),
    GetPage(
      name: AppRoutes.settingsNotifications,
      page: () => const NotificationPreferencesScreen(),
      binding: NotificationPreferencesBinding(),
    ),
    GetPage(
      name: AppRoutes.settingsSecurity,
      page: () => const SecuritySettingsScreen(),
      binding: SecuritySettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.settingsChangePassword,
      page: () => const ChangePasswordScreen(),
      binding: ChangePasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.settingsHelpCenter,
      page: () => const HelpCenterScreen(),
      binding: HelpCenterBinding(),
    ),
    GetPage(
      name: AppRoutes.settingsAbout,
      page: () => const AboutScreen(),
      binding: AboutBinding(),
    ),
    GetPage(
      name: AppRoutes.map,
      page: () => const MapScreen(),
      binding: MapBinding(),
    ),
    GetPage(
      name: AppRoutes.addPlace,
      page: () => const AddPlaceScreen(),
      binding: AddPlaceBinding(),
    ),
  ];
}
