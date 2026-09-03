import 'package:fast_creation_master/profile/setup/controller/profile_setup_controller.dart';
import 'package:get/get.dart';

class ProfileSetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileSetupController());
  }
}
