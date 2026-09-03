import 'package:fast_creation_master/profile/member/controller/member_pay_success_controller.dart';
import 'package:get/get.dart';

class MemberPaySuccessBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    Get.lazyPut<MemberPaySuccessController>(() => MemberPaySuccessController(
          isBackHome: args != null && args['isBackHome'] == true,
        ));
  }
}
