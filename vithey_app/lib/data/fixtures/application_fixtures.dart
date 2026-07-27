import 'package:aub_connect_app/core/constants/app_assets.dart';
import 'package:aub_connect_app/core/constants/mock_identities.dart';
import 'package:aub_connect_app/data/fixtures/mock_clock.dart';
import 'package:aub_connect_app/data/fixtures/mock_ids.dart';
import 'package:aub_connect_app/data/models/applicant_detail_model.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/modules/apply_cv/models/application_detail_model.dart';

/// Mock job-application usage (no role picker ΓÇö usage-shaped):
/// - Logged-in user = **Poster (HR)**: owns JOB posts; Applied Jobs has **4**
///   mock rows in dev so the tab UI can be exercised.
/// - `author-1` = **Applier (Student)**: applies to jobs; has no JOB posts.
abstract final class ApplicationFixtures {
  static String get _ownCvFileName =>
      '${MockIdentities.mockUserFullName.replaceAll(' ', '_')}_CV.pdf';

  /// Logged-in mock has applied to these job posts (feed Apply state).
  /// `post-10` is intentionally omitted so Apply CV wizard can be demoed.
  static Set<String> seedAppliedJobPostIds() => {
        MockIds.post3,
        MockIds.post4,
      };

  static Map<String, ApplicationDetailModel> buildApplicationDetails() {
    return {
      MockIds.app1: ApplicationDetailModel(
        applicationId: MockIds.app1,
        jobPostId: MockIds.post7,
        jobTitle: 'Call Center Officer',
        organization: 'LOLC (Cambodia) Plc.',
        status: ApplicationStatus.pending,
        appliedAt: MockClock.daysAgo(1),
        cvFileName: 'Heng_Liza_CV.pdf',
        applicantUserId: MockIds.author1,
        applicantName: 'Heng Liza',
        applicantHeadline: 'Web Developer',
        applicantLocation: 'Pur Senchey, Phnom Penh',
        applicantEmail: 'hengliza81@gmail.com',
      ),
      MockIds.app2: ApplicationDetailModel(
        applicationId: MockIds.app2,
        jobPostId: MockIds.post7,
        jobTitle: 'Call Center Officer',
        organization: 'LOLC (Cambodia) Plc.',
        status: ApplicationStatus.reviewed,
        appliedAt: MockClock.daysAgo(2),
        reviewStartedAt: MockClock.daysAgo(1),
        cvFileName: 'Sreynich_Chan_CV.pdf',
        applicantUserId: MockIds.author4,
        applicantName: 'Sreynich Chan',
        applicantHeadline: 'Business student',
        applicantLocation: 'Phnom Penh',
        applicantEmail: 'sreynich@example.com',
      ),
      MockIds.appMy1: ApplicationDetailModel(
        applicationId: MockIds.appMy1,
        jobPostId: MockIds.post9,
        jobTitle: 'Marketing Intern',
        organization: 'KDSB',
        status: ApplicationStatus.pending,
        appliedAt: MockClock.daysAgo(3),
        cvFileName: 'Heng_Liza_CV.pdf',
        applicantUserId: MockIds.author1,
        applicantName: 'Heng Liza',
      ),
      MockIds.appMy2: ApplicationDetailModel(
        applicationId: MockIds.appMy2,
        jobPostId: MockIds.post8,
        jobTitle: 'Young Talent, Finance',
        organization: 'Chip Mong Group',
        status: ApplicationStatus.reviewed,
        appliedAt: MockClock.daysAgo(5),
        reviewStartedAt: MockClock.daysAgo(4),
        cvFileName: 'Heng_Liza_CV.pdf',
        applicantUserId: MockIds.author1,
        applicantName: 'Heng Liza',
      ),
      // Logged-in user's Applied Jobs (dev mocks) ΓÇö original uploaded CV name.
      MockIds.appMy3: ApplicationDetailModel(
        applicationId: MockIds.appMy3,
        jobPostId: MockIds.post3,
        jobTitle: 'Web Developer',
        organization: 'Aeon Mall',
        status: ApplicationStatus.pending,
        appliedAt: MockClock.hoursAgo(20),
        cvFileName: _ownCvFileName,
        applicantUserId: MockIds.currentUser,
        applicantName: MockIdentities.mockUserFullName,
      ),
      MockIds.appMy4: ApplicationDetailModel(
        applicationId: MockIds.appMy4,
        jobPostId: MockIds.post4,
        jobTitle: 'Sales (Credit Officer) Intern',
        organization: 'KDSB',
        status: ApplicationStatus.reviewed,
        appliedAt: MockClock.daysAgo(1),
        reviewStartedAt: MockClock.hoursAgo(12),
        cvFileName: _ownCvFileName,
        applicantUserId: MockIds.currentUser,
        applicantName: MockIdentities.mockUserFullName,
      ),
      MockIds.appMy5: ApplicationDetailModel(
        applicationId: MockIds.appMy5,
        jobPostId: MockIds.post3,
        jobTitle: 'Young Talent, Finance',
        organization: 'Chip Mong Group',
        status: ApplicationStatus.accepted,
        appliedAt: MockClock.daysAgo(10),
        reviewStartedAt: MockClock.daysAgo(8),
        decidedAt: MockClock.daysAgo(6),
        reviewerNote:
            'Thank you for your interest. Please check your email to receive interview time and location.',
        cvFileName: _ownCvFileName,
        applicantUserId: MockIds.currentUser,
        applicantName: MockIdentities.mockUserFullName,
      ),
      MockIds.appMy6: ApplicationDetailModel(
        applicationId: MockIds.appMy6,
        jobPostId: MockIds.post4,
        jobTitle: 'Marketing Intern',
        organization: 'Global Tech Solutions',
        status: ApplicationStatus.rejected,
        appliedAt: MockClock.daysAgo(14),
        reviewStartedAt: MockClock.daysAgo(12),
        decidedAt: MockClock.daysAgo(9),
        reviewerNote:
            "Thank you for your interest. I'm so sorry to inform you didn't pass our selection. However, we openly welcome you again next time.",
        cvFileName: _ownCvFileName,
        applicantUserId: MockIds.currentUser,
        applicantName: MockIdentities.mockUserFullName,
      ),
    };
  }

