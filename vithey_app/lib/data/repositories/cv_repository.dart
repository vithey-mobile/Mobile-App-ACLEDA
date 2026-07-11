import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/data/fixtures/cv_fixtures.dart';
import 'package:aub_connect_app/data/models/cv_file_model.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/data/services/upload_service.dart';
import 'package:aub_connect_app/core/constants/api_endpoints.dart';
import 'package:aub_connect_app/core/network/api_service.dart';

class CvRepository {
  CvRepository(this._uploadService, this._api, this._flags);

  final UploadService _uploadService;
  final ApiService _api;
  final FeatureFlags _flags;

  static const maxBytes = 10 * 1024 * 1024;
  static const acceptedExtensions = ['pdf', 'doc', 'docx'];
  static const acceptedMimeTypes = {
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  };

  bool get useMockApi => _flags.useMockApi;

  CvMetadataModel? _mockSavedCv = CvFixtures.savedCv();

  Future<String?> getApplicantCvDownloadUrl(String applicationId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return CvFixtures.previewUrl;
    }
    final response = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.jobApplicationCvPreview(applicationId),
      fromJson: (json) => json as Map<String, dynamic>,
    );
    if (!response.isSuccess || response.data == null) return null;
    return response.data!['download_url'] as String? ?? response.data!['url'] as String?;
  }

  Future<CvMetadataModel?> getSavedCv() async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return _mockSavedCv;
    }
    final response = await _api.get<CvMetadataModel?>(
      ApiEndpoints.usersMeCv,
      fromJson: (json) {
        if (json == null) return null;
        final data = json as Map<String, dynamic>;
        return CvMetadataModel(
          fileId: data['cv_file_id']?.toString() ?? data['file_id']?.toString() ?? '',
          fileName: data['file_name'] as String? ?? 'CV',
          mimeType: data['mime_type'] as String? ?? 'application/pdf',
          downloadUrl: data['download_url'] as String?,
        );
      },
    );
    if (!response.isSuccess) return null;
    return response.data;
  }

  Future<LocalCvFile?> pickLocalCv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: acceptedExtensions,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;
    if (file.path == null) return null;
    return LocalCvFile(
      path: file.path!,
      displayName: file.name,
      sizeBytes: file.size,
      mimeType: _mimeFromExtension(file.extension ?? ''),
    );
  }

  String? validateLocalFile(LocalCvFile file) {
    final ext = file.displayName.split('.').last.toLowerCase();
    if (!acceptedExtensions.contains(ext)) {
      return 'Accepted formats: PDF, DOC, or DOCX';
    }
    if (!acceptedMimeTypes.contains(file.mimeType)) {
      return 'Unsupported file type';
    }
    if (file.sizeBytes <= 0) return 'File is empty';
    if (file.sizeBytes > maxBytes) return 'File must be 10 MB or smaller';
    if (!File(file.path).existsSync()) return 'File no longer available';
    return null;
  }

  Future<UploadedCvFile> uploadCv(LocalCvFile file) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      return UploadedCvFile(
        fileId: 'uploaded-${DateTime.now().millisecondsSinceEpoch}',
        fileName: file.displayName,
        mimeType: file.mimeType,
        sizeBytes: file.sizeBytes,
      );
    }
    return _uploadService.uploadCv(
      filePath: file.path,
      fileName: file.displayName,
      mimeType: file.mimeType,
    );
  }

  Future<void> setDefaultCv(String fileId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      _mockSavedCv = CvMetadataModel(
        fileId: fileId,
        fileName: 'Updated_CV.pdf',
        mimeType: 'application/pdf',
      );
      return;
    }
    final response = await _api.put<void>(
      ApiEndpoints.usersMeCv,
      data: {'cv_file_id': fileId},
      fromJson: (_) {},
    );
    if (!response.isSuccess) {
      throw CvRepositoryException(response.error?.message ?? 'Could not save default CV');
    }
  }

  String _mimeFromExtension(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }
}

class CvRepositoryException implements Exception {
  CvRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
