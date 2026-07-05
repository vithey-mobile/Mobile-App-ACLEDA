import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/data/models/finance_dashboard_model.dart';
import 'package:aub_connect_app/data/models/profile_args.dart';
import 'package:aub_connect_app/data/models/student_verification_model.dart';
import 'package:aub_connect_app/data/repositories/finance_repository.dart';
import 'package:aub_connect_app/data/repositories/profile_repository.dart';
import 'package:aub_connect_app/data/repositories/student_verification_repository.dart';
import 'package:aub_connect_app/modules/finance/widgets/invoice_preview_sheet.dart';

class FinanceController extends GetxController {
  FinanceController(this._financeRepository, this._verificationRepository);

  final FinanceRepository _financeRepository;
  final StudentVerificationRepository _verificationRepository;

  final dashboard = Rxn<FinanceDashboard>();
  final isLoading = true.obs;
  final isRefreshing = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final showAll = false.obs;
  final currentTab = 1.obs;

  @override
  void onInit() {
    super.onInit();
    _guardAndLoad();
  }

  Future<void> _guardAndLoad() async {
    final verification = await _verificationRepository.getMyVerification();
    if (verification.status != VerificationStatus.verified) {
      final target = verification.status == VerificationStatus.notSubmitted
          ? AppRoutes.studentVerification
          : AppRoutes.verificationStatus;
      Get.offNamed(target);
      return;
    }
    await loadFinanceHome();
  }

  Future<void> loadFinanceHome() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      dashboard.value = await _financeRepository.getFinanceDashboard();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshFinance() async {
    isRefreshing.value = true;
    try {
      dashboard.value = await _financeRepository.getFinanceDashboard();
    } catch (e) {
      Get.snackbar(AppStrings.appName, 'Could not refresh finance data');
    } finally {
      isRefreshing.value = false;
    }
  }

  void toggleShowAll() => showAll.value = !showAll.value;

  List<PaymentSummary> get visiblePayments {
    final items = dashboard.value?.payments ?? [];
    if (showAll.value) return items;
    return items.take(4).toList();
  }

  Future<void> openPaymentDetail(String paymentId) async {
    try {
      final invoice = await _financeRepository.getPaymentInvoice(paymentId);
      await InvoicePreviewSheet.show(
        invoice: invoice,
        onDownload: () => downloadInvoice(paymentId),
      );
    } catch (e) {
      Get.snackbar(AppStrings.appName, 'Payment no longer available');
    }
  }

  Future<void> downloadInvoice(String paymentId) async {
    try {
      await _financeRepository.downloadInvoice(paymentId);
      Get.snackbar(AppStrings.appName, 'Invoice downloaded');
    } catch (e) {
      Get.snackbar(AppStrings.appName, 'Could not download invoice');
    }
  }

  void onTabSelected(int index) {
    currentTab.value = index;
    switch (index) {
      case 0:
        Get.offNamed(AppRoutes.home);
        break;
      case 1:
        break;
      case 2:
        Get.offNamed(AppRoutes.createPost);
        break;
      case 3:
        Get.offNamed(AppRoutes.chat);
        break;
      case 4:
        Get.offNamed(
          AppRoutes.profile,
          arguments: const ProfileArgs(userId: ProfileRepository.currentUserId),
        );
        break;
    }
  }
}
