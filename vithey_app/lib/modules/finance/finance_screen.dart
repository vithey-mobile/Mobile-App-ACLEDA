import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/app_screen_body.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/modules/finance/finance_controller.dart';
import 'package:aub_connect_app/modules/finance/widgets/finance_app_bar.dart';
import 'package:aub_connect_app/modules/finance/widgets/finance_summary_card.dart';
import 'package:aub_connect_app/modules/finance/widgets/payment_receipts_section.dart';
import 'package:aub_connect_app/modules/home/widgets/home_bottom_navigation.dart';

class FinanceScreen extends GetView<FinanceController> {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FinanceAppBar(),
      body: AppScreenBody(
        child: Obx(() {
        if (controller.isLoading.value) return const LoadingWidget();
        if (controller.hasError.value) {
          return AppErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.loadFinanceHome,
          );
        }

        final data = controller.dashboard.value;
        if (data == null) return const LoadingWidget();

        return RefreshIndicator(
          onRefresh: controller.refreshFinance,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              FinanceSummaryCard(dashboard: data),
              const SizedBox(height: 20),
              PaymentReceiptsSection(
                payments: controller.visiblePayments,
                showAll: controller.showAll.value,
                onToggleShowAll: controller.toggleShowAll,
                onPaymentTap: controller.openPaymentDetail,
              ),
            ],
          ),
        );
      }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.onTabSelected(2),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Obx(
        () => HomeBottomNavigation(
          currentIndex: controller.currentTab.value,
          onTap: controller.onTabSelected,
        ),
      ),
    );
  }
}
