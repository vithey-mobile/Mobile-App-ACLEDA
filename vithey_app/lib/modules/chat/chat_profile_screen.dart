import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/chat_args.dart';
import 'package:aub_connect_app/data/models/chat_participant.dart';
import 'package:aub_connect_app/data/repositories/chat_repository.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class ChatProfileController extends GetxController {
  ChatProfileController(this._chatRepository);

  final ChatRepository _chatRepository;

  final participant = Rxn<ChatParticipant>();
  final isLoading = true.obs;
  final selectedTab = 0.obs;

  String? _conversationId;
  String? _participantId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as ChatProfileArgs;
    _conversationId = args.conversationId;
    _participantId = args.participantId;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    isLoading.value = true;
    try {
      participant.value = await _chatRepository.getParticipant(
        conversationId: _conversationId!,
        participantId: _participantId!,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void openMessage() => Get.back();

  Future<void> blockUser() async {
    if (_conversationId == null) return;
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Block this user?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Get.back(result: true), child: const Text('Block')),
        ],
      ),
    );
    if (confirmed != true) return;
    await _chatRepository.blockConversation(_conversationId!);
    Get.close(2);
    Get.snackbar(AppStrings.appName, 'User blocked');
  }

  Future<void> reportUser() async {
    if (_participantId == null) return;
    final reasonController = TextEditingController();
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Report user'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(hintText: 'Reason for report'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Get.back(result: true), child: const Text('Report')),
        ],
      ),
    );
    if (confirmed != true) return;
    await _chatRepository.reportUser(_participantId!, reasonController.text.trim());
    reasonController.dispose();
    Get.snackbar(AppStrings.appName, 'Report submitted');
  }
}

class ChatProfileScreen extends GetView<ChatProfileController> {
  const ChatProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'block':
                  controller.blockUser();
                case 'report':
                  controller.reportUser();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'block', child: Text('Block')),
              PopupMenuItem(value: 'report', child: Text('Report')),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingWidget();
        final p = controller.participant.value;
        if (p == null) {
          return const Center(child: Text('Participant unavailable'));
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Stack(
                children: [
                  UserAvatar(name: p.fullName, imageUrl: p.avatarUrl, radius: 48),
                  if (p.isOnline)
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(p.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            Center(
              child: Text(
                p.isOnline ? 'Active now' : 'Offline',
                style: TextStyle(color: context.appColors.muted),
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(label: 'Message', icon: Icons.chat_bubble_outline, onPressed: controller.openMessage),
            const SizedBox(height: 20),
            if (p.bio != null || p.location != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.appColors.inputFill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (p.bio != null) Text(p.bio!),
                    if (p.location != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 16, color: context.appColors.muted),
                          const SizedBox(width: 4),
                          Text(p.location!, style: TextStyle(color: context.appColors.muted)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 24),
            const EmptyStateWidget(
              title: 'No shared media yet',
              subtitle: 'Images, videos, and files will appear here when supported',
            ),
          ],
        );
      }),
    );
  }
}
