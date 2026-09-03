import 'dart:async';
import 'dart:io';
import 'package:alipay_kit/alipay_kit.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_common/by_common_utils.dart';
import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:byhy_app_common_utils/app_common/event/common_event.dart';
import 'package:byhy_app_common_utils/app_http/apis.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:byhy_app_common_utils/app_purchase/ios_purchase/ios_buy_engine.dart';
import 'package:byhy_app_common_utils/app_purchase/wechat_buy_engine/ali_pay_order_bean.dart';
import 'package:byhy_app_common_utils/app_purchase/wechat_buy_engine/bug_engine.dart';
import 'package:byhy_app_common_utils/app_purchase/wechat_buy_engine/wx_pay_model.dart';
import 'package:byhy_app_common_utils/app_purchase/wechat_buy_engine/wx_yeepay_order_bean.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:wechat_kit/wechat_kit.dart';
import '../../../core/cache/global_controller.dart';
import '../../../core/controller/user_controller.dart';
import '../../../core/network/novel_apis.dart';
import '../../../core/service/data_service.dart';
import '../../../core/widget/view/loading_dialog.dart';
import '../../../global/routes/app_pages.dart';
import '../../../home/first_create/fake_chapter_list_view.dart';
import '../../../home/main_page/bean/not_pay_order_info_model.dart';
import '../../../home/main_page/bean/not_pay_order_model.dart';
import '../../../home/share_sales/reward/reward_controller.dart';
import '../../../square/add_wechat_dialog.dart';
import '../controller/member_pay_success_controller.dart';
import '../dialog/confirm_dialog.dart';

class NotPayOrderWidget extends StatefulWidget {
  final NotPayOrderParams notPayOrderParams;
  final VoidCallback closeNotPayOrderEvent;
  const NotPayOrderWidget({
    super.key,
    required this.notPayOrderParams,
    required this.closeNotPayOrderEvent,
  });

  @override
  State<NotPayOrderWidget> createState() => _NotPayOrderWidgetState();
}

class _NotPayOrderWidgetState extends State<NotPayOrderWidget> {
  late Duration _duration;
  Timer? _timer;
  int _milliseconds = 0;
  bool _showMilliseconds = true;
  int _beginTime = 0;
  late NotPayOrderParams notPayOrderParams;
  NotPayOrderInfoData? notPayOrderInfoData;

  /// 当前选中的支付方式
  String currentPayMethod = Platform.isAndroid ? "wxpay" : "apple";

  /// 创建订单config_id
  int createOrderConfigId = 0;

  /// 创建ios订单appleVipId
  String createIosOrderAppleVipId = "";

  String paySupport = Platform.isAndroid ? "wxpay,alipay,yeepay" : "apple";

  ///Ios支付工具
  IosBuyEngin iosBuyEngin = IosBuyEngin();

  /// 是否正在加载
  RxBool isLoading = false.obs;

  ///加载文案
  RxString loadingText = "订单处理中...".obs;

  ///订单id
  String orderId = "";

  ///付费页数据
  PayData payData = Get.find<PayData>();

  ///苹果支付成功后查询订单状态的监听
  late StreamSubscription _iosPaySuccessSubscription;

  late StreamSubscription _iosBuyStreamSubscription;

  final userInfo = Get.find<UserController>().userInfoBean;

  ///刷新未支付订单事件
  late StreamSubscription<RefreshNotPayOrderEvent> queryNotPayOrderEventSub;



  @override
  void initState() {
    super.initState();
    initData();
    _startTimer();
    ///监听支付结果
    subscribePayResult();
    ///iOS支付初始化
    if(Platform.isIOS) {
      iosBuyEngin.initializeInAppPurchase();
      iosBuyEngin.onPayStatus = (status) {
        if ( status == PurchaseStatus.restored || status == PurchaseStatus.error || status == PurchaseStatus.canceled) {
          isLoading.value = false;
          LoadingDialog().dismiss();
        } else if (status == PurchaseStatus.pending) {
          isLoading.value = true;
          loadingText.value = '等待支付中...';
        }
      };
    }

    queryNotPayOrderEventSub = eventBus.on<RefreshNotPayOrderEvent>().listen((e){
      Get.log("===刷新订单===");
      notPayOrderParams = e.notPayOrderParams;
      getBeginTime();
      _duration = _getRemain();
      getOrderInfoById();
    });
  }



