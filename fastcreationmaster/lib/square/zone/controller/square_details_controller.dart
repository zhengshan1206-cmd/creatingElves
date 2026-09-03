import 'package:fast_creation_master/core/controller/base_controller.dart';
import 'package:fast_creation_master/core/widget/view/muti_status_view.dart';
import 'package:fast_creation_master/profile/member/beans/user_info_bean.dart';
import 'package:fast_creation_master/square/beans/zoon_detail_bean.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:fast_creation_master/core/network/novel_apis.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:get/get.dart';

// 攻略类型1.图文 2.视频
class SquareDetailsController extends BaseController {
  ///页面加载
  final RxBool showLoading = true.obs;

  ///详情id
  final int id;

  SquareDetailsController({required this.id});

  Rx<ZoonDetailBean?> detailsData = Rx<ZoonDetailBean?>(null);

  ///用户控制器
  final UserController _userController = Get.find<UserController>();

  ///获取用户信息
  UserInfoBean? get userInfo => _userController.userInfoBean.value;

  @override
  void onInit() {
    super.onInit();
    getStrategyGuideDetail();
  }

  void getStrategyGuideDetail() {
    // statusType.value = MultiStatusType.statusLoading;
    showLoading.value = true;
    HttpUtils.get(
      NovelApis.getStrategyGuideDetail,
      {"id": id},
      showMsgWhenFailed: false,
      success: (data) {
        detailsData.value = ZoonDetailBean.fromJson(data["data"]);
        statusType.value = MultiStatusType.statusContent;
        Get.log("===系列课详情数据===${detailsData.value?.toJson()}");
        showLoading.value = false;
        update();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        showLoading.value = false;
        statusType.value = MultiStatusType.statusNoNetWork;
      },
    );
  }
}
