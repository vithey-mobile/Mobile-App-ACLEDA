```json
vithey_app/
│
├── android/
├── ios/
├── web/
├── test/
│
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
|
├── lib/
│   ├── main.dart
│   ├── app.dart
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_strings.dart
│   │   │   ├── app_routes.dart
│   │   │   └── api_endpoints.dart
│   │   │
│   │   ├── theme/
│   │   │   ├── light_theme.dart
│   │   │   ├── dark_theme.dart
│   │   │   └── app_theme.dart
│   │   │
│   │   ├── network/
│   │   │   ├── dio_client.dart
│   │   │   ├── api_service.dart
│   │   │   └── api_response.dart
│   │   │
│   │   ├── storage/
│   │   │   ├── secure_storage_service.dart
│   │   │   └── local_storage_service.dart
│   │   │
│   │   ├── utils/
│   │   │   ├── validators.dart
│   │   │   ├── file_picker_helper.dart
│   │   │   ├── date_formatter.dart
│   │   │   └── permission_helper.dart
│   │   │
│   │   └── widgets/           # ← REUSABLE COMPONENTS
│   │
│   ├── data/
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── post_model.dart
│   │   │   ├── comment_model.dart
│   │   │   ├── cv_model.dart
│   │   │   ├── payment_model.dart
│   │   │   ├── chat_model.dart
│   │   │   ├── message_model.dart
│   │   │   └── notification_model.dart
│   │   │
│   │   ├── repositories/
│   │   │   ├── auth_repository.dart
│   │   │   ├── post_repository.dart
│   │   │   ├── profile_repository.dart
│   │   │   ├── cv_repository.dart
│   │   │   ├── finance_repository.dart
│   │   │   ├── chat_repository.dart
│   │   │   ├── chatbot_repository.dart
│   │   │   └── notification_repository.dart
│   │   │
│   │   └── services/
│   │       ├── auth_service.dart
│   │       ├── upload_service.dart
│   │       ├── payment_service.dart
│   │       ├── chat_service.dart
│   │       └── chatbot_service.dart
│   │       └── ...
│   │
│   ├── modules/
│   │   ├── splash/
│   │   │   ├── splash_screen.dart
│   │   │   ├── splash_controller.dart
│   │   │   └── splash_binding.dart
│   │   │
│   │   ├── onboarding/
│   │   │   ├── onboarding_screen.dart
│   │   │   ├── onboarding_controller.dart
│   │   │   ├── onboarding_binding.dart
│   │   │   └── widgets/
│   │   │       └── onboarding_slide.dart
│   │   │
│   │   ├── auth/
│   │   │   ├── auth_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   ├── auth_controller.dart
│   │   │   ├── auth_binding.dart
│   │   │   └── widgets/
│   │   │       ├── login_form.dart
│   │   │       └── register_form.dart
│   │   │       └── auth0_form.dart
│   │   │
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   ├── home_controller.dart
│   │   │   ├── home_binding.dart
│   │   │   └── widgets/
│   │   │       ├── post_card.dart
│   │   │       ├── video_post_card.dart
│   │   │       ├── poster_post_card.dart
│   │   │       └── job_post_card.dart
│   │   │
│   │   ├── create_post/
│   │   │   ├── create_post_screen.dart
│   │   │   ├── create_post_controller.dart
│   │   │   ├── create_post_binding.dart
│   │   │   └── widgets/
│   │   │       ├── post_type_selector.dart
│   │   │       ├── video_upload_box.dart
│   │   │       ├── poster_upload_box.dart
│   │   │       └── job_form.dart
│   │   │
│   │   ├── post_detail/
│   │   │   ├── post_detail_screen.dart
│   │   │   ├── post_detail_controller.dart
│   │   │   ├── post_detail_binding.dart
│   │   │   └── widgets/
│   │   │       ├── comment_list.dart
│   │   │       ├── comment_input.dart
│   │   │       └── mention_user_box.dart
│   │   │
│   │   ├── apply_cv/
│   │   │   ├── apply_cv_screen.dart
│   │   │   ├── apply_cv_controller.dart
│   │   │   ├── apply_cv_binding.dart
│   │   │   └── widgets/
│   │   │       ├── big_upload_icon.dart
│   │   │       ├── cv_file_preview.dart
│   │   │       └── submit_cv_button.dart
│   │   │
│   │   ├── profile/
│   │   │   ├── profile_screen.dart
│   │   │   ├── profile_controller.dart
│   │   │   ├── profile_binding.dart
│   │   │   └── widgets/
│   │   │       ├── profile_header.dart
│   │   │       ├── profile_tabs.dart
│   │   │       ├── user_info_tab.dart
│   │   │       ├── user_video_tab.dart
│   │   │       ├── user_poster_tab.dart
│   │   │       └── view_cv_icon.dart
│   │   │
│   │   ├── preview_cv/
│   │   │   ├── preview_cv_screen.dart
│   │   │   ├── preview_cv_controller.dart
│   │   │   ├── preview_cv_binding.dart
│   │   │   └── widgets/
│   │   │       ├── cv_preview_view.dart
│   │   │       ├── cv_download_button.dart
│   │   │       └── no_cv_widget.dart
│   │   │
│   │   ├── applicant_cv_preview/
│   │   │   ├── applicant_cv_preview_screen.dart
│   │   │   ├── applicant_cv_preview_controller.dart
│   │   │   ├── applicant_cv_preview_binding.dart
│   │   │   └── widgets/
│   │   │       ├── applicant_cv_card.dart
│   │   │       └── applicant_cv_viewer.dart
│   │   │
│   │   ├── finance/
│   │   │   ├── finance_screen.dart
│   │   │   ├── finance_controller.dart
│   │   │   ├── finance_binding.dart
│   │   │   └── widgets/
│   │   │       ├── payment_history_card.dart
│   │   │       ├── payment_status_badge.dart
│   │   │       └── payment_alert_card.dart
│   │   │
│   │   ├── student_verification/
│   │   │   ├── student_verification_screen.dart
│   │   │   ├── student_verification_controller.dart
│   │   │   ├── student_verification_binding.dart
│   │   │   └── widgets/
│   │   │       └── student_verification_form.dart
│   │   │
│   │   ├── chat/
│   │   │   ├── chat_screen.dart
│   │   │   ├── chat_controller.dart
│   │   │   ├── chat_binding.dart
│   │   │   └── widgets/
│   │   │       ├── chat_list_item.dart
│   │   │       ├── message_request_card.dart
│   │   │       └── search_user_box.dart
│   │   │
│   │   ├── chat_detail/
│   │   │   ├── chat_detail_screen.dart
│   │   │   ├── chat_detail_controller.dart
│   │   │   ├── chat_detail_binding.dart
│   │   │   └── widgets/
│   │   │       ├── message_bubble.dart
│   │   │       ├── message_input.dart
│   │   │       └── read_status.dart
│   │   │
│   │   ├── chatbot/
│   │   │   ├── chatbot_screen.dart
│   │   │   ├── chatbot_controller.dart
│   │   │   ├── chatbot_binding.dart
│   │   │   └── widgets/
│   │   │       ├── ai_message_bubble.dart
│   │   │       ├── user_message_bubble.dart
│   │   │       └── chatbot_input.dart
│   │   │
│   │   ├── notification/
│   │   │   ├── notification_screen.dart
│   │   │   ├── notification_controller.dart
│   │   │   ├── notification_binding.dart
│   │   │   └── widgets/
│   │   │       └── notification_item.dart
│   │   │
│   │   └── settings/
│   │       ├── settings_screen.dart
│   │       ├── settings_controller.dart
│   │       ├── settings_binding.dart
│   │       └── widgets/
│   │           ├── setting_tile.dart
│   │           ├── theme_toggle.dart
│   │           └── language_selector.dart
│   │
│   └── routes/
│       ├── app_pages.dart
│       └── app_routes.dart
│
├── pubspec.yaml
└── README.md
```
