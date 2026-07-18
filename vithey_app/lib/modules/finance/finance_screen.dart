import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/app_screen_body.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/modules/finance/finance_controller.dart';
import 'package:aub_connect_app/modules/finance/widgets/finance_app_bar.dart';
import 'package:aub_connect_app/modules/finance/widgets/finance_balance_card.dart';
import 'package:aub_connect_app/modules/finance/widgets/finance_total_paycheck.dart';
import 'package:aub_connect_app/modules/finance/widgets/payment_receipts_section.dart';

class FinanceScreen extends GetView<FinanceController> {
  const FinanceScreen({super.key});

  static const _morphDuration = Duration(milliseconds: 420);

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

          final showAll = controller.showAll.value;

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cards stay above the list; only the transaction list scrolls.
                TweenAnimationBuilder<double>(
                  duration: _morphDuration,
                  curve: Curves.easeInOutCubic,
                  tween: Tween<double>(end: showAll ? 0.0 : 1.0),
                  builder: (context, t, child) {
                    final factor = t.clamp(0.0, 1.0);
                    return ClipRect(
                      child: Align(
                        alignment: Alignment.topCenter,
                        heightFactor: factor,
                        child: Opacity(
                          opacity: Curves.easeOut.transform(factor),
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FinanceBalanceCard(
                        dashboard: data,
                        onPayNow: controller.payNow,
                      ),
                      const SizedBox(height: 12),
                      FinanceTotalPaycheck(amount: data.totalPaycheck),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                Expanded(
                  child: PaymentReceiptsSection(
                    payments: controller.visiblePayments,
                    showAll: showAll,
                    onToggleShowAll: controller.toggleShowAll,
                    onPaymentTap: controller.openPaymentDetail,
                    onRefresh: controller.refreshFinance,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
