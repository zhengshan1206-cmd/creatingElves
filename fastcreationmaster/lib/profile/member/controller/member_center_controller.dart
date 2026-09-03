import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_common/aes/byhy_aes_storage_utils.dart';
import 'package:byhy_app_common_utils/app_common/by_common_utils.dart';
import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:byhy_app_common_utils/app_common/consts/build_config.dart';
import 'package:byhy_app_common_utils/app_common/event/common_event.dart';
import 'package:byhy_app_common_utils/app_http/apis.dart';
import 'package:byhy_app_common_utils/app_http/channel.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:byhy_app_common_utils/app_purchase/ios_purchase/ios_buy_engine.dart';
import 'package:byhy_app_common_utils/app_purchase/wechat_buy_engine/ali_pay_order_bean.dart';
import 'package:byhy_app_common_utils/app_purchase/wechat_buy_engine/bug_engine.dart';
import 'package:byhy_app_common_utils/app_purchase/wechat_buy_engine/wx_pay_model.dart';
import 'package:byhy_app_common_utils/app_purchase/wechat_buy_engine/wx_yeepay_order_bean.dart';
import 'package:fast_creation_master/core/cache/global_controller.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/global/launch/bean/launch_info_bean.dart';
import 'package:fast_creation_master/global/launch/controller/launch_controller.dart';
import 'package:fast_creation_master/global/other/event_tracking/event_tracking.dart';
import 'package:fast_creation_master/global/routes/app_pages.dart';
import 'package:fast_creation_master/home/first_create/fake_chapter_list_view.dart';
import 'package:fast_creation_master/home/main_page/controller/home_controller.dart';
import 'package:fast_creation_master/profile/member/beans/vip_type_bean.dart';
import 'package:fast_creation_master/profile/member/dialog/confirm_dialog.dart';
import 'package:fast_creation_master/profile/member/dialog/member_agree_dialog.dart';
import 'package:fast_creation_master/profile/member/dialog/member_retain_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:sp_util/sp_util.dart';
import 'package:wechat_kit/wechat_kit.dart';
import 'package:alipay_kit/alipay_kit_platform_interface.dart';

import '../../../core/network/novel_apis.dart';
import '../../../core/service/data_service.dart';
import '../../../global/const/const.dart';
import '../../../global/login/controller/onekey_manager.dart';
import '../../../home/share_sales/reward/reward_controller.dart';
import '../../../square/add_wechat_dialog.dart';
import '../widget/not_pay_order_widget.dart';
import 'member_pay_success_controller.dart';
import 'pay_style_manager.dart';

