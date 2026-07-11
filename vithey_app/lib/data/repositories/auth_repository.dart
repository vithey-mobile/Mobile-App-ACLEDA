import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/core/session/current_user_service.dart';
import 'package:aub_connect_app/core/storage/secure_storage_service.dart';
import 'package:aub_connect_app/data/models/auth_result_model.dart';
import 'package:aub_connect_app/data/models/auth_token_model.dart';
import 'package:aub_connect_app/data/fixtures/user_fixtures.dart';
import 'package:aub_connect_app/data/services/auth_service.dart';

class AuthRepository {
  AuthRepository(
    this._authService,
    this._secureStorage,
    this._currentUser,
    this._flags,
  );

  final AuthService _authService;
  final SecureStorageService _secureStorage;
  final CurrentUserService _currentUser;
  final FeatureFlags _flags;

  bool get useMockAuth => _flags.useMockAuth;

  Future<AuthResultModel> login({
    required String email,
    required String password,
  }) async {
    if (useMockAuth) {
      return _mockAuth(email: email, fullName: 'Vithey User');
    }
    final result = await _authService.login(email: email, password: password);
    await _saveTokens(result);
    return result;
  }

  Future<AuthResultModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (useMockAuth) {
      return _mockAuth(email: email, fullName: fullName);
    }
    final result = await _authService.register(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
    );
    await _saveTokens(result);
    return result;
  }

  Future<AuthResultModel> completeGoogleAuth({
    required String email,
    required String displayName,
  }) async {
    if (useMockAuth) {
      return _mockAuth(email: email, fullName: displayName);
    }
    throw AuthServiceException(
      'Google sign-in is not configured yet. Set ENABLE_GOOGLE_AUTH=true when ready.',
    );
  }

  Future<bool> validateSession() async {
    if (useMockAuth) {
      return _secureStorage.hasAccessToken();
    }
    try {
      await _authService.getMe();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    await _secureStorage.clearTokens();
    _currentUser.clear();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (useMockAuth) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (currentPassword.isEmpty) {
        throw AuthServiceException('Current password is incorrect');
      }
      return;
    }
    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } on AuthServiceException catch (e) {
      if (e.message.toLowerCase().contains('404') || e.message.toLowerCase().contains('not found')) {
        throw AuthServiceException('Password change is not available yet.');
      }
      rethrow;
    }
  }

  Future<void> requestPasswordReset({required String email}) async {
    if (useMockAuth) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return;
    }
    await _authService.requestPasswordReset(email: email);
  }

  Future<void> _saveTokens(AuthResultModel result) async {
    await _secureStorage.saveTokens(
      accessToken: result.tokens.accessToken,
      refreshToken: result.tokens.refreshToken,
    );
    _currentUser.setUser(result.user);
  }

  Future<AuthResultModel> _mockAuth({
    required String email,
    required String fullName,
  }) async {
    final result = AuthResultModel(
      user: UserFixtures.currentUser(email: email, fullName: fullName),
      tokens: const AuthTokenModel(
        accessToken: 'mock-access-token',
        refreshToken: 'mock-refresh-token',
        expiresIn: 900,
      ),
    );
    await _saveTokens(result);
    return result;
  }
}