  static List<JobApplicationModel> defaultApplicants() {
    return [
      JobApplicationModel(
        id: MockIds.app1,
        jobPostId: MockIds.post7,
        applicantName: 'Heng Liza',
        applicantUserId: MockIds.author1,
        headline: 'Web Developer',
        location: 'Pur Senchey, Phnom Penh',
        email: 'hengliza81@gmail.com',
        appliedAt: MockClock.daysAgo(1),
        cvFileName: 'Heng_Liza_CV.pdf',
        rank: 1,
      ),
      JobApplicationModel(
        id: MockIds.app2,
        jobPostId: MockIds.post7,
        applicantName: 'Sreynich Chan',
        applicantUserId: MockIds.author4,
        headline: 'Business student',
        location: 'Phnom Penh',
        email: 'sreynich@example.com',
        appliedAt: MockClock.daysAgo(2),
        cvFileName: 'Sreynich_Chan_CV.pdf',
        status: ApplicationStatus.reviewed,
        rank: 2,
      ),
    ];
  }

  /// Applicants on Poster-owned jobs (and optional other listings).
  static Map<String, List<JobApplicationModel>> buildApplicantsByJob() {
    final onCallCenter = defaultApplicants();
    final onFinance = [
      JobApplicationModel(
        id: MockIds.appMy2,
        jobPostId: MockIds.post8,
        applicantName: 'Heng Liza',
        applicantUserId: MockIds.author1,
        headline: 'Web Developer',
        location: 'Pur Senchey, Phnom Penh',
        email: 'hengliza81@gmail.com',
        appliedAt: MockClock.daysAgo(5),
        cvFileName: 'Heng_Liza_CV.pdf',
        status: ApplicationStatus.reviewed,
        rank: 1,
      ),
    ];
    final onMarketing = [
      JobApplicationModel(
        id: MockIds.appMy1,
        jobPostId: MockIds.post9,
        applicantName: 'Heng Liza',
        applicantUserId: MockIds.author1,
        headline: 'Web Developer',
        location: 'Pur Senchey, Phnom Penh',
        email: 'hengliza81@gmail.com',
        appliedAt: MockClock.daysAgo(3),
        cvFileName: 'Heng_Liza_CV.pdf',
        rank: 1,
      ),
    ];
    return {
      MockIds.post7: onCallCenter,
      MockIds.post8: onFinance,
      MockIds.post9: onMarketing,
    };
  }

