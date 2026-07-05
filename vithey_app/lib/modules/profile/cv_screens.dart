import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/data/models/profile_args.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/data/repositories/profile_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class PreviewOwnCvScreen extends StatefulWidget {
  const PreviewOwnCvScreen({super.key});

  @override
  State<PreviewOwnCvScreen> createState() => _PreviewOwnCvScreenState();
}

class _PreviewOwnCvScreenState extends State<PreviewOwnCvScreen> {
  CvMetadataModel? _cv;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cv = await Get.find<ProfileRepository>().getOwnCv();
    setState(() {
      _cv = cv;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_cv?.fileName ?? 'Preview CV'),
        actions: [
          if (_cv?.downloadUrl != null)
            IconButton(
              icon: const Icon(Icons.download_outlined),
              onPressed: () => launchUrl(Uri.parse(_cv!.downloadUrl!), mode: LaunchMode.externalApplication),
            ),
        ],
      ),
      body: _loading
          ? const LoadingWidget()
          : _cv == null
              ? const EmptyStateWidget(
                  title: 'No CV uploaded yet',
                  subtitle: 'Upload your CV from the upload flow',
                  actionLabel: 'Upload CV',
                )
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.picture_as_pdf, size: 64, color: AppColors.primary),
                      const SizedBox(height: 16),
                      Text(_cv!.fileName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Type: ${_cv!.mimeType}'),
                      const Spacer(),
                      CustomButton(
                        label: 'Open CV',
                        onPressed: () => launchUrl(Uri.parse(_cv!.downloadUrl!), mode: LaunchMode.externalApplication),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class ApplicantCvScreen extends GetView<ApplicantCvController> {
  const ApplicantCvScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as ApplicantCvArgs?;
    return Scaffold(
      appBar: AppBar(title: const Text('View CV')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(args?.applicantName ?? 'Applicant', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(args?.cvFileName ?? 'CV document'),
            const SizedBox(height: 24),
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.picture_as_pdf, size: 72, color: AppColors.primary),
                    SizedBox(height: 12),
                    Text('Secure CV preview placeholder'),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.decline,
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.accept,
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ApplicantCvController extends GetxController {
  ApplicantCvController(this._repository);

  final ProfileRepository _repository;
  String? _applicationId;

  @override
  void onInit() {
    super.onInit();
    _applicationId = (Get.arguments as ApplicantCvArgs?)?.applicationId;
  }

  Future<void> accept() async {
    if (_applicationId == null) return;
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Accept this application?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Get.back(result: true), child: const Text('Accept')),
        ],
      ),
    );
    if (confirmed != true) return;
    await _repository.updateApplicationStatus(_applicationId!, ApplicationStatus.accepted);
    Get.back();
    Get.snackbar('Vithey', 'Application accepted');
  }

  Future<void> decline() async {
    if (_applicationId == null) return;
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Decline this application?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Get.back(result: true), child: const Text('Decline')),
        ],
      ),
    );
    if (confirmed != true) return;
    await _repository.updateApplicationStatus(_applicationId!, ApplicationStatus.rejected);
    Get.back();
    Get.snackbar('Vithey', 'Application declined');
  }
}

class ApplicantCvBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ApplicantCvController(Get.find<ProfileRepository>()));
  }
}
