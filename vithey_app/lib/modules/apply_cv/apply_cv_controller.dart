import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/data/models/cv_file_model.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/data/repositories/cv_repository.dart';
import 'package:aub_connect_app/data/repositories/job_application_repository.dart';
import 'package:aub_connect_app/modules/apply_cv/models/apply_cv_args.dart';
import 'package:aub_connect_app/modules/apply_cv/widgets/application_success_dialog.dart';

enum ApplyCvPhase {
  loadingJob,
  ready,
  uploadingCv,
  applying,
  success,
  error,
}

enum CvSelectionMode {
  none,
  saved,
  localApplicationOnly,
  localUpdateDefault,
}

class ApplyCvController extends GetxController {
  ApplyCvController(this._cvRepository, this._jobApplicationRepository);

  final CvRepository _cvRepository;
  final JobApplicationRepository _jobApplicationRepository;

  final phase = ApplyCvPhase.loadingJob.obs;
  final job = Rxn<FeedPost>();
  final eligibility = Rxn<JobEligibilityResult>();
  final savedCv = Rxn<CvMetadataModel>();
  final localCv = Rxn<LocalCvFile>();
  final selectionMode = CvSelectionMode.none.obs;
  final saveAsDefault = false.obs;
  final fileError = ''.obs;
  final submitError = ''.obs;
  final submitLabel = 'Submit'.obs;
  final isSubmitting = false.obs;

  final descriptionController = TextEditingController();

  String? _jobPostId;
  String? _uploadedFileId;
  bool _submitLocked = false;

  bool get canSubmit {
    if (phase.value != ApplyCvPhase.ready) return false;
    if (isSubmitting.value) return false;
    if (eligibility.value?.eligibility != JobEligibility.eligible) return false;
    if (!_hasValidCv) return false;
    return true;
  }

  bool get _hasValidCv {
    if (selectionMode.value == CvSelectionMode.saved && savedCv.value != null) return true;
    if (localCv.value != null && fileError.value.isEmpty) return true;
    return false;
  }

  String get acceptedPolicyLabel => 'PDF, DOC or DOCX (max. 10 MB)';

  @override
  void onInit() {
    super.onInit();
    final args = ApplyCvArgs.from(Get.arguments);
    _jobPostId = args.jobPostId;
    if (args.jobPreview != null) job.value = args.jobPreview;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    phase.value = ApplyCvPhase.loadingJob;
    submitError.value = '';
    try {
      final results = await Future.wait([
        _jobApplicationRepository.loadJobEligibility(_jobPostId!),
        _cvRepository.getSavedCv(),
      ]);
      final eligibilityResult = results[0] as JobEligibilityResult;
      final saved = results[1] as CvMetadataModel?;

      eligibility.value = eligibilityResult;
      job.value = eligibilityResult.job ?? job.value;
      savedCv.value = saved;

      if (eligibilityResult.eligibility == JobEligibility.eligible && saved != null) {
        selectionMode.value = CvSelectionMode.saved;
      }

      phase.value = ApplyCvPhase.ready;
    } catch (e) {
      phase.value = ApplyCvPhase.error;
      submitError.value = 'Could not load job details';
    }
  }

  Future<void> retryLoad() => _loadInitialData();

  Future<void> pickLocalCv({required bool updateDefault}) async {
    fileError.value = '';
    final picked = await _cvRepository.pickLocalCv();
    if (picked == null) return;

    final validationError = _cvRepository.validateLocalFile(picked);
    if (validationError != null) {
      fileError.value = validationError;
      localCv.value = picked;
      selectionMode.value = updateDefault ? CvSelectionMode.localUpdateDefault : CvSelectionMode.localApplicationOnly;
      return;
    }

    localCv.value = picked;
    selectionMode.value = updateDefault ? CvSelectionMode.localUpdateDefault : CvSelectionMode.localApplicationOnly;
    saveAsDefault.value = updateDefault;
  }

  void useSavedCv() {
    if (savedCv.value == null) return;
    localCv.value = null;
    fileError.value = '';
    selectionMode.value = CvSelectionMode.saved;
    saveAsDefault.value = false;
  }

  void clearCvSelection() {
    localCv.value = null;
    fileError.value = '';
    selectionMode.value = CvSelectionMode.none;
    saveAsDefault.value = false;
  }

  void removeLocalCv() {
    localCv.value = null;
    fileError.value = '';
    if (savedCv.value != null) {
      selectionMode.value = CvSelectionMode.saved;
    } else {
      selectionMode.value = CvSelectionMode.none;
    }
    saveAsDefault.value = false;
  }

  void toggleSaveAsDefault(bool value) => saveAsDefault.value = value;

  Future<void> submit() async {
    if (!canSubmit || _submitLocked || _jobPostId == null) return;
    _submitLocked = true;
    isSubmitting.value = true;
    submitError.value = '';

    try {
      final refreshed = await _jobApplicationRepository.loadJobEligibility(_jobPostId!);
      eligibility.value = refreshed;
      job.value = refreshed.job ?? job.value;
      if (refreshed.eligibility != JobEligibility.eligible) {
        submitError.value = refreshed.message ?? 'This job is no longer eligible';
        return;
      }

      String cvFileId;
      if (selectionMode.value == CvSelectionMode.saved) {
        cvFileId = savedCv.value!.fileId;
      } else {
        final local = localCv.value!;
        final validationError = _cvRepository.validateLocalFile(local);
        if (validationError != null) {
          fileError.value = validationError;
          return;
        }

        if (_uploadedFileId == null) {
          phase.value = ApplyCvPhase.uploadingCv;
          submitLabel.value = 'Uploading CV…';
          final uploaded = await _cvRepository.uploadCv(local);
          _uploadedFileId = uploaded.fileId;
        }
        cvFileId = _uploadedFileId!;

        if (saveAsDefault.value || selectionMode.value == CvSelectionMode.localUpdateDefault) {
          await _cvRepository.setDefaultCv(cvFileId);
          savedCv.value = CvMetadataModel(
            fileId: cvFileId,
            fileName: local.displayName,
            mimeType: local.mimeType,
          );
        }
      }

      phase.value = ApplyCvPhase.applying;
      submitLabel.value = 'Submitting application…';
      final note = descriptionController.text.trim();
      final result = await _jobApplicationRepository.submitApplication(
        jobPostId: _jobPostId!,
        cvFileId: cvFileId,
        applicationNote: note.isEmpty ? null : note,
      );

      phase.value = ApplyCvPhase.success;
      final title = job.value?.jobMeta.title ?? 'this role';
      await ApplicationSuccessDialog.show(jobTitle: title);
      Get.back(result: result);
    } catch (e) {
      phase.value = ApplyCvPhase.ready;
      submitError.value = e.toString();
    } finally {
      isSubmitting.value = false;
      submitLabel.value = 'Submit';
      _submitLocked = false;
    }
  }

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
  }
}
