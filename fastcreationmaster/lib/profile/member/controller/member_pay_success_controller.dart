/*
 * @Author: cold-x
 * @Date: 2025-08-20 20:00:54
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-28 10:29:14
 * @FilePath: /fastcreationmaster/lib/profile/member/controller/member_pay_success_controller.dart
 * @Description: 
 */
import 'dart:io';
import 'package:alipay_kit/alipay_kit.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_common/by_common_utils.dart';
import 'package:byhy_app_common_utils/app_common/event/common_event.dart';
import 'package:byhy_app_common_utils/app_http/apis.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:byhy_app_common_utils/app_purchase/wechat_buy_engine/ali_pay_order_bean.dart';
import 'package:byhy_app_common_utils/app_purchase/wechat_buy_engine/bug_engine.dart';
import 'package:byhy_app_common_utils/app_purchase/wechat_buy_engine/wx_pay_model.dart';
import 'package:byhy_app_common_utils/app_purchase/wechat_buy_engine/wx_yeepay_order_bean.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/core/network/novel_apis.dart';
import 'package:fast_creation_master/core/widget/view/loading_dialog.dart';
import 'package:fast_creation_master/global/routes/app_pages.dart';
import 'package:fast_creation_master/home/main_page/bean/home_novel_bean.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:wechat_kit/wechat_kit.dart';
import '../../../core/cache/global_controller.dart';
import '../../../core/service/data_service.dart';
import '../../../global/launch/controller/launch_controller.dart';
import '../../../global/other/event_tracking/event_tracking.dart';
import '../../../global/routes/routes_utils.dart';
import '../../../home/share_sales/reward/reward_controller.dart';
import '../dialog/confirm_dialog.dart';
import '../dialog/pay_operation_dialog.dart';
import 'dart:async';
import 'package:byhy_app_common_utils/app_purchase/ios_purchase/ios_buy_engine.dart';
import 'package:fast_creation_master/profile/member/beans/integral_pay_list_bean.dart';

import '../page/member_pay_success_page_ex.dart';

class MemberPaySuccessController extends GetxController with WidgetsBindingObserver {
  ///广场列表
  RxList<HomeNovelBean> itemList = <HomeNovelBean>[].obs;
  List<HomeNovelBean> skeletonizerData = [];

  ///运营banner
  RxList<BannerBean> bannerList = <BannerBean>[].obs;

  ///是否直接返回首页
  bool isBackHome = false;

  ///是否展示过运营弹窗
  bool isShowDialog = false;

  MemberPaySuccessController({this.isBackHome = false});

  String paySupport = Platform.isAndroid ? "wxpay,alipay,yeepay" : "apple";

  ///积分套餐详情
  IntegralPayListBean? integralPackage;

  /// 可用的字数包支付方式列表
  List<Map<String, dynamic>> wordPackagePayMethodBeans = [];

  /// 当前选中的支付方式
  String currentPayMethod = Platform.isAndroid ? "wxpay" : "apple";

  /// 当前选中的字数包支付方式索引
  RxInt currentWordPackagePayMethodIndex = 0.obs;

  /// 创建订单config_id
  int createOrderConfigId = 0;

  /// 创建ios订单appleVipId
  String createIosOrderAppleVipId = "";

  ///订单id
  String orderId = "";

  /// 是否正在加载
  RxBool isLoading = false.obs;

  ///加载文案
  RxString loadingText = "订单处理中...".obs;

  ///Ios支付工具
  IosBuyEngin iosBuyEngin = IosBuyEngin();

  ///苹果支付成功后查询订单状态的监听
  late StreamSubscription _iosPaySuccessSubscription;

  late StreamSubscription _iosBuyStreamSubscription;

  ///易宝异常状态
  RxBool isYeepayException = false.obs;

  final UserController userController = Get.find<UserController>();

  ///是否购买了积分
  bool isBuyPoints = false;
  ///协议是否阅读
  RxBool agreementChecked = false.obs;

  ///付费页数据
  PayData payData = Get.find<PayData>();

  /// 埋点相关
  final landingPage = Get.find<LaunchController>().launchInfo?.verConfig.landingPage ?? '';
  final pagePageID = GlobalController.instance.pay.payPageID;

  /// 协议是否阅读
  void agreementCheckedChanged(bool value) {
    agreementChecked.value = value;
    update();
  }


