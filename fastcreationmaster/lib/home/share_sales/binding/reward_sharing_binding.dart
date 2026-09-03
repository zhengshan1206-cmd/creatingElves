import 'package:fast_creation_master/home/share_sales/controller/reward_sharing_controller.dart';
import 'package:get/get.dart';

class RewardSharingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RewardSharingController>(() => RewardSharingController());
  }
}
