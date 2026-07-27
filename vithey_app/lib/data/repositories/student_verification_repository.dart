import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/data/models/student_verification_model.dart';
import 'package:aub_connect_app/data/services/student_verification_service.dart';
import 'package:get/get.dart';

class StudentVerificationRepository {
  StudentVerificationRepository(this._service, this._localStorage, this._flags) {
    // Sync once so Home AppBar / Profile see the latest mock status.
    refreshVerifiedFlag();
  }

  final StudentVerificationService _service;
  final LocalStorageService _localStorage;
  final FeatureFlags _flags;

  /// True only while status is [VerificationStatus.verified].
  /// Home finance icon and profile "Review verify" label observe this.
  final isVerified = false.obs;

  bool get useMockApi => _flags.useMockApi;

  Future<void> refreshVerifiedFlag() async {
    final current = await getMyVerification();
    _publishVerified(current.status);
  }

  void _publishVerified(VerificationStatus status) {
    isVerified.value = status == VerificationStatus.verified;
  }

  Future<StudentVerificationModel> getMyVerification() async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      final model = await _readMockVerification();
      _publishVerified(model.status);
      return model;
    }
    const model =
        StudentVerificationModel(status: VerificationStatus.notSubmitted);
    _publishVerified(model.status);
    return model;
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
      final normalizedDoc = documentFileName?.trim();
      final hasDocument = normalizedDoc != null && normalizedDoc.isNotEmpty;
      // Reset outcome every submit — always re-check after pending delay.
      await _localStorage.saveVerificationStatus('pending');
      await _localStorage.saveVerificationDraft(
        studentId: studentId,
        universityEmail: universityEmail,
        submittedAtIso: now.toIso8601String(),
        documentFileName: hasDocument ? normalizedDoc : null,
      );
      // Pending / fail clears finance access until success resolves.
      _publishVerified(VerificationStatus.pending);
      return StudentVerificationModel(
        id: 'ver-mock-1',
        status: VerificationStatus.pending,
        studentId: studentId,
        universityEmail: universityEmail,
        submittedAt: now,
        documentFileName: hasDocument ? normalizedDoc : null,
      );
    }
    await _service.submitVerification(
      studentId: studentId,
      universityEmail: universityEmail,
    );
    final model = StudentVerificationModel(
      status: VerificationStatus.verified,
      studentId: studentId,
      universityEmail: universityEmail,
      verifiedAt: DateTime.now(),
    );
    _publishVerified(model.status);
    return model;
  }

  Future<void> clearStoredDocument() => _localStorage.clearVerificationDocument();

  /// Mock: after pending review delay —
  /// document present → verified success; no document → rejected (fail).
  Future<StudentVerificationModel> resolveMockPendingOutcome() async {
    final current = await _readMockVerification();
    if (current.status != VerificationStatus.pending) return current;

    final hasDocument = current.documentFileName != null &&
        current.documentFileName!.trim().isNotEmpty;

    if (hasDocument) {
      await _localStorage.saveVerificationStatus('verified');
      final verified = current.copyWith(
        status: VerificationStatus.verified,
        verifiedAt: DateTime.now(),
        canResubmit: false,
      );
      _publishVerified(VerificationStatus.verified);
      return verified;
    }

    await _localStorage.saveVerificationStatus('rejected');
    final rejected = current.copyWith(
      status: VerificationStatus.rejected,
      rejectionReason:
          'Verification failed. Please upload your student document and try again.',
      canResubmit: true,
    );
    _publishVerified(VerificationStatus.rejected);
    return rejected;
  }

  Future<StudentVerificationModel> refreshForMockApproval() =>
      resolveMockPendingOutcome();

  String? validateStudentId(String value) {
    if (value.trim().isEmpty) return 'Student ID is required';
    return null;
  }

  String? validateUniversityEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Student email is required';
    return null;
  }

  Future<StudentVerificationModel> _readMockVerification() async {
    final statusRaw = await _localStorage.readVerificationStatus();
    // No saved status yet → treat as not submitted so Verify opens the form.
    if (statusRaw == null || statusRaw.isEmpty) {
      return const StudentVerificationModel(
        status: VerificationStatus.notSubmitted,
      );
    }
    final draft = await _localStorage.readVerificationDraft();
    final status = _parseStatus(statusRaw);
    return StudentVerificationModel(
      id: status == VerificationStatus.notSubmitted ? null : 'ver-mock-1',
      status: status,
      studentId: draft['studentId'],
      universityEmail: draft['universityEmail'],
      submittedAt: draft['submittedAt'] != null
          ? DateTime.tryParse(draft['submittedAt']!)
          : null,
      verifiedAt: status == VerificationStatus.verified ? DateTime.now() : null,
      documentFileName: draft['documentFileName'],
      rejectionReason: status == VerificationStatus.rejected
          ? 'Document was unreadable. Please resubmit.'
          : null,
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