  @override
  void onInit() {
    super.onInit();
    fetchNovelList();
    loadBanners(postion: 103);
    getIntegralPackage();

    EventTracking.reportDataPoint(
                      pageTag: 'member_page_become_member_dialog',
                      operateType: 'view',
                      funcDetailTag: landingPage,
                      funcDetailImg: '',
                      extra: {
                        'pay_page_id': pagePageID,
                      });

    ///iOS支付初始化
    if (Platform.isIOS) {
      iosBuyEngin.initializeInAppPurchase();
      iosBuyEngin.onPayStatus = (status) {
        if (
            status == PurchaseStatus.restored ||
            status == PurchaseStatus.error ||
            status == PurchaseStatus.canceled) {
          isLoading.value = false;
          LoadingDialog().dismiss();
        } else if (status == PurchaseStatus.pending) {
          isLoading.value = true;
          loadingText.value = '等待支付中...';
        }
      };
    }

    WidgetsBinding.instance.addObserver(this);

    ///监听支付结果
    subscribePayResult();
  }

  ///跳转运营位弹窗
  void gotoDialog() {
    if (isShowDialog) {
      return;
    }
    final UserController userController = Get.find<UserController>();
    if ((userController.payDialogType != 100 ||
            userController.payDialogType != 101) &&
        userController.payDialogBean != null) {
      isShowDialog = true;
      Get.bottomSheet(
          PayOperationDialog(
            bean: userController.payDialogBean!,
            type: userController.payDialogType,
          ),
          enableDrag: false,
          isScrollControlled: true);
      DataService.onEvent('banner_click', {'source': 'payment_dialog'});
    }
  }

