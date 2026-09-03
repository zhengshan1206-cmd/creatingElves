import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_http/apis.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:fast_creation_master/core/controller/base_controller.dart';
import 'package:fast_creation_master/core/network/novel_apis.dart';
import 'package:fast_creation_master/core/widget/view/muti_status_view.dart';
import 'package:fast_creation_master/square/beans/strategy_list_bean.dart';
import 'package:get/get.dart';

import '../../../global/routes/routes_utils.dart';

class SquareZoneController extends BaseController {
  ///当前页码
  int currentPage = 1;

  ///每页数量
  final int pageSize = 10;

  ///是否还有更多数据
  bool hasMore = true;

  ///专区id
  final int id;

  ///封面图
  final String iconUrl;

  SquareZoneController({this.id = 0, this.iconUrl = ""});

  ///攻略列表
  final RxList<StrategyListBean> strategyList = <StrategyListBean>[].obs;

  ///当前列表类型
  String type = "";

  ///banner
  final RxList<BannerBean> bannerList = <BannerBean>[].obs;

  ///是否显示banner
  RxBool showBanner = true.obs;

  @override
  void onInit() {
    super.onInit();
    getStrategyGuideList();
    _loadBannerByType();
  }

  ///获取攻略列表
  getStrategyGuideList({bool isRefresh = true}) {
    String api = NovelApis.getStrategyGuideList;
    final argument = Get.arguments;
    Get.log("===argument===$argument");
    bool needId = true;
    if (argument["type"] != null) {
      type = argument["type"];
      if (argument["type"] == "xi_lie_ke") {
        api = NovelApis.getStrategyGuideList;
      }

      if (argument["type"] == "all_look") {
        api = NovelApis.getNovelGuideList;
        needId = false;
      }
    }

    if (isRefresh) {
      currentPage = 1;
      hasMore = true;
    }

    if (!hasMore) return;

    HttpUtils.get(
      api,
      {
        "page": currentPage,
        "pageSize": pageSize,
        "group_id": needId ? id.toString() : "",
        "type": 'app_ai_novel_square_guide',
      },
      showMsgWhenFailed: false,
      success: (data) {
        if (data['status'] == 200) {
          final List strategyData = data["data"]["data"] ?? [];
          List<StrategyListBean> beans =
              strategyData.map((e) => StrategyListBean.fromJson(e)).toList();
          if (beans.isEmpty) {
            statusType.value = MultiStatusType.statusEmpty;
          } else {
            statusType.value = MultiStatusType.statusContent;
          }

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
        } else {
          if (strategyList.isEmpty) {
            statusType.value = MultiStatusType.statusNoNetWork;
          }
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        statusType.value = MultiStatusType.statusNoNetWork;
      },
    );
  }

  /// [postion] banner所处的位置
  /// 202 => 'Ai长文-小说-攻略-0基础必看',
  /// 203 => 'Ai长文-小说-攻略-变现专区',
  /// 204 => 'Ai长文-小说-攻略-系列课',
  /// 205 => 'Ai长文-小说-攻略-大家都在看',
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

  ///关闭banner
  void closeBanner() {
    showBanner.value = false;
  }

  ///根据类型加载对应的banner
  void _loadBannerByType() {
    final argument = Get.arguments;
    int bannerPosition = 100; // 默认位置

    if (argument != null && argument["type"] != null) {
      String type = argument["type"];
      switch (type) {
        case "xi_lie_ke":
          // 系列课
          bannerPosition = 204;
          break;
        case "all_look":
          // 大家都在看
          bannerPosition = 205;
          break;
        case "ji_chu_bi_kan":
          // 0基础必看
          bannerPosition = 202;
          break;
        case "bian_xian_zhuan_qu":
          // 变现专区
          bannerPosition = 203;
          break;
      }
    }
    print("===bannerPosition===$type");

    loadBanners(postion: bannerPosition);
  }
}
