import 'dart:io';

import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:byhy_app_common_utils/app_http/apis.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:get/get.dart';

import '../../global/launch/controller/launch_controller.dart';
import '../../profile/member/beans/integral_pay_list_bean.dart';
import '../../profile/member/beans/user_menus_bean.dart';
import '../../profile/member/beans/vip_page_bean.dart';
import '../../profile/member/beans/vip_page_top_bean.dart';
import '../../profile/member/beans/vip_type_bean.dart';
import '../controller/user_controller.dart';
import '../network/novel_apis.dart';

class AppPrivacyURL extends GetxController {
  List protocolList = [];
  ///获取协议列表
  void getProtocolList() {
    HttpUtils.get(
      NovelApis.novelAppMenus,
      showMsgWhenFailed: false,
      {},
      success: (data) {
        // byDebugPrint(data, tag: "协议列表");
        if (data != null && data['data'] != null) {
          List<dynamic> list = data['data'];
          protocolList = list.map((e) => UserMenusBean.fromJson(e)).toList();
        }
      },
    );
  }
  ///跳转至指定协议页
  void goPrivacyPageWithTitle(String title) {
    try {
      UserMenusBean? bean =
          protocolList.firstWhereOrNull((element) => element.title == title);
      if (bean != null && bean.url.isNotEmpty) {
        ByNavRouterUtils.jumpWebViewPage(Get.context!, title, bean.url);
      }
    } catch (e) {
      // throw(e);
    }
  }
}

///付费页数据，包含套餐，运营位数据，字数包套餐，返回拦截弹窗数据
class PayData extends GetxController {

  ///底部须知说明
  RxString inform = ''.obs;
  ///客服链接
  VipPageBean? vipPageBean;
  ///运营位数据
  RxList<VipOperationBean> operationList = <VipOperationBean>[].obs;
  ///vip套餐列表数据
  RxList<VipTypeBean> vipList = <VipTypeBean>[].obs;
  ///vip套餐返回拦截列表数据
  RxList<VipTypeBean> vipInterceptList = <VipTypeBean>[].obs;
  ///字数包列表数据
  RxList<IntegralPayListBean> wordsPackageList = <IntegralPayListBean>[].obs;
  ///字数包协议
  String? wordsPackIllustrate = '';
  //支付方式支持
  String paySupport = Platform.isAndroid ? "wxpay,alipay,yeepay" : "apple";
  ///vip支付方式配置
  Map<String, dynamic>? payConfig = {};
  ///字数包支付方式配置
  Map<String, dynamic>? wordPackagePayConfig = {};

  ///付费页面顶部数据
  VipPageTopData? vipPageTopData;

  ///banner vip套餐列表数据
  RxList<VipTypeBean> bannerVipList = <VipTypeBean>[].obs;

  ///顶部站位图
  RxList<String> vipPageTopDataList = <String>[].obs;

  ///banner 顶部站位图
  RxList<String> bannerVipPageTopDataList = <String>[].obs;

  /// 归因付费页ID
  int payPageID = 0;


  void init({bool isReload = false, void Function(int)? onSuccess,}) {
    _loadVipHappys(isReload: isReload, onSuccess: onSuccess);
    _loadWordPackageList(isReload: isReload, onSuccess: onSuccess);
    _loadVipPageData(isReload: isReload);
    _loadOperationConfigData(isReload: isReload);
    _loadPayPageTopInfo();
    if(Get.find<UserController>().paybackURL.isNotEmpty) {
      _loadVipHappys(vipType: 2);
    }
  }

  ///拉取付费页展示支付页页面类型数据(用于归因)
  void getPayStyle({void Function()? onSuccess}) {
    HttpUtils.post(
      APIs.payStyle,
      showMsgWhenFailed: false,
      {},
      success: (data) async {
        ///初始化付费页数据
        init(isReload: true);
        onSuccess?.call();
        final String landingPage = data['data']['landing_page'];
        if(landingPage.isNotEmpty) {
          final launchInfo = Get.find<LaunchController>().launchInfo;
          launchInfo?.verConfig.landingPage = landingPage;
        }
        payPageID = data['data']['pay_page_id'] ?? 0;
      },
    );
  }

  ///获取vip数据
  _loadVipPageData({bool isReload = false}) {
    if(inform.isNotEmpty && vipPageBean != null && !isReload) {
      return;
    }
    HttpUtils.get(
      APIs.vipPage, showMsgWhenFailed: false, {}, success: (json) {
      final data = json["data"];
      if (data == null) return;
      vipPageBean = VipPageBean.fromJson(data);
      inform.value = vipPageBean!.user.inform;
    });
  }

  ///获取运营配置
  _loadOperationConfigData({bool isReload = false}) {
    if(operationList.isNotEmpty && !isReload) {
      return;
    }
    HttpUtils.get(NovelApis.vipOperationPage, showMsgWhenFailed: false, {}, success: (json) {
      final opData = json["data"];
      if(opData is List) {
        final List data = opData;
        operationList.value = data.map((e) => VipOperationBean.fromJson(e)).toList();
      }
    });
  }

