import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/app.dart';
import 'package:aub_connect_app/core/network/api_service.dart';
import 'package:aub_connect_app/core/network/dio_client.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/core/storage/secure_storage_service.dart';
import 'package:aub_connect_app/core/theme/app_theme.dart';
import 'package:aub_connect_app/data/repositories/auth_repository.dart';
import 'package:aub_connect_app/data/repositories/comment_repository.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';
import 'package:aub_connect_app/data/repositories/profile_repository.dart';
import 'package:aub_connect_app/data/services/auth_service.dart';
import 'package:aub_connect_app/data/services/post_service.dart';
import 'package:aub_connect_app/data/services/profile_service.dart';
import 'package:aub_connect_app/data/repositories/cv_repository.dart';
import 'package:aub_connect_app/data/repositories/job_application_repository.dart';
import 'package:aub_connect_app/data/repositories/ai_repository.dart';
import 'package:aub_connect_app/data/repositories/chat_repository.dart';
import 'package:aub_connect_app/data/repositories/finance_repository.dart';
import 'package:aub_connect_app/data/repositories/student_verification_repository.dart';
import 'package:aub_connect_app/data/services/ai_service.dart';
import 'package:aub_connect_app/data/services/chat_service.dart';
import 'package:aub_connect_app/data/services/finance_service.dart';
import 'package:aub_connect_app/data/services/job_application_service.dart';
import 'package:aub_connect_app/data/services/student_verification_service.dart';
import 'package:aub_connect_app/data/repositories/notification_repository.dart';
import 'package:aub_connect_app/data/services/notification_service.dart';
import 'package:aub_connect_app/data/services/settings_service.dart';
import 'package:aub_connect_app/data/repositories/settings_repository.dart';
import 'package:aub_connect_app/data/services/upload_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final secureStorage = SecureStorageService();
  final localStorage = LocalStorageService();
  final dioClient = DioClient(secureStorage);

  Get.put<SecureStorageService>(secureStorage, permanent: true);
  Get.put<LocalStorageService>(localStorage, permanent: true);
  Get.put<DioClient>(dioClient, permanent: true);
  Get.put<ApiService>(ApiService(dioClient), permanent: true);
  Get.put<AuthService>(AuthService(Get.find<ApiService>()), permanent: true);
  Get.put<AuthRepository>(
    AuthRepository(Get.find<AuthService>(), secureStorage),
    permanent: true,
  );
  Get.put<PostService>(PostService(Get.find<ApiService>()), permanent: true);
  Get.put<PostRepository>(PostRepository(Get.find<PostService>()), permanent: true);
  Get.put<CommentRepository>(CommentRepository(Get.find<PostRepository>()), permanent: true);
  Get.put<ProfileService>(ProfileService(Get.find<ApiService>()), permanent: true);
  Get.put<UploadService>(UploadService(Get.find<DioClient>()), permanent: true);
  Get.put<JobApplicationService>(JobApplicationService(Get.find<ApiService>()), permanent: true);
  Get.put<CvRepository>(CvRepository(Get.find<UploadService>(), Get.find<ApiService>()), permanent: true);
  Get.put<JobApplicationRepository>(
    JobApplicationRepository(Get.find<PostRepository>(), Get.find<JobApplicationService>()),
    permanent: true,
  );
  Get.put<ProfileRepository>(
    ProfileRepository(Get.find<ProfileService>(), Get.find<PostRepository>()),
    permanent: true,
  );
  Get.put<StudentVerificationService>(StudentVerificationService(Get.find<ApiService>()), permanent: true);
  Get.put<StudentVerificationRepository>(
    StudentVerificationRepository(Get.find<StudentVerificationService>(), localStorage),
    permanent: true,
  );
  Get.put<FinanceService>(FinanceService(Get.find<ApiService>()), permanent: true);
  Get.put<FinanceRepository>(FinanceRepository(Get.find<FinanceService>()), permanent: true);
  Get.put<ChatService>(ChatService(Get.find<ApiService>()), permanent: true);
  Get.put<ChatRepository>(ChatRepository(Get.find<ChatService>()), permanent: true);
  Get.put<AiService>(AiService(Get.find<ApiService>()), permanent: true);
  Get.put<AiRepository>(AiRepository(Get.find<AiService>()), permanent: true);
  Get.put<NotificationService>(NotificationService(Get.find<ApiService>()), permanent: true);
  Get.put<NotificationRepository>(
    NotificationRepository(Get.find<NotificationService>()),
    permanent: true,
  );
  Get.put<SettingsService>(SettingsService(Get.find<ApiService>()), permanent: true);
  Get.put<SettingsRepository>(
    SettingsRepository(Get.find<SettingsService>(), localStorage),
    permanent: true,
  );

  final themeMode = AppTheme.fromStorage(await localStorage.readThemeMode());
  Get.changeThemeMode(themeMode);
  runApp(VitheyApp(themeMode: themeMode));
}
