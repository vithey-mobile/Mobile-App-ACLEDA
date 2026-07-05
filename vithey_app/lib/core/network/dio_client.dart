import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aub_connect_app/core/storage/secure_storage_service.dart';

class DioClient {
  DioClient(this._secureStorage);

  final SecureStorageService _secureStorage;
  Dio? _dio;

  Dio get dio {
    _dio ??= _createDio();
    return _dio!;
  }

  Dio _createDio() {
    final client = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api/v1',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      ),
    );

    client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshed = await _tryRefreshToken(client);
            if (refreshed) {
              final request = error.requestOptions;
              final token = await _secureStorage.readAccessToken();
              request.headers['Authorization'] = 'Bearer $token';
              final response = await client.fetch(request);
              handler.resolve(response);
              return;
            }
          }
          handler.next(error);
        },
      ),
    );

    return client;
  }

  Future<bool> _tryRefreshToken(Dio client) async {
    final refreshToken = await _secureStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      final response = await client.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );
      final data = response.data['data'] as Map<String, dynamic>?;
      if (data == null) return false;
      await _secureStorage.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String? ?? refreshToken,
      );
      return true;
    } catch (_) {
      await _secureStorage.clearTokens();
      return false;
    }
  }
}
