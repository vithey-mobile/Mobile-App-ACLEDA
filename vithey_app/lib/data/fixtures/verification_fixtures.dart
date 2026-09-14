import 'package:aub_connect_app/core/constants/mock_identities.dart';
import 'package:aub_connect_app/data/fixtures/mock_clock.dart';
import 'package:aub_connect_app/data/fixtures/mock_ids.dart';
import 'package:aub_connect_app/data/models/student_verification_model.dart';

abstract final class VerificationFixtures {
  static StudentVerificationModel demoVerified() {
    return StudentVerificationModel(
      id: MockIds.verification,
      status: VerificationStatus.verified,
      studentId: 'AUB2024001',
      universityEmail: MockIdentities.mockUserEmail,
      submittedAt: MockClock.daysAgo(14),
      verifiedAt: MockClock.daysAgo(10),
      documentFileName: 'student_id.pdf',
    );
  }

  static StudentVerificationModel demoPending() {
    return StudentVerificationModel(
      id: MockIds.verification,
      status: VerificationStatus.pending,
      studentId: 'AUB2024001',
      universityEmail: MockIdentities.mockUserEmail,
      submittedAt: MockClock.daysAgo(2),
      documentFileName: 'student_id.pdf',
    );
  }

  static StudentVerificationModel demoRejected() {
    return StudentVerificationModel(
      id: MockIds.verification,
      status: VerificationStatus.rejected,
      studentId: 'AUB2024001',
      universityEmail: MockIdentities.mockUserEmail,
      submittedAt: MockClock.daysAgo(5),
      documentFileName: 'student_id.pdf',
      rejectionReason: 'Document was unreadable. Please resubmit.',
      canResubmit: true,
    );
  }
}
