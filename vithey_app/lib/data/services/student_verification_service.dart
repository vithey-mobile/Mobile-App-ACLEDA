import 'package:aub_connect_app/core/constants/api_endpoints.dart';
import 'package:aub_connect_app/core/network/api_service.dart';

class StudentVerificationService {
  StudentVerificationService(this._api);

  final ApiService _api;

  Future<void> submitVerification({
    required String studentId,
    required String universityEmail,
    String? documentFileId,
  }) async {
    final response = await _api.post<void>(
      ApiEndpoints.studentsVerify,
      data: {
        'student_id': studentId,
        'university_email': universityEmail,
        if (documentFileId != null) 'document_file_id': documentFileId,
      },
      fromJson: (_) {},
    );
    if (!response.isSuccess) {
      throw StudentVerificationServiceException(response.error?.message ?? 'Verification failed');
    }
  }
}

class StudentVerificationServiceException implements Exception {
  StudentVerificationServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
