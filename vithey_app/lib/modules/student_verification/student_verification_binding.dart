import 'package:get/get.dart';
import 'package:aub_connect_app/data/repositories/student_verification_repository.dart';
import 'package:aub_connect_app/modules/student_verification/student_verification_screen.dart';
import 'package:aub_connect_app/modules/student_verification/verification_status_screen.dart';

class StudentVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StudentVerificationController(Get.find<StudentVerificationRepository>()));
  }
}

class VerificationStatusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VerificationStatusController(Get.find<StudentVerificationRepository>()));
  }
}