  ///获取创作广场列表页
  void fetchNovelList({
    bool? showLoading = true,
    void Function()? onSuccess,
  }) {
    HttpUtils.get(
      NovelApis.homeNovelList,
      {'page': 1, 'page_size': 10},
      success: (data) {
        if (data['status'] == 200) {
          final List items = data["data"]['data'] ?? [];
          List<HomeNovelBean> beans = List<HomeNovelBean>.from(items.map(
            (ele) => HomeNovelBean.fromJson(ele),
          ));
          itemList.value = beans;
          onSuccess?.call();
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
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
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///关闭页面
  bool _isClosed = false;
  void closePage() {
    if (_isClosed) return;
    // 触发二次付费引导（从支付成功页离开时）
    // userController.triggerSecondPayGuide();
    _isClosed = true;
    if (isBackHome) {
      Get.offAllNamed(Routes.main);
    } else {
      Get.back();
    }
  }

  ///获取支付成功后的积分套餐
  void getIntegralPackage() {
    String id  = Get.find<UserController>().integralPackageId;
    /// 检查积分套餐ID是否为空
    if (id.isEmpty) {
      print('积分套餐ID为空，跳过获取');
      return;
    }

    HttpUtils.get(
      NovelApis.getHappyById,
      {
        'id': id,
        'support_pays': Platform.isAndroid ? "wxpay,alipay,yeepay" : "apple",
        'ver': 2,
      },
      success: (data) {
        final infoData = data['data']['info'];
        integralPackage = IntegralPayListBean.fromJson(infoData);
        // 处理支付方式
        if (Platform.isAndroid) {
          final payConfig = data['data']['pays'];
          _processPayMethods(payConfig);
        }

        update();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 处理字数包支付方式
  void _processPayMethods(Map<String, dynamic> payConfig) {
    wordPackagePayMethodBeans.clear();
    payConfig.forEach((key, value) {
      if (value == 1) {
        _addPayMethod(key);
      }
    });

    // 设置默认支付方式
    if (wordPackagePayMethodBeans.isNotEmpty) {
      currentWordPackagePayMethodIndex.value = 0;
      currentPayMethod = wordPackagePayMethodBeans.first["payNameKey"];
    }
  }

  /// 添加支付方式
  void _addPayMethod(String payType) {
    print("===payType=== $payType");
    switch (payType) {
      case "wxpay":
        wordPackagePayMethodBeans.add({
          "payName": "微信支付",
          "icon": "assets/profile/member/member_3.png",
          "payNameKey": "wxpay",
        });
        break;
      case "alipay":
        wordPackagePayMethodBeans.add({
          "payName": "支付宝支付",
          "icon": "assets/profile/member/member_4.png",
          "payNameKey": "alipay",
        });
        break;
      case "yeepay":
      // 检查是否已经添加了微信支付
        bool hasWxPay = wordPackagePayMethodBeans
            .any((bean) => bean["payNameKey"] == "wxpay");
        if (!hasWxPay) {
          wordPackagePayMethodBeans.add({
            "payName": "微信支付",
            "icon": "assets/profile/member/member_3.png",
            "payNameKey": "yeepay",
          });
        }
        break;
    }
  }

  /// 切换支付方式
  void switchPayMethod(int index) {
    currentWordPackagePayMethodIndex.value = index;
    currentPayMethod = wordPackagePayMethodBeans[index]["payNameKey"];
    update();
  }

  ///创建字数包订单
  Future<void> createWordPackageOrder() async {
    if (!agreementChecked.value) {
      Get.dialog(const MemberAgreeDialogEx());
      return;
    }

    if (integralPackage == null) {
      BotToast.showText(text: "套餐信息未加载，请稍后再试");
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

    LoadingDialog().show(message:  loadingText.value);
    getCreateOrderConfigId();

    ///创建订单上报
    DataService.onEvent('pay_create_order', {
      'source': 'pay_success_page',
      'type': 'words_package',
      'channel': currentPayMethod
    });

    HttpUtils.post(
      APIs.createOrderv2,
      {
        "pay": currentPayMethod == 'yeepay' ? 'wxpay' : currentPayMethod,
        "config_id": createOrderConfigId,
        "support_pays": Platform.isAndroid ? "wxpay,alipay,yeepay" : "apple",
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
        LoadingDialog().dismiss();

      },
    );
  }

  ///获取创建订单config_id和AppleVipId
  void getCreateOrderConfigId() {
    if (integralPackage != null) {
      createOrderConfigId = integralPackage!.id;
      if (Platform.isIOS) {
        createIosOrderAppleVipId = integralPackage!.appleVipId;
      }
    }
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
    HttpUtils.post(
      APIs.queryOrder,
      params,
      success: (data) {
        byDebugPrint(data["data"], tag: "订单状态:");
        final status = data["data"]["order_status"] ?? "";
        if (status == 'SUCCESS') {
          isLoading.value = false;
          onSuccess?.call();
          handlePaySuccess();
        } else if (status == 'FAIL') {
          isLoading.value = false;
          onFailed?.call();
          LoadingDialog().dismiss();
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
    await iosBuyEngin.loadProductDataAndBuy(createIosOrderAppleVipId, orderId);
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
          queryWordPackageOrder();
        },
        onFailure: () {
          Get.log("支付失败或取消");
          isLoading.value = false;
          LoadingDialog().dismiss();

        },
        onError: () {
          BotToast.showText(text: "支付异常");
          isLoading.value = false;
          LoadingDialog().dismiss();
        },
      );

      // 支付宝支付结果
      PaymentUtil().subscribeAliPayResp(
        Get.context!,
        onSuccess: () {
          // 支付成功,查询订单状态
          queryWordPackageOrder();
        },
        onFailure: () {
          Get.log("支付失败或取消");
          isLoading.value = false;
          LoadingDialog().dismiss();
        },
        onError: () {
          BotToast.showText(text: "支付异常");
          isLoading.value = false;
          LoadingDialog().dismiss();
        },
      );
    } else if (Platform.isIOS) {
      ///ios支付结果
      _iosPaySuccessSubscription =
          eventBus.on<QueryIosOrderEvent>().listen((event) {
            queryWordPackageOrder(receiptData: event.serverVerificationData);
          });
      _iosBuyStreamSubscription =
          eventBus.on<IosProductBuySuccessEvent>().listen((e) {
            // print('__________iOS监听订单');
            // handlePaySuccess();
          });
    }
  }

  /// 处理支付成功
  void handlePaySuccess() {
    DataService.onEvent('pay_succuss', {
      'type': 'words_package',
      'channel': currentPayMethod,
      'source': 'pay_success_page'
    });
    isBuyPoints = true;
    /// 充值成功更新用户信息
    Get.find<UserController>().reloadUserInfo();
    LoadingDialog().dismiss();
    // if (Platform.isIOS) {
    //   eventBus.fire(const IosProductBuySuccessEvent());
    // }
    // 显示支付成功提示
    BotToast.showText(text: "购买成功");
    Get.offAllNamed(Routes.main);

    // if(Platform.isAndroid){
    //   Get.back();
    // }
    //
    // if(Platform.isIOS){
    //   Get.back();
    //   Get.back();
    // }
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
          // 这里可以跳转到客服页面
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

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    if (Platform.isIOS) {
      _iosBuyStreamSubscription.cancel();
      _iosPaySuccessSubscription.cancel();
    } else if (Platform.isAndroid) {
      cancelSubscribePayResult();
    }
    submitEvent();
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
                queryWordPackageOrder();
              },
              onCancel: () {},
            ),
          );
        }
      }
    });
  }

  ///上报未支付积分订单
  submitEvent(){
    eventBus.fire(const RefreshHalfPriceWordCountPackageEvent());
    if(isBuyPoints==false){
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
          eventBus.fire(const RefreshHalfPriceWordCountPackageEvent());
          Get.log("====上报未支付积分订单=== $data");
        },
        fail: (code, msg) {
        },
      );
    }
  }
}

class RefreshHalfPriceWordCountPackageEvent{
  const RefreshHalfPriceWordCountPackageEvent();
}
