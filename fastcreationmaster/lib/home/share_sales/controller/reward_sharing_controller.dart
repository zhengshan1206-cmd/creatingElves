import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class RewardSharingController extends GetxController {
  /// 当前选中的tab索引：0=字数奖励，1=现金奖励
  int currentTabIndex = 0;

  @override
  void onInit() {
    super.onInit();
  }

  void switchTab(int index) {
    if (index == currentTabIndex) return;
    currentTabIndex = index;
    update();
  }
}
