/*
 * @Author: cold-x
 * @Date: 2025-06-05 10:48:00
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-02-24 19:08:33
 * @FilePath: /fastcreationmaster/lib/home/main_page/controller/home_controller.dart
 * @Description: 
 */

import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_common/aes/byhy_aes_storage_utils.dart';
import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:byhy_app_common_utils/app_common/event/common_event.dart';
import 'package:byhy_app_common_utils/app_http/apis.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:fast_creation_master/core/cache/global_controller.dart';
import 'package:fast_creation_master/global/const/asset_const.dart';
import 'package:fast_creation_master/profile/member/dialog/intercept.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/global/routes/app_pages.dart';
import 'package:fast_creation_master/home/dialog/home_marketing_dialog.dart';
import 'package:fast_creation_master/home/dialog/new_user_dialog.dart';
import 'package:fast_creation_master/home/main_page/bean/home_novel_bean.dart';
import 'package:fast_creation_master/profile/aboutUs/controllers/about_us_controller.dart';
import 'package:fast_creation_master/profile/member/beans/user_info_bean.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../core/cache/daily_cache_manager.dart';
import '../../../core/controller/base_controller.dart';
import '../../../core/controller/base_record_controller.dart';
import '../../../core/network/novel_apis.dart';
import 'package:flutter/widgets.dart';

import '../../../global/const/const.dart';
import '../../../global/other/event_tracking/event_tracking.dart';
import '../../../global/routes/routes_utils.dart';
import '../../../profile/member/controller/member_pay_success_controller.dart';
import '../../../profile/member/widget/not_pay_order_widget.dart';
import '../../long_novel/controller/brief_detail_provider.dart';
import '../../long_novel/page/novel_brief_page.dart';
import 'package:fast_creation_master/core/widget/view/provider_page_tracker.dart';

import '../bean/not_pay_order_model.dart';

class HomeController extends BaseController {
  ///中部工具箱标题
  List<String> toolBoxTitles = ['小说名', '推广文', '写笔名'];

  ///中部工具箱简介
  List<String> toolBoxBriefs = ['5秒定书名', '爆款文案速成', '作家马甲速配'];

  ///中部工具箱背景图标名称
  List<String> toolBoxBgNames = [
    'btn_home_novel_name${AssetConst.springFestival()}.png',
    'btn_home_promote_content${AssetConst.springFestival()}.png',
    'btn_home_pen_name${AssetConst.springFestival()}.png'
  ];

  ///社媒推广标题
  List<String> promotionTitles = ['标题小助手', '推广文案助手', '短视频脚本'];

  ///社媒推广背景图标名称
  List<String> promotionBgNames = [
    'btn_home_title_assistant.png',
    'btn_home_promote_content_assistant.png',
    'btn_home_video_script_assistant.png'
  ];

  RxList<HomeNovelBean> itemList = <HomeNovelBean>[].obs;
  List<HomeNovelBean> skeletonizerData = [];

  ///是否可以弹出营销弹窗
  bool canShowMarketingDialog = false;

  ///控制底部运营条显示状态
  RxBool showBottomOperationView = true.obs;

  ///控制底部运营条是否被手动关闭
  RxBool isBottomOperationClosed = false.obs;

  ///控制气泡一显示状态（不展开的气泡）
  RxBool showBubbleOne = true.obs;

  ///控制气泡二显示状态（展开的气泡）
  RxBool showBubbleTwo = false.obs;

  final userController = Get.find<UserController>();

  UserInfoBean? userInfoBean;

  ///当前进度数据
  RxList<HomeNovelBean> novelProgressList = <HomeNovelBean>[].obs;

  ///当前进度id
  Rx<int> currentID = 0.obs;

  ///当前进度条
  Rx<int> progress = 0.obs;

  ///当前进度条
  Rx<String> progressTitle = ''.obs;

  ///定时器轮循进度
  Timer? _timer;
  bool _isRunning = false;

  ///是否在轮循

