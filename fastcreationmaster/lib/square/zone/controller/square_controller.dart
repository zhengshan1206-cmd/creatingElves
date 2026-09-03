import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_common/by_common_utils.dart';
import 'package:byhy_app_common_utils/app_http/apis.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/core/network/novel_apis.dart';
import 'package:fast_creation_master/profile/member/beans/user_info_bean.dart';
import 'package:fast_creation_master/square/add_wechat_dialog.dart';
import 'package:fast_creation_master/square/beans/strategy_list_bean.dart';
import 'package:fast_creation_master/square/beans/zone_menus_bean.dart';
import 'package:fast_creation_master/square/square_guide_dialog.dart';
import 'package:get/get.dart';

import '../../../global/other/event_tracking/event_tracking.dart';
import '../../../global/routes/routes_utils.dart';

class SquareController extends GetxController {
  ///banner
  final RxList<BannerBean> bannerList = <BannerBean>[].obs;

  ///专区列表
  RxList<ZoneMenusBean> zoneList = <ZoneMenusBean>[].obs;

  ///攻略列表
  RxList<StrategyListBean> strategyList = <StrategyListBean>[].obs;

  ///获取用户信息
  final UserController _userController = Get.find<UserController>();

  ///用户信息
  UserInfoBean? get userInfo => _userController.userInfoBean.value;

  ///当前页码
  int currentPage = 1;

  ///每页数量
  final int pageSize = 10;

  ///是否还有更多数据
  bool hasMore = true;

  ///引导弹窗是否显示
  bool isShowGuideDialog = false;

  ///是否显示banner
  RxBool showBanner = true.obs;

  ///专区列表 0基础必看 变现专区
  RxList<ZoneMenusBean> zoneListHeader = <ZoneMenusBean>[].obs;

  ///系列课
  RxList<StrategyListBean> courseZoneList = <StrategyListBean>[].obs;

  ///系列课id
  int? courseId;


  RxString title1 = "".obs;

  // String title2 = "";

  @override
  void onInit() {
    super.onInit();
    loadBanners(postion: 100);
    getCategoryList();
    getStrategyGuideList();
    // getCourseList();
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

  ///是否显示引导弹窗
  showGuideDialog() {
    if (userInfo == null) {
      // 如果用户信息未加载，等待加载完成后再显示
      _userController.getUserInfo(
        onSuccess: (userInfo) {
          if (userInfo?.isVip == 0) {
            isShowGuideDialog = true;

            // 旧版本弹窗
            Get.dialog(
              SquareGuideDialog(),
            );

            /// 加V弹窗
            // Get.dialog(AddWechatDialog(
            //   wechatUrl: _userController.strategyAddVUrl,
            // ));
          }
        },
      );
    } else if (userInfo?.isVip == 0) {
      isShowGuideDialog = true;
      // 旧版本弹窗
      Get.dialog(
        SquareGuideDialog(),
      );

      /// 加V弹窗
      // Get.dialog(AddWechatDialog(
      //   wechatUrl: _userController.strategyAddVUrl,
      // ));
    }
  }

  ///关闭banner
  void closeBanner() {
    showBanner.value = false;
  }

  ///获取分类列表
  getCategoryList() {
    HttpUtils.get(
      NovelApis.getCategoryList,
      {"type": 'app_ai_novel_square_guide'},
      showMsgWhenFailed: false,
      success: (data) {
        byDebugPrint(data, tag: "分类列表item");

        final List categoryData = data["data"] ?? [];
        List<ZoneMenusBean> beans =
            categoryData.map((e) => ZoneMenusBean.fromJson(e)).toList();
        List<ZoneMenusBean> zoneListHeaderBeans = [];
        zoneList.value = beans;
        if (beans.isNotEmpty) {
          for (var e in beans) {
            if (e.key == "ji_chu_bi_kan" || e.key == "bian_xian_zhuan_qu") {
              zoneListHeaderBeans.add(e);
            }
            if (e.key == "xi_lie_ke") {
              courseId = e.id;
              title1.value = e.title;
              update();


              getCourseList(id: courseId!);
            }
          }
          zoneListHeader.value = zoneListHeaderBeans;
        }

        update();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///获取所有攻略列表
  getStrategyGuideList({bool isRefresh = false}) {
    if (isRefresh) {
      currentPage = 1;
      hasMore = true;
    }

    if (!hasMore) return;

    HttpUtils.get(
      NovelApis.getNovelGuideList,
      {
        "type": 'app_ai_novel_square_guide',
        "page": currentPage,
        "pageSize": pageSize,
      },
      showMsgWhenFailed: false,
      success: (data) {
        byDebugPrint(data, tag: "攻略列表item11");
        final List strategyData = data["data"]["data"] ?? [];
        List<StrategyListBean> beans =
            strategyData.map((e) => StrategyListBean.fromJson(e)).toList();

        if (isRefresh) {
          strategyList.value = beans;
        } else {
          strategyList.addAll(beans);
        }

        hasMore = beans.length >= pageSize;
        if (hasMore) {
          currentPage++;
        }

        update();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///展示加v 弹窗
  void addWechatDialog() {
    String addWechatBgUrl = Get.find<UserController>().addWechatBgUrl;
  }

  ///获取系列课列表
  getCourseList({
    required int id,
  }) {
    HttpUtils.get(
      NovelApis.getStrategyGuideList,
      {
        "type": 'app_ai_novel_square_guide',
        "page": 1,
        "pageSize": 2,
        "group_id": id,
      },
      showMsgWhenFailed: false,
      success: (data) {
        byDebugPrint(data, tag: "系列课列表");
        final List strategyData = data["data"]["data"] ?? [];
        List<StrategyListBean> beans =
            strategyData.map((e) => StrategyListBean.fromJson(e)).toList();
        courseZoneList.value = beans;
        update();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }
}