  ///获取VIP套餐与返回拦截套餐列表
  _loadVipHappys({
    int vipType = 1,
    bool isReload = false,
    void Function(int)? onSuccess,
    void Function()? onFailed,
  }) {
    if(vipType == 1 && vipList.isNotEmpty && !isReload) {
      return;
    }
    if(vipType == 2 && vipInterceptList.isNotEmpty && !isReload) {
      return;
    }
    HttpUtils.get(
      APIs.vipHappys,
      showMsgWhenFailed: false,
      {"ver": 1, "support_pays": paySupport, 'vip_type': vipType},
      success: (data) {
        final respData = data["data"];
        final List items = respData["items"] ?? [];
        /// VIP套餐列表
        List<VipTypeBean> typeBeans =
            items.map((e) => VipTypeBean.fromJson(e)).toList();
        if(vipType == 1) {
          if(Platform.isAndroid) {
            payConfig = respData["pays"] ?? {};
          }
          vipList.clear();
          vipList.addAll(typeBeans);
          onSuccess?.call(0);
        }
        ///vip返回拦截套餐
        else {
          vipInterceptList.clear();
          vipInterceptList.addAll(typeBeans);
        }
      },
      fail: (code, msg) {
        onFailed?.call();
      },
    );
  }

  /// 获取字数包列表
  _loadWordPackageList({
    bool isReload = false,
    void Function(int)? onSuccess,
    void Function()? onFailed,
  }) {
    if(wordsPackageList.isNotEmpty && !isReload) {
      return;
    }
    HttpUtils.get(
      APIs.scoreHappys,
      {
        "ver": 2,
        "support_pays": paySupport,
        "source_type": 2,
      },
      showMsgWhenFailed: false,
      success: (data) {
        final List items = data["data"]["items"] ?? [];
        wordsPackIllustrate = data["data"]["words_pack_illustrate"];
        /// 字数包套餐列表
        List<IntegralPayListBean> typeBeans =
            items.map((e) => IntegralPayListBean.fromJson(e)).toList();
        if (Platform.isAndroid) {
          wordPackagePayConfig = data["data"]["pays"] ?? {};
        }
        wordsPackageList.clear();
        wordsPackageList.addAll(typeBeans);
        onSuccess?.call(1);
      },
      fail: (code, msg) {
        onFailed?.call();
      },
    );
  }

  ///获取付费页顶部运营素材信息
  _loadPayPageTopInfo(){
    HttpUtils.get(
      NovelApis.getPayPageTopMaterial,
      {
        "ver": 2,
        "support_pays": paySupport,
        "source_type": 2,
      },
      showMsgWhenFailed: false,
      success: (data) {
        Get.log("===获取付费页顶部运营素材信息===$data");
        VipPageTopBeanResponse vipPageTopBeanResponse = VipPageTopBeanResponse.fromJson(data);
        if(vipPageTopBeanResponse.data!=null){
          vipPageTopData = vipPageTopBeanResponse.data;
          if(vipPageTopData!=null){
            vipPageTopDataList.clear();
            vipPageTopDataList.addAll(vipPageTopData!.pics);
          }
        }
      },
      fail: (code, msg) {
      },
    );
  }



  ///获取bannerVIP套餐与返回拦截套餐列表
  loadBannerVipHappys({
    int vipType = 1,
    bool isReload = false,
    void Function(int)? onSuccess,
    void Function()? onFailed,
    required String payPageId,
  }) {
    // if(vipType == 1 && vipList.isNotEmpty && !isReload) {
    //   return;
    // }
    // if(vipType == 2 && vipInterceptList.isNotEmpty && !isReload) {
    //   return;
    // }
    HttpUtils.get(
      APIs.vipHappys,
      showMsgWhenFailed: false,
      {"ver": 1, "support_pays": paySupport, 'vip_type': vipType,"pay_page_id":payPageId,},
      success: (data) {
        Get.log("===pay_page_id ==>$payPageId banner拉起付费页面获取套餐列表===$data  ");
        final respData = data["data"];
        final List items = respData["items"] ?? [];
        /// VIP套餐列表
        List<VipTypeBean> typeBeans =
        items.map((e) => VipTypeBean.fromJson(e)).toList();
        if(vipType == 1) {
          if(Platform.isAndroid) {
            payConfig = respData["pays"] ?? {};
          }
          bannerVipList.clear();
          bannerVipList.addAll(typeBeans);
          onSuccess?.call(0);
        }
        ///vip返回拦截套餐
        else {
          vipInterceptList.clear();
          vipInterceptList.addAll(typeBeans);
        }
      },
      fail: (code, msg) {
        onFailed?.call();
      },
    );

    HttpUtils.get(
      NovelApis.getPayPageTopMaterial,
      {
        "ver": 2,
        "support_pays": paySupport,
        "source_type": 2,
        "pay_page_id":payPageId,
      },
      showMsgWhenFailed: false,
      success: (data) {
        Get.log("===获取banner进入的付费页顶部运营素材信息===$data");
        VipPageTopBeanResponse vipPageTopBeanResponse = VipPageTopBeanResponse.fromJson(data);
        if(vipPageTopBeanResponse.data!=null){
          vipPageTopData = vipPageTopBeanResponse.data;
          if(vipPageTopData!=null){
            bannerVipPageTopDataList.clear();
            bannerVipPageTopDataList.addAll(vipPageTopData!.pics);
          }
        }
        update();
      },
      fail: (code, msg) {
      },
    );

  }


}

// 全局依赖注入绑定
class GlobalBinding implements Bindings {
  @override
  void dependencies() {
    // 注册全局控制器
    Get.put(GlobalController());
    
    // 注册各模块控制器
    Get.put(PayData());
  }
}

class BannerManager {
  ///小说正文页
  bool novelDetailBanner = false;
  ///支付成功页
  Rx<bool> paySuccessBanner = false.obs;
}

// 全局状态管理类
class GlobalController extends GetxController {
  // 单例模式
  static GlobalController get instance => Get.find();

  ///支付相关数据
  PayData get pay => Get.find();

  BannerManager banner = BannerManager();
  
  // // 初始化 - 从本地加载数据
  // @override
  // void onInit() {
  //   super.onInit();
  // }
}
