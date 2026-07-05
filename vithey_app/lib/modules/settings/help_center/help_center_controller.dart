import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class FaqCategory {
  const FaqCategory({required this.id, required this.title, required this.topics});

  final String id;
  final String title;
  final List<String> topics;
}

class HelpCenterController extends GetxController {
  final query = ''.obs;

  static const categories = <FaqCategory>[
    FaqCategory(id: 'account', title: 'Account & Login', topics: ['Reset password', 'Update email', 'Logout']),
    FaqCategory(id: 'verification', title: 'Student Verification', topics: ['Accepted documents', 'Pending status']),
    FaqCategory(id: 'finance', title: 'Finance', topics: ['Payment alerts', 'Invoice detail']),
    FaqCategory(id: 'jobs', title: 'Jobs & CV', topics: ['Upload CV', 'Apply to job', 'Applicant review']),
    FaqCategory(id: 'chat', title: 'Chat & Safety', topics: ['Message requests', 'Block/report']),
    FaqCategory(id: 'ai', title: 'AI Assistant', topics: ['Topics', 'Privacy', 'Unavailable provider']),
  ];

  List<FaqCategory> get filteredCategories {
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return categories;
    return categories
        .where((c) =>
            c.title.toLowerCase().contains(q) || c.topics.any((t) => t.toLowerCase().contains(q)))
        .toList();
  }

  void openFaqCategory(String categoryId) {
    final category = categories.firstWhereOrNull((c) => c.id == categoryId);
    if (category == null) return;

    Get.bottomSheet(
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...category.topics.map((t) => ListTile(title: Text(t), dense: true)),
            ],
          ),
        ),
      ),
      backgroundColor: Get.theme.cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    );
  }

  Future<void> contactSupport() async {
    final uri = Uri(scheme: 'mailto', path: 'support@vithey.app', query: 'subject=Vithey%20App%20Support');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Vithey', 'Email support: support@vithey.app');
    }
  }
}
