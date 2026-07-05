import 'package:dio/dio.dart';
import 'package:aub_connect_app/core/network/api_response.dart';
import 'package:aub_connect_app/core/network/dio_client.dart';

class ApiService {
  ApiService(this._dioClient);

  final DioClient _dioClient;

  Dio get _dio => _dioClient.dio;

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) fromJson,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(path, queryParameters: queryParameters);
    return ApiResponse.fromJson(response.data ?? {}, fromJson);
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    required T Function(dynamic json) fromJson,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(path, data: data);
    return ApiResponse.fromJson(response.data ?? {}, fromJson);
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    required T Function(dynamic json) fromJson,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(path, data: data);
    return ApiResponse.fromJson(response.data ?? {}, fromJson);
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    required T Function(dynamic json) fromJson,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(path, data: data);
    return ApiResponse.fromJson(response.data ?? {}, fromJson);
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    required T Function(dynamic json) fromJson,
  }) async {
    final response = await _dio.delete<Map<String, dynamic>>(path);
    return ApiResponse.fromJson(response.data ?? {}, fromJson);
  }
}
