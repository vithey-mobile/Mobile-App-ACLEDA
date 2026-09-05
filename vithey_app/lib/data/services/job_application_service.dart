import 'package:aub_connect_app/core/constants/api_endpoints.dart';
import 'package:aub_connect_app/core/network/api_service.dart';

class JobApplicationResponse {
  const JobApplicationResponse({
    required this.applicationId,
    required this.jobPostId,
    required this.cvFileId,
    required this.status,
  });

  final String applicationId;
  final String jobPostId;
  final String cvFileId;
  final String status;
}

class JobApplicationService {
  JobApplicationService(this._api);

  final ApiService _api;

  Future<JobApplicationResponse> createApplication({
    required String jobPostId,
    required String cvFileId,
    String? applicationNote,
  }) async {
    final response = await _api.post<JobApplicationResponse>(
      ApiEndpoints.jobApplications(),
      data: {
        'job_post_id': jobPostId,
        'cv_file_id': cvFileId,
        if (applicationNote != null && applicationNote.isNotEmpty) 'application_note': applicationNote,
      },
      fromJson: (json) {
        final data = json as Map<String, dynamic>;
        return JobApplicationResponse(
          applicationId: data['application_id']?.toString() ?? data['id']?.toString() ?? '',
          jobPostId: data['job_post_id']?.toString() ?? jobPostId,
          cvFileId: data['cv_file_id']?.toString() ?? cvFileId,
          status: data['status']?.toString() ?? 'PENDING',
        );
      },
    );
    if (!response.isSuccess || response.data == null) {
      throw JobApplicationServiceException(response.error?.message ?? 'Application failed');
    }
    return response.data!;
  }

  Future<bool> hasApplied(String jobPostId) async {
    final response = await _api.get<List<dynamic>>(
      ApiEndpoints.jobApplications(jobPostId: jobPostId),
      fromJson: (json) => json as List<dynamic>? ?? [],
    );
    if (!response.isSuccess || response.data == null) return false;
    return response.data!.isNotEmpty;
  }
}

class JobApplicationServiceException implements Exception {
  JobApplicationServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