class MemberCenterController extends GetxController
    with WidgetsBindingObserver {
  ///tab选中索引
  RxInt tabCurrentIndex = 0.obs;

  /// 是否正在加载
  RxBool isLoading = false.obs;

  ///加载文案
  RxString loadingText = "订单处理中...".obs;

  /// 可用的vip支付方式列表
  List<Map<String, dynamic>> payMethodBeans = [];

  /// 可用的字数包支付方式列表
  List<Map<String, dynamic>> wordPackagePayMethodBeans = [];

  /// 当前选中的支付方式
  String currentPayMethod = Platform.isAndroid ? "wxpay" : "apple";

  /// 当前选中的vip支付方式索引
  RxInt currentPayMethodIndex = 0.obs;

  /// 当前选中的字数包支付方式索引
  RxInt currentWordPackagePayMethodIndex = 0.obs;

  /// 当前选中的vip套餐索引
  RxInt selectedPackageIndex = 0.obs;

  /// 当前选中的字数包套餐索引
  RxInt selectedWordPackageIndex = 0.obs;

  ///协议是否阅读
  RxBool agreementChecked = false.obs;

  /// 创建订单config_id
  int createOrderConfigId = 0;

  /// 创建ios订单appleVipId
  String createIosOrderAppleVipId = "";

  ///订单id
  String orderId = "";

  ///Ios支付工具
  IosBuyEngin iosBuyEngin = IosBuyEngin();

  ///苹果支付成功后查询订单状态的监听
  late StreamSubscription _iosPaySuccessSubscription;

  late StreamSubscription _iosBuyStreamSubscription;

  ///易宝异常状态
  RxBool isYeepayException = false.obs;

  ///是否是挽留弹窗拉起的支付
  RxBool isRetainPay = false.obs;
  ///是否是二次挽留弹窗拉起的支付
  RxBool isSecondRetainPay = false.obs;

  final userInfo = Get.find<UserController>().userInfoBean;

  ///返回拦截弹窗次数
  int interceptCount = 0;

  ///付费页样式管理器
  late PayStyleManager styleManager;

  ///付费页数据
  PayData payData = Get.find<PayData>();

  ///是否来自于banner
  bool isFromBanner = false;

  ///需要展示的vipList
  RxList<VipTypeBean> newVipList = <VipTypeBean>[].obs;

  ///需要展示的顶部站位图
  RxList<String> vipPageTopDataList = <String>[].obs;


  MemberCenterController({
    this.isBackHome = false, 
    this.showSKUDialog = false ,
    this.source = 'unknown',
    this.payPageStyle,
    this.payScreenType,});

  ///是否直接返回首页
  bool isBackHome = false;
  ///是否需要显示SKU弹窗
  bool? showSKUDialog;
  ///付费页来源
  String? source;
  ///付费页横竖屏
  int? payScreenType; // 0: 横屏, 1: 竖屏
  ///付费页样式类型
  int? payPageStyle; 

  /// 埋点相关
  final landingPage = Get.find<LaunchController>().launchInfo?.verConfig.landingPage ?? '';
  final pagePageID = GlobalController.instance.pay.payPageID;

  @override
  void onInit() {
    super.onInit();

    styleManager = PayStyleManager(
      type: payScreenType ?? 0,
      style: payPageStyle ?? 1, // 1: 默认样式, 2: 黑色样式, 3: 白色样式

      // type: 0,
      // style: 4,
    );
    loadBannerVipList();

    // newVipList = isFromBanner ? payData.bannerVipList : payData.vipList;
    ///iOS支付初始化
    if(Platform.isIOS) {
      iosBuyEngin.initializeInAppPurchase();
      iosBuyEngin.onPayStatus = (status) {
        if (status == PurchaseStatus.purchased || status == PurchaseStatus.restored || status == PurchaseStatus.error || status == PurchaseStatus.canceled) {
          isLoading.value = false;
        } else if (status == PurchaseStatus.pending) {
          isLoading.value = true;
          loadingText.value = '等待支付中...';
        }
      };
    }
    WidgetsBinding.instance.addObserver(this);
    loadInit();
    
    EventTracking.reportDataPoint(
      pageTag: 'member_page', 
      operateType: 'view', 
      funcDetailTag: landingPage, 
      funcDetailImg: '',
      extra: {'pay_page_id': pagePageID});
    ///监听支付结果
    subscribePayResult();

    ///显示SKU付费弹窗
    if (showSKUDialog!) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 400), () {
          interceptCount = 1;
          closePage();
        });
      });
    }
  }


  loadBannerVipList(){
    final arguments = Get.arguments;
    if(arguments!=null){
      if(arguments["payPageId"]!=null){
        payData.loadBannerVipHappys(payPageId: arguments["payPageId"],onSuccess: (value){
          newVipList.clear();
          newVipList.addAll(payData.bannerVipList);
          vipPageTopDataList.clear();
          vipPageTopDataList.addAll(payData.bannerVipPageTopDataList);

          update();
          Get.log("===newVipList=== $newVipList");
        });
      }else{
        newVipList.clear();
        newVipList.addAll(payData.vipList);
        vipPageTopDataList.clear();
        vipPageTopDataList.addAll(payData.vipPageTopDataList);
        update();
      }
    }
  }


  void loadInit() {
    if (userInfo.value?.isVip == 1) {
      changeTab(1);
      loadWordPackageList();
    } else {
      changeTab(0);
      loadVipHappys();
    }
  }

  ///获取VIP权益列表
  loadVipHappys({
    int vipType = 1,
    void Function()? onSuccess,
  }) {
    if(newVipList.isNotEmpty) {
      if (Platform.isAndroid) {
        _processPayMethods(payData.payConfig!, 'vip');
      }
      switchVipListCurrent(selectedPackageIndex.value);
    }
    
  }

  /// 获取字数包列表
  loadWordPackageList({
    void Function()? onSuccess,
  }) {
    if (payData.vipInterceptList.isNotEmpty) {
      if (Platform.isAndroid) {
        _processPayMethods(payData.wordPackagePayConfig!, 'text');
      }
      switchWordPackageListCurrent(selectedWordPackageIndex.value);
    }
  }

  /// 处理支付方式
  void _processPayMethods(Map<String, dynamic> payConfig, String type) {
    List<Map<String, dynamic>> targetList =
        type == 'vip' ? payMethodBeans : wordPackagePayMethodBeans;
    targetList.clear();

    payConfig.forEach((key, value) {
      if (value == 1) {
        _addPayMethod(targetList, key);
      }
    });

    // 设置默认支付方式
    if (targetList.isNotEmpty) {
      if (type == 'vip' && tabCurrentIndex.value == 0) {
        currentPayMethodIndex.value = 0;
        currentPayMethod = payMethodBeans.first["payNameKey"];
      } else {
        currentWordPackagePayMethodIndex.value = 0;
        currentPayMethod = wordPackagePayMethodBeans.first["payNameKey"];
      }
    }
  }

  /// 添加支付方式
  void _addPayMethod(List<Map<String, dynamic>> targetList, String payType) {
    switch (payType) {
      case "wxpay":
        targetList.add({
          "payName": "微信支付",
          "icon": "assets/profile/member/member_3.png",
          "payNameKey": "wxpay",
        });
        break;
      case "alipay":
        targetList.add({
          "payName": "支付宝支付",
          "icon": "assets/profile/member/member_4.png",
          "payNameKey": "alipay",
        });
        break;
      case "yeepay":
        // 检查是否已经添加了微信支付
        bool hasWxPay = targetList.any((bean) => bean["payNameKey"] == "wxpay");
        if (!hasWxPay) {
          targetList.add({
            "payName": "微信支付",
            "icon": "assets/profile/member/member_3.png",
            "payNameKey": "yeepay",
          });
        }
        break;
    }
  }

  ///套餐切换
  void switchVipListCurrent(int index) {
    selectedPackageIndex.value = index;
    getPackageButtonText();
    update();
  }

  /// 字数包套餐切换
  void switchWordPackageListCurrent(int index) {
    selectedWordPackageIndex.value = index;
    getPackageButtonText();
    update();
  }

  /// 切换支付方式
  void switchPayMethod(int index) {
    if (tabCurrentIndex.value == 0) {
      currentPayMethodIndex.value = index;
    } else {
      currentWordPackagePayMethodIndex.value = index;
    }
    currentPayMethod = tabCurrentIndex.value == 0
        ? payMethodBeans[index]["payNameKey"]
        : wordPackagePayMethodBeans[index]["payNameKey"];
    update(['pay_select']);
    // update();
  }

  ///tab切换
  void changeTab(int index) {
    tabCurrentIndex.value = index;
    agreementChecked.value = !Get.find<UserController>().isAudit();
    update();
  }

  /// 获取列表背景图片 member_center_vertical_page.dart
  String getVipBackgroundImage(bool isSelected, int vipLevel, String type) {
    String bgPath =
        'assets/profile/member/member_pay_vertical_${type == 'vip' ? 'vip' : 'text'}_bg_1.png';
    if (!isSelected) {
      bgPath = 'assets/profile/member/member_pay_vertical_bg.png';
    } else {
      if (vipLevel == 0) {
        bgPath =
            'assets/profile/member/member_pay_vertical_${type == 'vip' ? 'vip' : 'text'}_bg_3.png';
      } else if (vipLevel == 1) {
        bgPath =
            'assets/profile/member/member_pay_vertical_${type == 'vip' ? 'vip' : 'text'}_bg_2.png';
      } else {
        bgPath =
            'assets/profile/member/member_pay_vertical_${type == 'vip' ? 'vip' : 'text'}_bg_1.png';
      }
    }
    return bgPath;
  }

  /// 获取列表背景图片 member_center_page.dart
  String getVipBackgroundImage2(bool isSelected, int vipLevel, String type) {
    String bgPath =
        'assets/profile/member/member_pay_${type == 'vip' ? 'vip' : 'text'}_bg_1.png';
    if (!isSelected) {
      bgPath = 'assets/profile/member/member_pay_bg.png';
    } else {
      if (vipLevel == 0) {
        bgPath =
            'assets/profile/member/member_pay_${type == 'vip' ? 'vip' : 'text'}_bg_3.png';
      } else if (vipLevel == 1) {
        bgPath =
            'assets/profile/member/member_pay_${type == 'vip' ? 'vip' : 'text'}_bg_2.png';
      } else {
        bgPath =
            'assets/profile/member/member_pay_${type == 'vip' ? 'vip' : 'text'}_bg_1.png';
      }
    }
    return bgPath;
  }

  /// 协议是否阅读
  void agreementCheckedChanged(bool value) {
    if(Get.find<UserController>().isAudit()) {
      agreementChecked.value = value;
      update();
    }
  }

  /// 获取套餐按钮文案
  String getPackageButtonText() {
    String buttonTitle = "立即购买";
    buttonTitle = tabCurrentIndex.value == 0
        ? newVipList[selectedPackageIndex.value].buttonTitle
        : payData.wordsPackageList[selectedWordPackageIndex.value].buttonTitle;
    return buttonTitle;
  }

  /// 获取当前选择的套餐ID
  int getPackageID() {
    int packageID = tabCurrentIndex.value == 0
        ? newVipList[selectedPackageIndex.value].id
        : payData.wordsPackageList[selectedWordPackageIndex.value].id;
    return packageID;
  }

  /// 套餐购买
  void packageBuy() {
    // if (newVipList.isEmpty || payData.vipInterceptList.isEmpty) {
    //   return;
    // }

    if (canCreateOrder() == false) return;
    if (!agreementChecked.value) {
      EventTracking.reportDataPoint(
          pageTag: 'member_page_renew_protocol_dialog',
          operateType: 'view',
          funcDetailTag: landingPage,
          funcDetailImg: '',
          extra: {'pay_page_id': pagePageID, 'vip_id': getPackageID()});
      Get.dialog(const MemberAgreeDialog());
      return;
    }
    if (tabCurrentIndex.value == 0) {
      createVipOrder();
    } else {
      createWordPackageOrder();
    }
  }

  ///获取创建订单config_id和AppleVipId
  void getCreateOrderConfigId() {
    ///创建订单上报
    DataService.onEvent('pay_create_order', {
      'source': source,
      'type': tabCurrentIndex.value == 0 ? 'vip' : 'words_package',
      'channel': currentPayMethod
    });

    EventTracking.reportDataPoint(
        pageTag: 'member_page_initiate_payment',
        operateType: '',
        funcDetailTag: landingPage,
        funcDetailImg: '',
        extra: {'pay_page_id': pagePageID, 'vip_id': getPackageID(), 'pay_type': (isRetainPay.value || isSecondRetainPay.value) ? 1 : 2});
    if (isRetainPay.value || isSecondRetainPay.value) {
      List<VipTypeBean> vipList = isSecondRetainPay.value ? payData.vipInterceptList : newVipList;
      if (tabCurrentIndex.value == 0) {
        if(vipList.isEmpty) {
          isRetainPay.value = false;
          isSecondRetainPay.value = false;
          return;
        }
        createOrderConfigId = vipList[0].id;
        if (Platform.isIOS) {
          createIosOrderAppleVipId = vipList[0].appleVipId;
        }
      } else {
        createOrderConfigId = payData.vipInterceptList[0].id;
        if (Platform.isIOS) {
          createIosOrderAppleVipId = payData.vipInterceptList[0].appleVipId;
        }
      }
      isRetainPay.value = false;
      isSecondRetainPay.value = false;
      update();
      return;
    }
    if (tabCurrentIndex.value == 0) {
      createOrderConfigId = newVipList[selectedPackageIndex.value].id;
      if (Platform.isIOS) {
        createIosOrderAppleVipId =
            newVipList[selectedPackageIndex.value].appleVipId;
      }
    } else {
      createOrderConfigId = payData.wordsPackageList[selectedWordPackageIndex.value].id;
      if (Platform.isIOS) {
        createIosOrderAppleVipId =
            payData.wordsPackageList[selectedWordPackageIndex.value].appleVipId;
      }
    }
  }

  ///创建vip订单
  Future<void> createVipOrder() async {
    final arguments = Get.arguments;
    String? pay_page_id;
    if(arguments!=null){
      if(arguments["payPageId"]!=null){
        pay_page_id = arguments["payPageId"];
      }
    }

    if (!agreementChecked.value) {
      Get.dialog(const MemberAgreeDialog());
      return;
    }

    ///检查微信支付是否正常
    if (currentPayMethod == 'wxpay' || currentPayMethod == 'yeepay') {
      bool canWechatPay = await WechatKitPlatform.instance.isInstalled();
      if (!canWechatPay) {
        BotToast.showText(text: "由于您未安装微信，无法完成支付。请切换其他方式支付");
        return;
      }
    }
    if (currentPayMethod == 'alipay') {
      // 支付宝支付
      bool canAliPay = await AlipayKitPlatform.instance.isInstalled();
      if (!canAliPay) {
        BotToast.showText(text: "由于您未安装支付宝，无法完成支付。请切换其他方式支付");
        return;
      }
    }
    getCreateOrderConfigId();
    ///没有订单ID
    if(createOrderConfigId == 0){
      return;
    }
    isLoading.value = true;
    loadingText.value = "订单处理中...";

    HttpUtils.post(
      APIs.iosOrder,
      {
        "pay": currentPayMethod == 'yeepay' ? 'wxpay' : currentPayMethod,
        "config_id": createOrderConfigId,
        "support_pays": payData.paySupport,
        "pay_page_id":pay_page_id,
      },
      success: (data) {
        byDebugPrint(data["data"], tag: "创建支付订单:");
        orderId = data["data"]["id"];
        pullUpPayment(data["data"]);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        isLoading.value = false;
        loadingText.value = "订单处理中...";
      },
    );
  }

  ///vip订单查询
  void queryVipOrder({
    void Function()? onSuccess,
    void Function()? onFailed,
    String? receiptData,
    int retryCount = 0,
  }) {
    if(orderId.isEmpty){
      return;
    }
    Map<String, dynamic> params = {
      "id": orderId,
    };

    if (Platform.isIOS && receiptData != null) {
      params["receipt_data"] = receiptData;
    }
    if (retryCount > 2 && Platform.isAndroid) {
      showConfirmDialog();
      onFailed?.call();
      return;
    }
    isLoading.value = true;
    loadingText.value = "订单查询中...";

    HttpUtils.post(
      APIs.queryOrderStatus,
      params,
      success: (data) {
        byDebugPrint(data["data"], tag: "订单状态:");
        final status = data["data"]["order_status"] ?? "";
        if (status == "SUCCESS") {
          isLoading.value = false;
          onSuccess?.call();
          if (Platform.isIOS) {
            eventBus.fire(const IosProductBuySuccessEvent());
          }
          else {
            closePageAndJumpToSuccessPage();
          }
          
        } else if (status == "FAIL") {
          isLoading.value = false;
          onFailed?.call();
        } else {
          Future.delayed(const Duration(seconds: 3), () {
            if (Platform.isIOS) {
              queryVipOrder(receiptData: receiptData);
            } else if (Platform.isAndroid) {
              queryVipOrder(
                  onSuccess: onSuccess,
                  onFailed: onFailed,
                  retryCount: retryCount + 1);
            }
          });
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        isLoading.value = false;
      },
    );
  }

  ///创建字数包订单
  Future<void> createWordPackageOrder() async {
    if (!agreementChecked.value) {
      Get.dialog(const MemberAgreeDialog());
      return;
    }

    ///检查微信支付是否正常
    if (currentPayMethod == 'wxpay' || currentPayMethod == 'yeepay') {
      bool canWechatPay = await WechatKitPlatform.instance.isInstalled();
      if (!canWechatPay) {
        BotToast.showText(text: "由于您未安装微信，无法完成支付。请切换其他方式支付");
        return;
      }
    }
    if (currentPayMethod == 'alipay') {
      // 支付宝支付
      bool canAliPay = await AlipayKitPlatform.instance.isInstalled();
      if (!canAliPay) {
        BotToast.showText(text: "由于您未安装支付宝，无法完成支付。请切换其他方式支付");
        return;
      }
    }
    isLoading.value = true;
    loadingText.value = "订单处理中...";

    getCreateOrderConfigId();
    HttpUtils.post(
      APIs.createOrderv2,
      {
        "pay": currentPayMethod == 'yeepay' ? 'wxpay' : currentPayMethod,
        "config_id": createOrderConfigId,
        "support_pays": payData.paySupport,
      },
      success: (data) {
        byDebugPrint(data["data"], tag: "创建支付订单:");
        orderId = data["data"]["id"];
        //拉起支付
        pullUpPayment(data["data"]);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        isLoading.value = false;
      },
    );
  }

  ///字数包订单查询
  void queryWordPackageOrder({
    void Function()? onSuccess,
    void Function()? onFailed,
    int retryCount = 0,
    String? receiptData,
  }) {
    Map<String, dynamic> params = {
      "id": orderId,
    };

    if (Platform.isIOS && receiptData != null) {
      params["receipt_data"] = receiptData;
    }
    if (retryCount > 2 && Platform.isAndroid) {
      showConfirmDialog();
      onFailed?.call();
      return;
    }
    isLoading.value = true;
    loadingText.value = "订单查询中...";
    print("字数包orderId: $orderId");
    HttpUtils.post(
      APIs.queryOrder,
      params,
      success: (data) {
        byDebugPrint(data["data"], tag: "订单状态:");
        final status = data["data"]["order_status"] ?? "";
        if (status == 'SUCCESS') {
          isLoading.value = false;
          onSuccess?.call();
          if (Platform.isIOS) {
            eventBus.fire(const IosProductBuySuccessEvent());
          }
          else {
            closePageAndJumpToSuccessPage();
          }
        } else if (status == 'FAIL') {
          isLoading.value = false;
          onFailed?.call();
        } else {
          Future.delayed(const Duration(seconds: 3)).then((value) {
            if (Platform.isIOS) {
              queryWordPackageOrder(receiptData: receiptData);
            } else if (Platform.isAndroid) {
              queryWordPackageOrder(
                  onSuccess: onSuccess,
                  onFailed: onFailed,
                  retryCount: retryCount + 1);
            }
          });
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        isLoading.value = false;
      },
    );
  }

  ///订单拉起支付
  void pullUpPayment(data) async {
    if (Platform.isAndroid) {
      isLoading.value = false;
      if (data["call_method"] == "wxpay") {
        WxPayOrderBean payOrderBean = WxPayOrderBean.fromJson(data);
        eventBus.fire(ShareDataEvent());
        PaymentUtil().wxPay(payOrderBean);
      } else if (data["call_method"] == "wxpay_mini") {
        YeepayPayOrderBean payOrderBean = YeepayPayOrderBean.fromJson(data);
        isYeepayException.value = true;
        eventBus.fire(ShareDataEvent());
        PaymentUtil().wxMiniProgramPay(payOrderBean);
      } else if (data["call_method"] == "alipay") {
        AliPayOrderBean aliPayOrderBean = AliPayOrderBean.fromJson(data);
        PaymentUtil().aliPay(aliPayOrderBean);
      }
    } else if (Platform.isIOS) {
      buyIosProductData(orderId);
    }
  }

  ///购买ios产品
  buyIosProductData(String orderId) async {
    if (createIosOrderAppleVipId.isEmpty) {
      BotToast.showText(text: "未查找到商品，请重试");
      isLoading.value = false;
      return;
    }
    // isLoading.value = false;
    await iosBuyEngin.loadProductDataAndBuy(createIosOrderAppleVipId, orderId);
  }

  ///ios补单
  void iosRepair({
    void Function()? onSuccess,
  }) {
    Get.log("===点击恢复购买");
    String receiptData = SpUtil.getString("ios_last_server_verification") ?? "";
    HttpUtils.post(APIs.iosRepair, {
      "receipt_data": receiptData,
    }, success: (json) {
      Get.log("===ios补单返回来的数据===  $json");
      onSuccess?.call();
    }, fail: (code, msg) {
      BotToast.showText(text: msg);
    });
  }

  /// 订阅支付结果
  void subscribePayResult() {
    if (Platform.isAndroid) {
      // 微信支付结果
      PaymentUtil().subscribeWXPayResp(
        Get.context!,
        onSuccess: () {
          isYeepayException.value = false;
          // 支付成功,查询订单状态
          if (tabCurrentIndex.value == 0) {
            queryVipOrder();
          } else {
            queryWordPackageOrder();
          }
        },
        onFailure: () {
          Get.log("支付失败或取消");
          if(tabCurrentIndex.value == 0){
            showRetainDialog(true);
          }
          isLoading.value = false;
        },
        onError: () {
          BotToast.showText(text: "支付异常");
          isLoading.value = false;
        },
      );

      // 支付宝支付结果
      PaymentUtil().subscribeAliPayResp(
        Get.context!,
        onSuccess: () {
          // 支付成功,查询订单状态
          if (tabCurrentIndex.value == 0) {
            queryVipOrder();
          } else {
            queryWordPackageOrder();
          }
        },
        onFailure: () {
          if(tabCurrentIndex.value == 0){
            showRetainDialog(true);
          }
          Get.log("支付失败或取消");
          isLoading.value = false;
        },
        onError: () {
          BotToast.showText(text: "支付异常");
          isLoading.value = false;
        },
      );
    } else if (Platform.isIOS) {
      ///ios支付结果
      _iosPaySuccessSubscription =
          eventBus.on<QueryIosOrderEvent>().listen((event) {
        if (tabCurrentIndex.value == 0) {
          queryVipOrder(receiptData: event.serverVerificationData);
        } else {
          queryWordPackageOrder(receiptData: event.serverVerificationData);
        }
      });
      _iosBuyStreamSubscription =
          eventBus.on<IosProductBuySuccessEvent>().listen((e) {
        print('__________iOS监听订单');
        closePageAndJumpToSuccessPage();
      });
    }
  }

  ///展示挽留弹窗
  Future<void> showRetainDialog(bool isFailed) async {
    final result = await Get.dialog<dynamic>(
      const MemberRetainDialog(
        type: MemberRetainType.payFailed_9_0_1,
      ),
    );
    if (result == "true") {
      isRetainPay.value = true;
      packageBuy();
    }
  }

  ///支付成功关闭当前页跳转支付成功页
  void closePageAndJumpToSuccessPage() {
    DataService.onEvent('pay_succuss', {'type': tabCurrentIndex.value == 0 ? 'vip' : 'words_package', 'channel': currentPayMethod, 'source': source});
    EventTracking.reportDataPoint(
        pageTag: 'member_page_payment_success',
        operateType: '',
        funcDetailTag: landingPage,
        funcDetailImg: '',
        extra: {'pay_page_id': pagePageID, 'vip_id': getPackageID(), 'pay_type': (isRetainPay.value || isSecondRetainPay.value) ? 1 : 2});
    eventBus.fire(const RefreshFakeChapter());
    /// 充值成功更新用户信息
    Get.find<UserController>().reloadUserInfo(
      successAction: (userInfo) {
        ///iOS平台游客开通vip时跳转至手机绑定页面
        if ((Platform.isIOS || isBackHome) && userInfo!.isFormal == 0) {
          Get.find<UserController>().checkPreLogin(
            binbing: true,
            showClose: false,
            actionCallback: () {
              closeAndBack();
          });
        }
      },
    );
    print('__________支付成功跳转支付成功落地页');
    String paySuccessShowType = Get.find<UserController>().paySuccessShowType;

    if(paySuccessShowType=="1" && !isBackHome){
      submitEvent();
      Get.back();
      ///加v
      Get.dialog(AddWechatDialog(
        wechatUrl:  Get.find<UserController>().strategyAddVUrl,
      ));
      return;
    }

    if(paySuccessShowType=="2"){
      /// 这里新增 跳转加v  跳转到支付成功页面
      Get.offNamed(Routes.memberPaySuccess,
          arguments: {'isBackHome': isBackHome});
    }
  }

  ///上报未支付积分订单
  submitEvent(){
    eventBus.fire(const RefreshHalfPriceWordCountPackageEvent());
    String id  = Get.find<UserController>().integralPackageId;
    /// 检查积分套餐ID是否为空
    if (id.isEmpty) {
      print('积分套餐ID为空，跳过获取');
      return;
    }
    HttpUtils.post(
      NovelApis.submitEvent,
      {
        "id": id, ///套餐id，即超级配置获取到的折扣套餐的id，当event=after_pay_not时必填
        "event": "after_pay_not" ///事件 not_pay=支付页未支付的事件  after_pay_not=支付后强付费套餐事件
      },
      success: (data) {
        Get.log("====上报未支付积分订单=== $data");
      },
      fail: (code, msg) {
      },
    );
  }


  ///订单查询失败，展示确认弹窗
  void showConfirmDialog() {
    isYeepayException.value = false;
    isLoading.value = false;
    Get.dialog(
      ConfirmDialog(
        title: '确认失败',
        content: '获取订单失败，如果已支付请点击联系客服解决问题',
        confirmText: '联系客服',
        onConfirm: () {
          ByNavRouterUtils.jumpWebViewPage(
              Get.context!, '在线客服', payData.vipPageBean?.kfUrl ?? '');
        },
        onCancel: () {},
      ),
    );
  }

  /// 取消订阅支付结果
  void cancelSubscribePayResult() {
    PaymentUtil().cancelSubscribeWXPayResp();
    PaymentUtil().cancelSubscribeAliPayResp();
  }

  ///付费页关闭逻辑
  Future<void> closePage() async {

    ///vip数据或者字数包套餐数据没有时，异常处理
    if((tabCurrentIndex.value == 1 && payData.wordsPackageList.isEmpty) || (tabCurrentIndex.value == 0 && newVipList.isEmpty)) {
      closeAndBack();
      return;
    }

    ///vip直接退出付费页
    if (userInfo.value?.isVip == 1 || BuildConfig.instance.channelType == ChannelType.huawei) {
      closeAndBack();
    } else {
      ///非vip字数包返回
      if (tabCurrentIndex.value == 1 && userInfo.value?.isVip == 0) {
        Get.back();
        return;
      }
      if(interceptCount >= 2) {
        closeAndBack();
        return;
      }
      EventTracking.reportDataPoint(
        pageTag: 'member_page_retention_dialog',
        operateType: 'view',
        funcDetailTag: landingPage,
        funcDetailImg: '',
        extra: {'pay_page_id': pagePageID, 'vip_id': getPackageID(),});
      final result = interceptCount == 0 ? 
        await Get.bottomSheet(const MemberRetainDialog(type: MemberRetainType.cancelPay_9_0_6,),
          isDismissible: false,
          isScrollControlled: true,
          enableDrag: false
        ) : 
        await Get.dialog<dynamic>(const MemberRetainDialog(type: MemberRetainType.cancelPaySecond_9_0_2,),
          barrierDismissible: false,
        );
      if (result == "true") {
        if(interceptCount == 0) {
          isRetainPay.value = true;
        }
        else {
          isSecondRetainPay.value = true;
        }
        interceptCount ++;
        packageBuy();
      } else if (result == "break") {

      } else {
        if(showSKUDialog!){
          showSKUDialog = false;
          interceptCount ++;
          return;
        }
        final int hasCache = ByStorageUtils.getInt(Consts.kCancelPaySecondTime) ?? 0;
        ///超级配置中无挽留弹窗
        if(Get.find<UserController>().paybackURL.isEmpty) {
          closeAndBack();
          return;
        }
        ///二次挽留弹窗已经超时
        if (hasCache > 0) {
          final int timeDiff = DateTime.now().millisecondsSinceEpoch -
              hasCache -
              Consts.kCancelPaySecondTimeDuration;
          if (timeDiff >= 0) {
            closeAndBack();
            return;
          }
        } 
        ///二次弹窗关闭
        if(interceptCount > 0) {
          ///第一次关闭时存储
          if(hasCache == 0) {
            final int time = DateTime.now().millisecondsSinceEpoch;
            ByStorageUtils.saveInt(Consts.kCancelPaySecondTime, time);
          }
          final bool isRegister = Get.isRegistered<HomeController>();
          if(isRegister) {
            final HomeController home = Get.find<HomeController>();
            ///当前无弹窗，并且用户没有手动关闭时修改值
            if(home.showCancelPaySecondTime.value == 0) {
              home.showCancelPaySecondTime.value = 1;
            }
          }
          closeAndBack();
        }
      }
      interceptCount ++;
    }
  }

  ///关闭返回
  void closeAndBack() {
    if (isBackHome) {
      Get.offAllNamed(Routes.main);
    } else {
      Get.back();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    if (Platform.isIOS) {
      _iosBuyStreamSubscription.cancel();
      _iosPaySuccessSubscription.cancel();
    } else if (Platform.isAndroid) {
      cancelSubscribePayResult();
    }
    fireQueryNotPayOrderEvent();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (state == AppLifecycleState.resumed) {
        if (isYeepayException.value && !(Get.isDialogOpen ?? false)) {
          isYeepayException.value = false;
          isLoading.value = false;
          Get.dialog(
            ConfirmDialog(
              title: '支付确认',
              content: '支付成功，请点击【已支付】\n如未支付成功，请点击【取消】',
              confirmText: '已支付',
              onConfirm: () {
                // 确认已支付，查询订单状态
                if (tabCurrentIndex.value == 0) {
                  queryVipOrder();
                } else {
                  queryWordPackageOrder();
                }
              },
              onCancel: () {},
            ),
          );
        }
      }
    });
  }

  /// 是否允许创建订单
  bool canCreateOrder() {
    var value = false;
    LaunchInfoBean? launchInfoBean = Get.find<LaunchController>().launchInfo;

    if (launchInfoBean?.isVip == 0) {
      if (launchInfoBean?.isFormal == 1) {
        value = true;
      } else {
        /// 允许游客购买
        if (launchInfoBean?.verConfig.allowTouristsVip == 1) {
          value = true;
        } else {
          value = false;
        }
      }
    } else {
      value = true;
    }
    if (!value) {
      ///登录界面
      OneKeyManager.onekeyLogin(source: 'pay');
    }
    return value;
  }


  void fireQueryNotPayOrderEvent(){
    eventBus.fire(const QueryNotPayOrderEvent());
  }
}
