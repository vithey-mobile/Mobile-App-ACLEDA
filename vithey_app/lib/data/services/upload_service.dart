import 'dart:io';

import 'package:dio/dio.dart';
import 'package:aub_connect_app/core/constants/api_endpoints.dart';
import 'package:aub_connect_app/core/network/dio_client.dart';
import 'package:aub_connect_app/data/models/cv_file_model.dart';

class UploadService {
  UploadService(this._dioClient);

  final DioClient _dioClient;

  Future<UploadedCvFile> uploadCv({
    required String filePath,
    required String fileName,
    required String mimeType,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
      'type': 'CV',
    });

    final response = await _dioClient.dio.post<Map<String, dynamic>>(
      ApiEndpoints.filesUpload,
      data: formData,
    );

    final body = response.data ?? {};
    final data = body['data'] as Map<String, dynamic>? ?? body;
    return UploadedCvFile(
      fileId: data['file_id']?.toString() ?? data['id']?.toString() ?? '',
      fileName: data['file_name'] as String? ?? fileName,
      mimeType: data['mime_type'] as String? ?? mimeType,
      sizeBytes: data['size_bytes'] as int? ?? File(filePath).lengthSync(),
    );
  }
}

class UploadServiceException implements Exception {
  UploadServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
