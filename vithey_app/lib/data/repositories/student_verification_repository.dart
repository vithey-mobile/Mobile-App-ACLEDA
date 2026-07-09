import 'package:get/get.dart';
import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/data/models/student_verification_model.dart';
import 'package:aub_connect_app/data/services/student_verification_service.dart';

class StudentVerificationRepository {
  StudentVerificationRepository(this._service, this._localStorage, this._flags);

  final StudentVerificationService _service;
  final LocalStorageService _localStorage;
  final FeatureFlags _flags;

  bool get useMockApi => _flags.useMockApi;

  static const _allowedDomains = ['aub.edu.kh', 'student.aub.edu.kh'];

  Future<StudentVerificationModel> getMyVerification() async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      return _readMockVerification();
    }
    return const StudentVerificationModel(status: VerificationStatus.notSubmitted);
  }

  Future<StudentVerificationModel> submitVerification({
    required String studentId,
    required String universityEmail,
    String? documentFileName,
    String? documentPath,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      final now = DateTime.now();
      await _localStorage.saveVerificationStatus('pending');
      await _localStorage.saveVerificationDraft(
        studentId: studentId,
        universityEmail: universityEmail,
        submittedAtIso: now.toIso8601String(),
      );
      return StudentVerificationModel(
        id: 'ver-mock-1',
        status: VerificationStatus.pending,
        studentId: studentId,
        universityEmail: universityEmail,
        submittedAt: now,
        documentFileName: documentFileName,
      );
    }
    await _service.submitVerification(studentId: studentId, universityEmail: universityEmail);
    return StudentVerificationModel(
      status: VerificationStatus.verified,
      studentId: studentId,
      universityEmail: universityEmail,
      verifiedAt: DateTime.now(),
    );
  }

  Future<StudentVerificationModel> refreshForMockApproval() async {
    final current = await _readMockVerification();
    if (current.status == VerificationStatus.pending) {
      await _localStorage.saveVerificationStatus('verified');
      return current.copyWith(status: VerificationStatus.verified, verifiedAt: DateTime.now());
    }
    return current;
  }

  String? validateStudentId(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Student ID is required';
    if (trimmed.length < 4) return 'Enter a valid student ID';
    return null;
  }

  String? validateUniversityEmail(String value) {
    final trimmed = value.trim().toLowerCase();
    if (trimmed.isEmpty) return 'Student email is required';
    final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailPattern.hasMatch(trimmed)) return 'Enter a valid email address';
    final domain = trimmed.split('@').last;
    if (!_allowedDomains.contains(domain)) {
      return 'Use your approved university email domain';
    }
    return null;
  }

  Future<StudentVerificationModel> _readMockVerification() async {
    final statusRaw = await _localStorage.readVerificationStatus();
    final draft = await _localStorage.readVerificationDraft();
    final status = _parseStatus(statusRaw);
    return StudentVerificationModel(
      id: status == VerificationStatus.notSubmitted ? null : 'ver-mock-1',
      status: status,
      studentId: draft['studentId'],
      universityEmail: draft['universityEmail'],
      submittedAt: draft['submittedAt'] != null ? DateTime.tryParse(draft['submittedAt']!) : null,
      verifiedAt: status == VerificationStatus.verified ? DateTime.now() : null,
      documentFileName: status == VerificationStatus.notSubmitted ? null : 'student_id.pdf',
      rejectionReason: status == VerificationStatus.rejected ? 'Document was unreadable. Please resubmit.' : null,
      canResubmit: status != VerificationStatus.pending,
    );
  }

  VerificationStatus _parseStatus(String? raw) {
    switch (raw) {
      case 'pending':
        return VerificationStatus.pending;
      case 'verified':
        return VerificationStatus.verified;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.notSubmitted;
    }
  }
}

class FinanceNavigation {
  FinanceNavigation._();

  static Future<void> openFinanceEntry() async {
    final repo = Get.find<StudentVerificationRepository>();
    final verification = await repo.getMyVerification();
    switch (verification.status) {
      case VerificationStatus.notSubmitted:
        Get.toNamed(AppRoutes.studentVerification);
      case VerificationStatus.pending:
      case VerificationStatus.rejected:
        Get.toNamed(AppRoutes.verificationStatus);
      case VerificationStatus.verified:
        Get.toNamed(AppRoutes.finance);
    }
  }
}