  ///初始化数据
  initData() {
    notPayOrderParams = widget.notPayOrderParams;
    getBeginTime();
    _duration = _getRemain();
    getOrderInfoById();
  }

  ///获取开始时间
  void getBeginTime() {
    DateTime beginDateTime = DateTime.fromMillisecondsSinceEpoch(notPayOrderParams.createdAt * 1000);
    _beginTime = beginDateTime.millisecondsSinceEpoch;
    Get.log("===开始时间=== $beginDateTime");
  }

  ///获取结束时间
  Duration _getRemain() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final timeDiff = _beginTime + 15 * 60 * 1000 - now;
    Duration tmpDur = Duration(milliseconds: timeDiff);
    if (tmpDur.isNegative) {
      widget.closeNotPayOrderEvent();
    }
    return tmpDur.isNegative ? Duration.zero : tmpDur;
  }

  void _startTimer() {
    _timer?.cancel();

    /// 如果显示毫秒，则每50毫秒更新一次，否则每秒更新一次
    final interval = _showMilliseconds
        ? const Duration(milliseconds: 50)
        : const Duration(seconds: 1);

    _timer = Timer.periodic(interval, (timer) {
      setState(() {
        _duration = _getRemain();
        if (_showMilliseconds) {
          _milliseconds = (1000 - DateTime.now().millisecond) % 1000;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _iosPaySuccessSubscription.cancel();
    _iosBuyStreamSubscription.cancel();
    queryNotPayOrderEventSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_duration.inSeconds % 60).toString().padLeft(2, '0');
    final milliseconds =
        (_milliseconds / 10).floor().toString().padLeft(2, '0');
    return GestureDetector(
        onTap: () {
          createVipOrder();
        },
        child: Stack(
          children: [
            SizedBox(height: 82.h),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                width: 1.sw,
                height: 32.w,
                decoration: BoxDecoration(
                  color: Color(0XFFFFD3D3),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 5.w,
                    ),
                    Image.asset(
                      "assets/home/commercialize/order_not_pay.png",
                      width: 29.w,
                      height: 23.w,
                      fit: BoxFit.fill,
                    ),
                    SizedBox(
                      width: 4.w,
                    ),
                    Text(
                      "您有一个订单",
                      style: TextStyle(
                        color: Color(0XFF222222),
                        fontSize: 14.sp,
                      ),
                    ),
                    Text(
                      "未支付",
                      style: TextStyle(
                        color: Color(0XFFFE5024),
                        fontSize: 14.sp,
                      ),
                    ),
                    _buildTimeBox(minutes),
                    _buildSeparator(),
                    _buildTimeBox(seconds),
                    if (_showMilliseconds) ...[
                      _buildSeparator(),
                      _buildTimeBox(milliseconds),
                    ],
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        ///todo 关闭15分钟未支付订单
                        widget.closeNotPayOrderEvent();
                      },
                      child: Image.asset(
                        "assets/home/commercialize/order_not_pay_close.png",
                        width: 20.w,
                        height: 20.w,
                        fit: BoxFit.fill,
                      ),
                    ),
                    SizedBox(
                      width: 7.w,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildTimeBox(String time) {
    return Container(
      width: 20.w,
      height: 20.w,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.w),
      ),
      alignment: Alignment.center,
      child: Text(
        time,
        style: TextStyle(
          color: Color(0XFF222222),
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        ':',
        style: TextStyle(
          color: const Color(0XFF222222).withOpacity(0.4),
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  ///查询未支付订单相关信息
  void getOrderInfoById() {
    HttpUtils.get(
      NovelApis.getOrderInfoById,
      {
        "id":notPayOrderParams.orderId
      },
      showMsgWhenFailed: false,
      success: (data) {
        if(data["data"]!=null){
          notPayOrderInfoData = NotPayOrderInfoData.fromJson(data['data']);
        }
        Get.log("===查询未支付订单相关信息===$data");
      },
    );
  }


  ///创建vip订单
  Future<void> createVipOrder() async {
    String currentPayMethod = "";
    int? vipConfigVersionId;
    int? payPageId;
    if(notPayOrderInfoData!=null){
      currentPayMethod = notPayOrderInfoData!.pay;
      createOrderConfigId = notPayOrderInfoData!.configId;
      vipConfigVersionId = notPayOrderInfoData!.vipConfigVersionId;
      payPageId = notPayOrderInfoData!.payPageId;
      createIosOrderAppleVipId = notPayOrderInfoData!.appleVipId;
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
    ///没有订单ID
    if(createOrderConfigId == 0){
      return;
    }
    isLoading.value = true;
    loadingText.value = "订单处理中...";
    LoadingDialog().show(message: loadingText.value);
    Get.log("===vip_config_version_id===    $vipConfigVersionId  payPageId===$payPageId");
    HttpUtils.post(
      APIs.iosOrder,
      {
        "pay": currentPayMethod == 'yeepay' ? 'wxpay' : currentPayMethod,
        "config_id": createOrderConfigId,
        "support_pays":paySupport,
        "pay_page_id":payPageId,
        "vip_config_version_id":vipConfigVersionId,
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
        LoadingDialog().dismiss();
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
        // isYeepayException.value = true;
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


  /// 订阅支付结果
  void subscribePayResult() {
    if (Platform.isAndroid) {
      // 微信支付结果
      PaymentUtil().subscribeWXPayResp(
        Get.context!,
        onSuccess: () {
          /// 支付成功,查询订单状态
          queryVipOrder();
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
          /// 支付成功,查询订单状态
          queryVipOrder();
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
            queryVipOrder(receiptData: event.serverVerificationData);
          });
      _iosBuyStreamSubscription =
          eventBus.on<IosProductBuySuccessEvent>().listen((e) {
            // closePageAndJumpToSuccessPage();
          });
    }
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
          eventBus.fire(const QueryNotPayOrderEvent());
          if (Platform.isIOS) {
            closePageAndJumpToSuccessPage();
            // eventBus.fire(const IosProductBuySuccessEvent());
          }else{
            closePageAndJumpToSuccessPage();
          }

        } else if (status == "FAIL") {
          isLoading.value = false;
          onFailed?.call();
          LoadingDialog().dismiss();
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
        LoadingDialog().dismiss();
      },
    );
  }

  ///订单查询失败，展示确认弹窗
  void showConfirmDialog() {
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


  ///支付成功关闭当前页跳转支付成功页
  void closePageAndJumpToSuccessPage() {
    DataService.onEvent('pay_succuss', {'type':  'vip' , 'channel': currentPayMethod, 'source': "home"});
    eventBus.fire(const RefreshFakeChapter());
    /// 充值成功更新用户信息
    Get.find<UserController>().reloadUserInfo();
    print('__________支付成功跳转支付成功落地页');
    String paySuccessShowType = Get.find<UserController>().paySuccessShowType;
    LoadingDialog().dismiss();
    if(paySuccessShowType=="1"){
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
          arguments: {'isBackHome': true});
    }

    ///iOS平台游客开通vip时跳转至手机绑定页面
    if (Platform.isIOS && userInfo.value!.isFormal == 0) {
      Get.find<UserController>().checkPreLogin(
          binbing: true,
          actionCallback: () {

          });
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


}

class QueryNotPayOrderEvent {
  const QueryNotPayOrderEvent();
}

///刷新未支付订单事件
class RefreshNotPayOrderEvent{
  final NotPayOrderParams notPayOrderParams;
  const RefreshNotPayOrderEvent({required this.notPayOrderParams});
}
