import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:byhy_app_common_utils/app_http/apis.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:fast_creation_master/core/network/novel_apis.dart';
import 'package:fast_creation_master/core/service/words.dart';
import 'package:fast_creation_master/profile/member/beans/record_bean.dart';
import 'package:fast_creation_master/profile/member/beans/user_menus_bean.dart';
import 'package:get/get.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/profile/member/beans/user_info_bean.dart';

import '../global/other/event_tracking/event_tracking.dart';
import '../global/routes/routes_utils.dart';

class ProfileController extends GetxController {
  ///用户信息
  final UserController _userController = Get.find<UserController>();

  // 将 userInfo 转换为响应式数据
  final Rx<UserInfoBean?> _userInfo = Rx<UserInfoBean?>(null);
  UserInfoBean? get userInfo => _userInfo.value;

  ///协议列表
  RxList<UserMenusBean> protocolList = <UserMenusBean>[].obs;

  ///记录统计
  Rx<RecordBean?> recordBean = Rx<RecordBean?>(null);

  ///banner
  RxList<BannerBean> bannerList = <BannerBean>[].obs;

  ///是否显示banner
  RxBool showBanner = true.obs;
  /// 是否上报了banner展示
  bool _reportBanner = false;

  @override
  void onInit() {
    super.onInit();
    // 初始化时获取用户信息
    _updateUserInfo();
    getProtocolList();
    loadBanners(postion: 7);
    // 监听 UserController 中的 userInfoBean 变化
    ever(_userController.userInfoBean, _updateUserInfo);
  }

  // 更新用户信息
  void _updateUserInfo([UserInfoBean? info]) {
    _userInfo.value = info ?? _userController.userInfoBean.value;
    getNovelCreateCount();
  }

  ///获取用户当前字数包字数
  ///是否需要显示详细字数
  String getUserWords({bool? needDetail = false}) {
    final words = userInfo?.wordsPack != null ? '${userInfo?.wordsPack}' : '0';
    if (needDetail!) {
      return words;
    }
    return WordsService.wordsDisplay(words);
  }

  ///关闭banner
  void closeBanner() {
    showBanner.value = false;
  }

  ///获取协议列表
  void getProtocolList() {
    HttpUtils.get(
      NovelApis.novelAppMenus,
      {},
      success: (data) {
        // byDebugPrint(data, tag: "协议列表");
        if (data != null && data['data'] != null) {
          List<dynamic> list = data['data'];
          protocolList.value =
              list.map((e) => UserMenusBean.fromJson(e)).toList();
          update();
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///根据标题匹配跳转协议
  getProtocolByTitle(String title) {
    try {
      UserMenusBean? bean =
          protocolList.firstWhereOrNull((element) => element.title == title);
      if (bean != null && bean.url.isNotEmpty) {
        ByNavRouterUtils.jumpWebViewPage(Get.context!, "", bean.url);
      }
    } catch (e) {}
  }

  ///记录统计
  void getNovelCreateCount() {
    HttpUtils.post(NovelApis.getNovelCreateCount, {}, success: (data) {
      recordBean.value = RecordBean.fromJson(data['data']);
    }, fail: (code, msg) {
      BotToast.showText(text: msg);
    });
  }

  ///更新信息
  void updateUserInfo() {
    _userController.reloadUserInfo();
    _updateUserInfo();
  }

  /// 上报banner展示数据
  void reportData() {
    EventTracking.reportDataPoint(
                        pageTag: 'my_page',
                        operateType: 'view',
                        funcDetailImg: '',
                        funcDetailTag: '',);
    if (bannerList.isNotEmpty && !_reportBanner) {
      BannerBean bean = bannerList.first;
      _reportBanner = true;
      EventTracking.reportDataPoint(
        pageTag: 'banner',
        operateType: 'view',
        funcDetailTag: bean.id.toString(),
        funcDetailImg: bean.imgUrl,
      );
    }
  }

  /// [postion] banner所处的位置
  loadBanners({
    required int postion,
  }) {
    HttpUtils.get(
      APIs.homeBanner,
      {
        "postion": postion,
      },
      showMsgWhenFailed: false,
      success: (data) {
        final List bannerData = data["data"]["item"] ?? [];
        // byDebugPrint(data["item"], tag: "banner所处的位置");
        List<BannerBean> beans =
            bannerData.map((e) => BannerBean.fromJson(e)).toList();
        bannerList.value = beans;
        update();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }
}
