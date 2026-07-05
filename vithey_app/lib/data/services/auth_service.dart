import 'package:aub_connect_app/core/constants/api_endpoints.dart';
import 'package:aub_connect_app/core/network/api_service.dart';
import 'package:aub_connect_app/data/models/auth_result_model.dart';
import 'package:aub_connect_app/data/models/user_model.dart';

class AuthService {
  AuthService(this._api);

  final ApiService _api;

  Future<AuthResultModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post(
      ApiEndpoints.authLogin,
      data: {'email_or_phone': email, 'password': password},
      fromJson: (json) => AuthResultModel.fromJson(json as Map<String, dynamic>),
    );
    if (!response.isSuccess || response.data == null) {
      throw AuthServiceException(response.error?.message ?? 'Login failed');
    }
    return response.data!;
  }

  Future<AuthResultModel> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await _api.post(
      ApiEndpoints.authRegister,
      data: {
        'full_name': fullName,
        'email': email,
        'password': password,
        'role': 'USER',
      },
      fromJson: (json) => AuthResultModel.fromJson(json as Map<String, dynamic>),
    );
    if (!response.isSuccess || response.data == null) {
      throw AuthServiceException(response.error?.message ?? 'Registration failed');
    }
    return response.data!;
  }

  Future<UserModel> getMe() async {
    final response = await _api.get(
      ApiEndpoints.usersMe,
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
    if (!response.isSuccess || response.data == null) {
      throw AuthServiceException(response.error?.message ?? 'Failed to load profile');
    }
    return response.data!;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _api.patch(
      ApiEndpoints.authChangePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
      fromJson: (_) => null,
    );
    if (!response.isSuccess) {
      throw AuthServiceException(response.error?.message ?? 'Password change failed');
    }
  }
}

class AuthServiceException implements Exception {
  AuthServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
