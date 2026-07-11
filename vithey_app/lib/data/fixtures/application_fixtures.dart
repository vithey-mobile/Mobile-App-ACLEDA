import 'package:aub_connect_app/data/fixtures/mock_clock.dart';
import 'package:aub_connect_app/data/fixtures/mock_ids.dart';
import 'package:aub_connect_app/data/models/applicant_detail_model.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/modules/apply_cv/models/application_detail_model.dart';

abstract final class ApplicationFixtures {
  static Set<String> seedAppliedJobPostIds() => {MockIds.post3, MockIds.post4};

  static Map<String, ApplicationDetailModel> buildApplicationDetails() {
    return {
      MockIds.app1: ApplicationDetailModel(
        applicationId: MockIds.app1,
        jobPostId: MockIds.post3,
        jobTitle: 'Multiple position · Aeon Mall',
        organization: 'Aeon Mall',
        status: ApplicationStatus.pending,
        appliedAt: MockClock.daysAgo(1),
        cvFileName: 'Heng_Liza_CV.pdf',
        applicantUserId: MockIds.author1,
        applicantName: 'Heng Liza',
      ),
      MockIds.app2: ApplicationDetailModel(
        applicationId: MockIds.app2,
        jobPostId: MockIds.post3,
        jobTitle: 'Multiple position · Aeon Mall',
        organization: 'Aeon Mall',
        status: ApplicationStatus.reviewed,
        appliedAt: MockClock.daysAgo(2),
        reviewStartedAt: MockClock.daysAgo(1),
        cvFileName: 'Chan_Dara_CV.pdf',
        applicantUserId: MockIds.author2,
        applicantName: 'Molika Khorn',
      ),
      MockIds.appMy1: ApplicationDetailModel(
        applicationId: MockIds.appMy1,
        jobPostId: MockIds.post4,
        jobTitle: 'Marketing Intern',
        organization: 'Global Tech Solutions',
        status: ApplicationStatus.pending,
        appliedAt: MockClock.daysAgo(3),
        cvFileName: 'Khorn_Molika_CV.pdf',
      ),
      MockIds.appMy2: ApplicationDetailModel(
        applicationId: MockIds.appMy2,
        jobPostId: MockIds.post3,
        jobTitle: 'Multiple position · Aeon Mall',
        organization: 'Aeon Mall',
        status: ApplicationStatus.reviewed,
        appliedAt: MockClock.daysAgo(5),
        reviewStartedAt: MockClock.daysAgo(4),
        cvFileName: 'Khorn_Molika_CV.pdf',
      ),
    };
  }

  static List<JobApplicationModel> defaultApplicants() {
    return [
      JobApplicationModel(
        id: MockIds.app1,
        jobPostId: MockIds.post3,
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
        jobPostId: MockIds.post3,
        applicantName: 'Molika Khorn',
        applicantUserId: MockIds.author2,
        headline: 'Marketing Major',
        location: 'Phnom Penh',
        email: 'molika@example.com',
        appliedAt: MockClock.daysAgo(2),
        cvFileName: 'Molika_Khorn_CV.pdf',
        status: ApplicationStatus.reviewed,
        rank: 2,
      ),
    ];
  }

  static Map<String, List<JobApplicationModel>> buildApplicantsByJob() {
    return {MockIds.post3: defaultApplicants()};
  }

  static List<AppliedJobSummary> myAppliedJobs() {
    return [
      AppliedJobSummary(
        id: MockIds.appMy1,
        jobPostId: MockIds.post4,
        jobTitle: 'Marketing Intern',
        company: 'Global Tech Solutions',
        status: ApplicationStatus.pending,
        appliedAt: MockClock.daysAgo(3),
      ),
      AppliedJobSummary(
        id: MockIds.appMy2,
        jobPostId: MockIds.post3,
        jobTitle: 'Multiple position · Aeon Mall',
        company: 'Aeon Mall',
        status: ApplicationStatus.reviewed,
        appliedAt: MockClock.daysAgo(5),
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
              'Led cross-functional product initiatives and mentored junior developers on campus hiring programs.',
        ),
        ApplicantExperienceEntry(
          title: 'Senior Product Designer',
          organization: 'FinStream Group',
          period: '2018 - 2021',
          description: 'Designed mobile banking experiences and collaborated with engineering on Flutter prototypes.',
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
          degree: 'B.S. Web Development',
          school: 'American University of Phnom Penh',
          period: '2018 - 2022',
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