  /// Dev mock: 4 Applied Jobs covering all statuses for UI review.
  static List<AppliedJobSummary> myAppliedJobs() {
    return [
      AppliedJobSummary(
        id: MockIds.appMy3,
        jobPostId: MockIds.post3,
        jobTitle: 'Web Developer',
        company: 'Aeon Mall',
        employmentType: 'Full-time',
        location: 'Phnom Penh, 32nd Street, SMC',
        mediaUrl: AppAssets.jobPost1,
        status: ApplicationStatus.pending,
        appliedAt: MockClock.hoursAgo(20),
      ),
      AppliedJobSummary(
        id: MockIds.appMy4,
        jobPostId: MockIds.post4,
        jobTitle: 'Sales (Credit Officer) Intern',
        company: 'KDSB',
        employmentType: 'Internship',
        location: 'KDSB Branches & Head Office',
        mediaUrl: AppAssets.jobPost2,
        status: ApplicationStatus.reviewed,
        appliedAt: MockClock.daysAgo(1),
      ),
      AppliedJobSummary(
        id: MockIds.appMy5,
        jobPostId: MockIds.post3,
        jobTitle: 'Young Talent, Finance',
        company: 'Chip Mong Group',
        employmentType: 'Internship',
        location: 'Phnom Penh',
        mediaUrl: AppAssets.jobPost1,
        status: ApplicationStatus.accepted,
        appliedAt: MockClock.daysAgo(10),
      ),
      AppliedJobSummary(
        id: MockIds.appMy6,
        jobPostId: MockIds.post4,
        jobTitle: 'Marketing Intern',
        company: 'Global Tech Solutions',
        employmentType: 'Internship',
        location: 'Phnom Penh, 32nd Street, SMC',
        mediaUrl: AppAssets.jobPost3,
        status: ApplicationStatus.rejected,
        appliedAt: MockClock.daysAgo(14),
      ),
    ];
  }

  /// Applier (Student) sample history ΓÇö for future applier session demos.
  static List<AppliedJobSummary> applierAppliedJobs() {
    return [
      AppliedJobSummary(
        id: MockIds.appMy1,
        jobPostId: MockIds.post9,
        jobTitle: 'Marketing Intern',
        company: 'KDSB',
        status: ApplicationStatus.pending,
        appliedAt: MockClock.daysAgo(3),
      ),
      AppliedJobSummary(
        id: MockIds.appMy2,
        jobPostId: MockIds.post8,
        jobTitle: 'Young Talent, Finance',
        company: 'Chip Mong Group',
        status: ApplicationStatus.reviewed,
        appliedAt: MockClock.daysAgo(5),
      ),
      AppliedJobSummary(
        id: MockIds.app1,
        jobPostId: MockIds.post7,
        jobTitle: 'Call Center Officer',
        company: 'LOLC (Cambodia) Plc.',
        status: ApplicationStatus.pending,
        appliedAt: MockClock.daysAgo(1),
      ),
    ];
  }

  static List<ApplicantExperienceEntry> experienceFor(String userId) {
    if (userId == MockIds.author1) {
      return const [
        ApplicantExperienceEntry(
          title: 'Principal Strategist',
          organization: 'Global Tech Solutions',
          period: '2021 - Present',
          description:
              'Led cross-functional product initiatives and mentored junior developers on campus hiring programs. Built SaaS workflows that reduced operational churn.',
        ),
        ApplicantExperienceEntry(
          title: 'Senior Product Designer',
          organization: 'FinStream Group',
          period: '2015 - 2021',
          description:
              'Designed mobile banking experiences and collaborated with engineering on Flutter prototypes.',
        ),
      ];
    }
    return const [
      ApplicantExperienceEntry(
        title: 'Marketing Intern',
        organization: 'Aeon Mall',
        period: '2024 - Present',
        description: 'Supported campaign analytics and social content for youth-focused retail events.',
      ),
    ];
  }

  static List<ApplicantEducationEntry> educationFor(String userId) {
    if (userId == MockIds.author1) {
      return const [
        ApplicantEducationEntry(
          degree: 'BACII Certificate',
          school: 'Champuvorn High School',
          period: '2017 - 2023',
        ),
        ApplicantEducationEntry(
          degree: 'Computer Science and Engineering',
          school: 'Acleda University and Business',
          period: '2024 - Present',
        ),
      ];
    }
    return const [
      ApplicantEducationEntry(
        degree: 'B.A. Marketing',
        school: 'American University of Phnom Penh',
        period: '2022 - 2026',
      ),
    ];
  }
}