  ///banner
  RxList<BannerBean> bannerList = <BannerBean>[].obs;

  ///是否显示banner
  RxBool showBanner = true.obs;

  ///是否显示取消二次付费页拦截弹窗
  RxInt showCancelPaySecondTime = 0.obs;

  late final AboutUsController aboutUs;

  RxBool writeCompleteNovelBanner = true.obs;

  ///底部banner
  BannerBean? bottomBanner ;
  ///底部banner要路由的落地页面
  String? landingPage;

  ///查询是否要展示限时半价得字数包
  RxBool halfPriceWordCountPackage = false.obs;

  late StreamSubscription refreshHalfPriceWordCountPackageEventSub;

  ///查询是否要展示订单未支付小条
  RxBool showOrderNotPay = false.obs;

  ///未支付订单model
  NotPayOrderModel? notPayOrderModel;

  ///监听未支付订单事件
  late StreamSubscription<QueryNotPayOrderEvent> queryNotPayOrderEventSub;



  @override
  void onInit() {
    ///初始化小说骨架数据
    initSkeletonizerData();
    aboutUs = Get.put(AboutUsController());

    fetchNovelList();
    loadBanners(postion: 1);
    loadBottomBanner(postion: 21);

    fetchNovelProgress();

    showCancelPaySecondTime.value = showSecondDialog() ? 1 : 0;
    // bool showNewUserDialog = showNewUserGuideDialog(); ///华为过审暂时隐藏
    bool showNewUserDialog = false;
    ///弹窗
    if (!showNewUserDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        checkUnCompleteNovel(
          failed: () {
            // 添加延迟检查机制，确保从引导页进入首页时能够触发弹窗
            // 只有在ever监听器没有触发的情况下才执行延迟检查
            ///不弹出未完成的小说时才弹此弹窗
            Future.delayed(const Duration(milliseconds: 300), () {
              // 如果用户信息存在但还没有触发过弹窗，则触发弹窗
              if (userController.userInfoBean.value != null &&
                  canShowMarketingDialog == false) {
                userInfoBean = userController.userInfoBean.value;
                canShowMarketingDialog = true;
                checkDialog();
              }
            });
          },
        );
      });
    }
    checkUpdateDiolog();
    ///初始化付费页数据
    GlobalController.instance.pay.getPayStyle();

    refreshHalfPriceWordCountPackageEventSub = eventBus.on<RefreshHalfPriceWordCountPackageEvent>().listen((e){
      getEventStatus();
    });

    queryNotPayOrderEventSub = eventBus.on<QueryNotPayOrderEvent>().listen((e){
      queryNotPayOrder(postRefreshOrder: true);
    });

    getEventStatus();

    queryNotPayOrder();

    EventTracking.reportDataPoint(
        pageTag: 'home',
        operateType: 'view',
        funcDetailTag: '',
        funcDetailImg: '');

    super.onInit();
  }

  @override
  void onClose() {
    // 清理资源
    _stopTimer();
    super.onClose();
  }

  ///显示新用户引导弹窗
  bool showNewUserGuideDialog() {
    ///用户是否去过引导页并登录，之后弹出引导写小说的弹窗
    final int? enteredGuide = ByStorageUtils.getInt(Consts.kUserEnteredGuide);
    final bool isLogin = userController.userInfoBean.value?.isFormal == 1;
    if (enteredGuide == 2) {
      ByStorageUtils.remove(Consts.kUserEnteredGuide);
      if (isLogin && userController.userInfoBean.value!.activeDay! <= 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.dialog(
            useSafeArea: false,
            InterceptView(
            type: InterceptType.guideNewUserWriting,
            action: () {
              Get.back();
              Get.toNamed(Routes.novelCreate)!.then((_) {
                viewDidAppear();
              });
            },
          ));
        });
        return true;
      }
    }
    return false;
  }
  ///检查非vip用户引导页是否有未完成的小说
  void checkUnCompleteNovel({void Function()? failed}) async {
    final shouldShow =
        await DailyManager.shouldShowPopup(Consts.kDailyUncompleteNovel);
    if (shouldShow) {
      HttpUtils.get(
        NovelApis.unCompleteNovel,
        {},
        showMsgWhenFailed: false,
        success: (data) {
          if (data['status'] == 200) {
            final novelID = data['data']['novel_id'];
            if (data['data']['is_show']) {
              // 展示弹窗
              Get.dialog(
                useSafeArea: false,
                InterceptView(
                type: InterceptType.novelContinue,
                action: () {
                  final provider = BriefDetailProvider();
                  ByNavRouterUtils.pushReplacement(
                    Get.context!,
                    trackProviderPage(
                      pageId: '/novel_brief_page',
                      widget: ChangeNotifierProvider(
                        create: (context) => provider,
                        child: NovelBriefPage(
                          novelID: novelID,
                        ),
                      ),
                    ),
                  );
                },
              ));
              // 记录当前日期
              DailyManager.recordPopupDate(Consts.kDailyUncompleteNovel);
            } else {
              failed?.call();
            }
          } else {
            failed?.call();
          }
        },
        fail: (code, msg) => failed?.call(),
      );
    } else {
      failed?.call();
    }
  }

  ///开始轮循
  _startTimer() {
    if (_isRunning) return;
    _timer = Timer.periodic(const Duration(seconds: 20), (timer) {
      fetchNovelProgress();
    });
    _isRunning = true;
  }

  ///结束轮循
  _stopTimer() {
    _timer?.cancel();
    _isRunning = false;
  }

  ///是否显示取消支付二次拦截弹窗后的底部弹窗
  bool showSecondDialog() {
    ///vip用户
    if (userController.userInfoBean.value != null &&
        userController.userInfoBean.value!.isVip != 0) {
      return false;
    }

    ///没有配置挽留弹窗
    if (userController.paybackURL.isEmpty) {
      return false;
    }
    final time = ByStorageUtils.getInt(Consts.kCancelPaySecondTime) ?? 0;
    if (time > 0) {
      final int timeDiff = DateTime.now().millisecondsSinceEpoch -
          time -
          Consts.kCancelPaySecondTimeDuration;
      if (timeDiff < 0) {
        return true;
      }
    }
    return false;
  }

  ///初始化骨架列表数据
  void initSkeletonizerData() {
    // skeletonizerData = List.filled(4, HomeNovelBean.initSkeletonizer());
    skeletonizerData = [];
  }

  ///跳转至对应工具模块
  void jumpToToolModule(int index) {
    CreationType? type;
    switch (index) {
      ///小说名
      case 0:
        type = CreationType.novelName;
        break;

      ///推广文
      case 1:
        type = CreationType.novelPromotion;
        break;

      ///笔名
      case 2:
        type = CreationType.penName;
        break;

      default:
        type = CreationType.novelName;
        break;
    }

    EventTracking.reportDataPoint(
                        pageTag: 'home_showcase',
                        operateType: 'click',
                        funcDetailImg: '',
                        funcDetailTag: '',
                        extra: {'source': index + 1});

    ///跳转至对应的创作记录页面
    Get.toNamed(Routes.toolCreation, arguments: {
      'type': type,
    })!
        .then((_) {
      viewDidAppear();
    });
  }

  ///跳转至对应社媒推广模块
  void jumpToPromotionModule(int index) {
    CreationType? type;
    switch (index) {
      ///标题小助手
      case 0:
        type = CreationType.douyinAssistant;
        break;

      ///推广文案助手
      case 1:
        type = CreationType.xhsAssistant;
        break;

      ///短视频脚本
      case 2:
        type = CreationType.shortVideoScript;
        break;

      default:
        type = CreationType.douyinAssistant;
        break;
    }

    EventTracking.reportDataPoint(
                        pageTag: 'home_showcase',
                        operateType: 'click',
                        funcDetailImg: '',
                        funcDetailTag: '',
                        extra: {'source': index + 4});

    ///跳转至对应的创作记录页面
    Get.toNamed(Routes.toolCreation, arguments: {
      'type': type,
    })!
        .then((_) {
      viewDidAppear();
    });
  }

  ///处理小说进度
  int handleExp(dynamic progress) {
    if (progress is double) {
      return progress.floor();
    }
    if (progress is int) {
      return progress;
    }
    return 0;
  }

  ///主视图出现
  void viewDidAppear() {
    fetchNovelProgress();
  }

  ///获取创作广场列表页
  void fetchNovelList({
    bool? showLoading = true,
    void Function()? onSuccess,
  }) {
    HttpUtils.get(
      NovelApis.homeNovelList,
      {'page': pageHelper.page, 'page_size': pageHelper.row},
      success: (data) {
        if (data['status'] == 200) {
          final List items = data["data"]['data'] ?? [];
          List<HomeNovelBean> beans = List<HomeNovelBean>.from(items.map(
            (ele) => HomeNovelBean.fromJson(ele),
          ));
          if (pageHelper.page == 1) {
            itemList.value = beans;
          } else {
            itemList.addAll(beans);
          }
          pageHelper.addPage();
          final hasMore = beans.length < pageHelper.row ? false : true;
          refreshSuccess(false, hasMore);
          onSuccess?.call();
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///弹窗判断
  void checkDialog() {
    ///新用户弹窗(未登录活跃<=1)
    if (userInfoBean != null &&
        userInfoBean!.isFormal == 0 &&
        userInfoBean!.activeDay! <= 1 &&
        userInfoBean!.isVip == 0) {
      Get.dialog(NewUserDialog());
      return;
    }

    EventTracking.reportDataPoint(
                        pageTag: 'home_pop_up',
                        operateType: 'click',
                        funcDetailImg: '',
                        funcDetailTag: '0',);
    ///付费引导弹窗
    if (userInfoBean?.isVip == 0) {
      Get.dialog(HomeMarketingDialog());
    }
  }

  ///获取所有小说的生成进度
  void fetchNovelProgress({
    void Function()? onSuccess,
  }) {
    HttpUtils.get(
      NovelApis.novelProgress,
      {},
      showMsgWhenFailed: false,
      success: (data) {
        if (data['status'] == 200) {
          final List items = data["data"]['list'] ?? [];
          if (items.isNotEmpty) {
            List<HomeNovelBean> beans = List<HomeNovelBean>.from(items.map(
              (ele) => HomeNovelBean.fromJson(ele),
            ));
            novelProgressList.value = beans;
            currentID.value = data['data']['id'] ?? 0;
            progressTitle.value = data['data']['title'] ?? '';
            progress.value = handleExp(data['data']['progress']);
            _startTimer();
          } else {
            _stopTimer();
            novelProgressList.value = [];
          }
          onSuccess?.call();
        }
      },
      fail: (code, msg) {},
    );
  }

  ///隐藏底部运营条和气泡一，显示气泡二
  void showExpandedBubble() {
    // 先隐藏底部运营条和气泡一
    showBottomOperationView.value = false;
    showBubbleOne.value = false;

    // 减少延迟时间，让气泡二更快出现
    Future.delayed(const Duration(milliseconds: 100), () {
      showBubbleTwo.value = true;
    });
  }

  ///显示底部运营条和气泡一，隐藏气泡二
  void showBottomOperation() {
    // 先隐藏气泡二
    showBubbleTwo.value = false;

    // 延迟显示底部运营条和气泡一，让隐藏动画先开始
    Future.delayed(const Duration(milliseconds: 200), () {
      // 只有在没有被手动关闭的情况下才显示底部运营条
      if (!isBottomOperationClosed.value) {
        showBottomOperationView.value = true;
      }
      showBubbleOne.value = true;
    });
  }

  ///关闭底部运营条
  void closeBottomOperation() {
    isBottomOperationClosed.value = true;
    showBottomOperationView.value = false;
  }

  ///关闭banner
  void closeBanner() {
    showBanner.value = false;
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
        if (bannerList.isNotEmpty) {
          BannerBean bean = beans.first;
          EventTracking.reportDataPoint(
            pageTag: 'banner',
            operateType: 'view',
            funcDetailTag: bean.id.toString(),
            funcDetailImg: bean.imgUrl,
          );
        }
        update();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///展示更新弹窗
  void checkUpdateDiolog() {
    ///获取版本信息
    aboutUs.fetchVersionInfo(
      onSuccess: () async {
        bool upgrade = await aboutUs.checkUpgrade();
        if (upgrade) {
          aboutUs.showUpdateDialog();
        }
      },
    );
  }

  ///关闭写完小说就能赚钱底部弹窗
  void closeWriteCompleteNovelBanner(){
    writeCompleteNovelBanner.value = false;
    update();
  }

  ///获取底部banner
  loadBottomBanner({
    required int postion,
  }) {
    HttpUtils.get(
      APIs.homeBanner,
      {
        "postion": postion,
      },
      showMsgWhenFailed: false,
      success: (data) {
        Get.log("===获取底部bannerEx=== $data  $postion");
        final List bannerData = data["data"]["item"] ?? [];
        List<BannerBean> beans = bannerData.map((e) => BannerBean.fromJson(e)).toList();
        if(beans.isNotEmpty){
          bottomBanner = beans.first;
        }
        if(bottomBanner!=null){
          if(bottomBanner!.type==1||bottomBanner!.type==2){
            getPayStyle(payPageId: bottomBanner!.jumpParam);
          }
        }
        update();
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
      },
    );
  }


  ///拉去banner对应的支付页
  void getPayStyle({void Function()? onSuccess,required String payPageId}) {
    HttpUtils.post(
      APIs.payStyle,
      showMsgWhenFailed: false,
      {
        "pay_page_id":payPageId,
      },
      success: (data) async {
        onSuccess?.call();
        landingPage = data['data']['landing_page'];
        Get.log("===获取支付落地页landing_page===$data");
        if(bottomBanner!=null){
          bottomBanner!.jumpUrl = landingPage??"";
        }
      },
    );
  }

  ///查询是否要展示
  void getEventStatus(){
    HttpUtils.get(
      NovelApis.getEventStatus,
      {
        "event": "after_pay_not",
      },
      showMsgWhenFailed: false,
      success: (data) {
        if(data["data"]!=null){
          if(data["data"]["status"]==1){
            halfPriceWordCountPackage.value = true;
            update();
            Get.log("===查询要展示限时半价=== ${halfPriceWordCountPackage.value}");
          }else if(data["data"]["status"]==2){
            halfPriceWordCountPackage.value = false;
            update();
            Get.log("===查询要展示限时半价=== ${halfPriceWordCountPackage.value}");
          }
        }
        Get.log("===查询订单未支付事件=== $data");
        update();
      },
      fail: (code, msg) {
        // BotToast.showText(text: msg);
      },
    );
  }

  ///关闭底部半价字数包运营小条
  void closeHalfPricePackage(){
    halfPriceWordCountPackage.value = false;
  }

  ///查询是否有未支付订单
  void queryNotPayOrder({ bool postRefreshOrder = false,}){
    HttpUtils.post(
      NovelApis.getToBePaidStatus,
      showMsgWhenFailed: false,
      {
      },
      success: (data) async {
        notPayOrderModel = null;
        notPayOrderModel = NotPayOrderModel.fromJson(data);
        if(notPayOrderModel!=null){
          if(notPayOrderModel!.data.status==1){
            if(postRefreshOrder){
              eventBus.fire(RefreshNotPayOrderEvent(notPayOrderParams: notPayOrderModel!.data.params));
            }
            showOrderNotPay.value = true;
          }else{
            showOrderNotPay.value = false;
          }
        }
        update();
        Get.log("===获取未支付订单信息===$data");
      },
    );
  }

  ///关闭未支付订单小条
  void closeNotPayOrderWidget(){
    showOrderNotPay.value = false;
  }
}
