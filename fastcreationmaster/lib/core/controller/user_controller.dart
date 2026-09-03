import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_common/by_common_utils.dart';
import 'package:byhy_app_common_utils/app_common/event/common_event.dart';
import 'package:byhy_app_common_utils/app_http/apis.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:fast_creation_master/core/service/data_service.dart';
import 'package:fast_creation_master/global/launch/bean/launch_info_bean.dart';
import 'package:fast_creation_master/global/launch/controller/launch_controller.dart';
import 'package:fast_creation_master/global/login/controller/onekey_manager.dart';
import 'package:fast_creation_master/global/routes/app_pages.dart';
import 'package:fast_creation_master/profile/member/beans/pre_login_config_bean.dart';
import 'package:fast_creation_master/profile/member/beans/user_info_bean.dart';
import 'package:fast_creation_master/profile/member/controller/member_center_controller.dart';
import 'package:fast_creation_master/profile/member/page/member_words_package_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../global/const/const.dart';
import '../../global/routes/routes_utils.dart';
import '../../home/long_novel/bean/novel_continue_write_model.dart';
import '../../profile/member/widget/not_pay_order_widget.dart';
import '../cache/cache.dart';
import '../network/novel_apis.dart';

class UserController extends GetxController {
  ///用户信息
  final Rx<UserInfoBean?> userInfoBean = Rx<UserInfoBean?>(null);

  ///是否可以前置登录
  bool isPreLogin = false;

  // 移除初始化时的 launchInfo 获取，改为动态获取
  // final launchInfo = Get.find<LaunchController>().launchInfo;

  /// 存储被前置登录限制的操作回调
  VoidCallback? _pendingActionCallback;

  ///支付挽留弹窗url
  String paybackURL = '';

  ///邀请名称
  String inviteName = "邀请码";

  ///邀请背景图
  String inviteBgUrl = "";

  ///支付成功后的运营弹窗
  BannerBean? payDialogBean;
  int payDialogType = 0;

  /// 展示类型 100图  101视频

  ///添加微信背景图片
  String addWechatBgUrl = "";

  ///新增 写完小说就能赚钱运营位
  String earnMoneyBgUrl = "";

  ///是否进入过付费页
  RxBool isEnterPayPage = false.obs;

  ///是否是vip购买成功后从成功页离开
  bool isVipBuySuccessLeave = false;

  ///二次付费引导显示状态
  RxBool showSecondPayGuide = false.obs;

  ///二次付费引导开始时间
  RxString secondPayGuideStartTime = ''.obs;

  ///支付成功后的积分套餐id
  String integralPackageId = "";

  ///支付后显示类型
  String paySuccessShowType = "1";


  /// 动态获取 launchInfo
  LaunchInfoBean? get launchInfo {
    try {
      return Get.find<LaunchController>().launchInfo;
    } catch (e) {
      print("获取 launchInfo 失败: $e");
      return null;
    }
  }

  List<LongNovelContinue> longNovelContinue = [];

  ///攻略加v跳转url
  String strategyAddVUrl = "";

  ///是否可以尝试
  bool couldTry = false;

  void initInfo() {
    reloadUserInfo();
    preLoginConfig();
    getCommonConfig();
    getCouldUse();

  }

  getUserInfo({
    void Function(UserInfoBean? userInfo)? onSuccess,
  }) {
    HttpUtils.get(
      APIs.loadUserInfo,
      {},
      success: (data) {
        final userInfoData = data["data"];
        UserInfoBean bean = UserInfoBean.fromJson(userInfoData);
        userInfoBean.value = bean;
        onSuccess?.call(bean);
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///更新用户信息
  Future reloadUserInfo(
      {void Function(UserInfoBean? userInfo)? successAction,
      bool reloadUse = true,
      VoidCallback? goBack}) async {
    eventBus.fire(const QueryNotPayOrderEvent());
    await getUserInfo(onSuccess: (userInfo) {
      Get.log("保存用户数据===>${userInfo?.toJson()}");
      if(reloadUse){
        getCouldUse();
      }
      if (goBack != null) {
        goBack();
      }
      if (successAction != null) {
        successAction(userInfo);
      }
    });
  }

  ///清空用户信息
  void clearUserInfo() {
    userInfoBean.value = null;
  }

  /// 获取所有配置
  preLoginConfig({
    void Function()? onSuccess,
  }) {
    HttpUtils.get(
      APIs.getConfig,
      {"group": "xiao_shuo_chuang_zuo_jing_ling"},
      success: (data) {
        byDebugPrint(data, tag: "peizhi11111111111111---");
        final config = data["data"]["deng_lu_qian_zhi"];
        if (config != null && config is! List) {
          PreLoginConfigBean configBean = PreLoginConfigBean.fromJson(config);
          if (configBean.valText == "1") {
            isPreLogin = true;
            update();
          }
        }

        final inviteNameConfig = data["data"]["yao_qing_ming_cheng"];
        if (inviteNameConfig != null && inviteNameConfig is! List) {
          PreLoginConfigBean configBean =
              PreLoginConfigBean.fromJson(inviteNameConfig);
          Get.log("===邀请名称===${configBean.toJson()}");
          if (configBean.valText.isNotEmpty) {
            inviteName = configBean.valText;
            update();
          }
        }

        final inviteBgUrlConfig = data["data"]["yao_qing_bei_jing_tu"];
        if (inviteBgUrlConfig != null && inviteBgUrlConfig is! List) {
          PreLoginConfigBean configBean =
              PreLoginConfigBean.fromJson(inviteBgUrlConfig);
          Get.log("===邀请背景图===${configBean.toJson()}");
          if (configBean.valText.isNotEmpty) {
            inviteBgUrl = configBean.valText;
            update();
          }
        }

        final paybackURLConfig = data["data"]["zhi_fu_wan_liu_tan_chuang"];
        if (paybackURLConfig != null && paybackURLConfig is! List) {
          PreLoginConfigBean configBean =
              PreLoginConfigBean.fromJson(paybackURLConfig);
          Get.log("===支付挽留url===${configBean.toJson()}");
          if (configBean.valText.isNotEmpty) {
            paybackURL = configBean.valText;
            update();
          }
        }

        ///支付成功后的运营弹窗
        try {
          final title = data['data']['zhi_fu_hou_an_niu_wen_an']['val_text'];
          final url = data['data']['zhi_fu_hou_tan_chuang_tu']['val_text'];
          payDialogType = data['data']['zhi_fu_hou_tan_chuang_tu']['val_type'];
          final jumpURL =
              data['data']['zhi_fu_hou_tan_chuang_tiao_zhuan']['val_text'];
          payDialogBean = BannerBean(
              id: 0,
              title: title,
              imgUrl: url,
              jumpUrl: jumpURL,
              jumpParam: '',
              type: 4,

              ///固定跳转至外部链接
              des: '');
        } catch (e) {
          // throw(e);
        }

        final wechatBgUrlConfig = data["data"]["gong_lve_jia_wei_tu"];
        if (wechatBgUrlConfig != null && wechatBgUrlConfig is! List) {
          PreLoginConfigBean configBean =
              PreLoginConfigBean.fromJson(wechatBgUrlConfig);
          Get.log("===微信背景图===${configBean.toJson()}");
          if (configBean.valText.isNotEmpty) {
            addWechatBgUrl = configBean.valText;
            update();
          }
        }

        final earnMoneyBgUrlConfig = data["data"]["AI_guang_chang_chong_zhi"];
        if (earnMoneyBgUrlConfig != null && earnMoneyBgUrlConfig is! List) {
          PreLoginConfigBean configBean =
              PreLoginConfigBean.fromJson(earnMoneyBgUrlConfig);
          Get.log("===首页新增底部背景图===${configBean.toJson()}");
          if (configBean.valText.isNotEmpty) {
            earnMoneyBgUrl = configBean.valText;
            update();
          }
        }

        ///攻略加v跳转url
        final strategyAddVUrlConfig =
            data["data"]["zhu_ye_gong_lve_tan_chuang_jia_V"];
        if (strategyAddVUrlConfig != null && strategyAddVUrlConfig is! List) {
          PreLoginConfigBean configBean =
              PreLoginConfigBean.fromJson(strategyAddVUrlConfig);
          Get.log("===攻略加v跳转url===${configBean.toJson()}");
          if (configBean.valText.isNotEmpty) {
            strategyAddVUrl = configBean.valText;
            update();
          }
        }


        ///套餐id
        final happyByIdConfig =
        data["data"]["zhi_fu_hou_tao_can"];
        if (happyByIdConfig != null && happyByIdConfig is! List) {
          PreLoginConfigBean configBean =
          PreLoginConfigBean.fromJson(happyByIdConfig);
          Get.log("===套餐id===${configBean.toJson()}");
          if (configBean.valText.isNotEmpty) {
            integralPackageId = configBean.valText;
            update();
          }
        }

        ///套餐id
        final paySuccessShowTypeConfig =
        data["data"]["zhi_fu_hou_xian_shi_lei_xing"];
        if (paySuccessShowTypeConfig != null && paySuccessShowTypeConfig is! List) {
          PreLoginConfigBean configBean =
          PreLoginConfigBean.fromJson(paySuccessShowTypeConfig);
          if (configBean.valText.isNotEmpty) {
            paySuccessShowType = configBean.valText;
            update();
          }
          Get.log("===支付后显示类型===${paySuccessShowType}  ${configBean.toJson()}");
        }


        // paybackURL = data['data']['zhi_fu_wan_liu_tan_chuang']['val_text'] ?? '';
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  /// 该用户是否在审核面
  bool isAudit() {
    /// 是否在审核
    if(launchInfo?.isAudit == 1) {
      return true;
    }
    /// 是否已归因 ，是否在归因监测内
    if(userInfoBean.value?.hasAttribution == 0 && userInfoBean.value?.isNewAttributionUser == 0) {
      return true;
    }
    return false;
  }

  ///根据启动页下发路径，跳转不同付费页面
  ///是否直接返回首页，默认false
  ///是否需要显示特定的付费SKU弹窗
  ///[isWordsEmpty]字数包付费页样式
  void jumpToPayPage(
      {String? payPage,
      bool isBackHome = false,
      String source = 'unknown',
      bool showSKUDialog = false,
      bool isWordsEmpty = true,
      void Function()? back,
      bool? fromBanner,
      String? arguments,
      }) {
    if(fromBanner==true&&arguments!=null){
      Get.log("===加载banner运营套餐===");
    }
    ///跳转至支付页字数包
    if (userInfoBean.value?.isVip == 1) {
      // Get.toNamed(Routes.memberWordsPackage, arguments: {'isBackHome': isBackHome, 'showSKU': showSKUDialog})!
      //       .then((_) {
      //     back?.call();
      //   });
      ///是否是新用户
      final bool isNewer = userInfoBean.value!.activeDay! <= 1;
      DataService.onEvent(
        'pay',
        {'type': 'words_package', 'source': source, 'newer': isNewer},
      );

      ///跳转至字数包
      showGeneralDialog(
        context: Get.context!,
        pageBuilder: (context, animation, secondaryAnimation) {
          return MemberWordsPackagePage(
            isWordsEmpty: isWordsEmpty,
            isBackHome: isBackHome,
            showSKUDialog: showSKUDialog,
            source: source,
          );
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          var curve = Curves.fastOutSlowIn.transform(animation.value);
          return Transform.translate(
              offset: Offset(0, (1 - curve) * 200),
              child: Opacity(opacity: curve, child: child));
        },
      ).then((_) {
        // 对话框关闭后的回调（覆盖所有关闭场景的最终保险）
        if (Get.isRegistered<MemberCenterController>()) {
          Get.delete<MemberCenterController>();
        }
        back?.call();
      });
      return;
    }

    bool isRegister = Get.isRegistered<MemberCenterController>();
    if (isRegister) {
      final MemberCenterController controller =
          Get.find<MemberCenterController>();
      controller.changeTab(0);
      controller.loadVipHappys();
    }
    DataService.onEvent('pay', {
      'type': 'vip',
      'source': source,
      'newer': userInfoBean.value!.activeDay! <= 1
    });
    try {
      String landingPage = launchInfo?.verConfig.landingPage ?? "";
      if (payPage != null && payPage.isNotEmpty) {
        landingPage = payPage;
      }
      // 如果路径为空，默认跳转到横版会员中心
      if (landingPage.isEmpty) {
        jumpToNormalPayPage(
            isBackHome: isBackHome,
            showSKUDialog: showSKUDialog,
            back: back,
            source: source);
        return;
      }
      // 检查是否是有效的会员中心路径
      if ([
        Routes.memberCenter,
        Routes.memberCenterVertical,
      ].contains(landingPage)) {
        Get.toNamed(landingPage, arguments: {
          'isBackHome': isBackHome,
          'showSKU': showSKUDialog,
          'source': source,
          "payPageId":arguments,
        })!
            .then((_) {
          back?.call();
        });
      } else if (landingPage.contains(Routes.payCenterPage)) {
        try {
          int screenType = int.parse(landingPage.split('__')[1]);

          ///检查横竖屏是否配置错误
          if (![0, 1].contains(screenType)) {
            screenType = 0;
          }

          ///检查样式是否配置错误
          int style = int.parse(landingPage.split('__')[2]);
          if (![1, 2, 3, 4, 5].contains(style)) {
            style = 1;
          }
          Get.toNamed(Routes.payCenterPage, arguments: {
            'isBackHome': isBackHome,
            'showSKU': showSKUDialog,
            'source': source,
            'style': style,
            'type': screenType,
            "payPageId":arguments,
          })!
              .then((_) {
            back?.call();
          });
        } catch (e) {
          jumpToNormalPayPage(
              isBackHome: isBackHome,
              showSKUDialog: showSKUDialog,
              back: back,
              source: source,
              arguments: arguments
          );
        }
      } else {
        jumpToNormalPayPage(
            isBackHome: isBackHome,
            showSKUDialog: showSKUDialog,
            back: back,
            source: source,
            arguments: arguments

        );
      }
    } catch (e) {
      jumpToNormalPayPage(
          isBackHome: isBackHome,
          showSKUDialog: showSKUDialog,
          back: back,
          source: source,
          arguments: arguments
      );
    }
  }

  void jumpToNormalPayPage(
      {bool isBackHome = false,
      bool showSKUDialog = false,
      void Function()? back,
      String source = 'unknown',
        String? arguments,
      }) {
    Get.toNamed(Routes.memberCenter, arguments: {
      'isBackHome': isBackHome,
      'showSKU': showSKUDialog,
      'source': source,
      'arguments':arguments,
    })!
        .then((_) {
      back?.call();
    });
  }

  ///检查是否前置登录
  /// [actionCallback] 如果需要登录，登录成功后要执行的操作

  void checkPreLogin(
      {VoidCallback? actionCallback, String? source, bool binbing = false, bool showClose = true}) {
    if (isPreLogin && userInfoBean.value?.isFormal == 0 && !binbing) {
      // 保存被限制的操作回调
      if (actionCallback != null) {
        _pendingActionCallback = actionCallback;
      }
      if (userInfoBean.value?.isVip == 0) {
        OneKeyManager.onekeyLogin(
            isBindMode: false,
            source: source,
            successLogin: _executePendingAction);
      } else {
        ///账号绑定
        OneKeyManager.onekeyLogin(
            isBindMode: true,
            source: source,
            successLogin: _executePendingAction);
      }
    } else {
      ///未开启前置登录，未登录并且是会员，则强制绑定
      if (userInfoBean.value?.isFormal == 0 && userInfoBean.value?.isVip == 1) {
      // if (userInfoBean.value?.isFormal == 0) {
        // 保存被限制的操作回调
        if (actionCallback != null) {
          _pendingActionCallback = actionCallback;
        }
        OneKeyManager.onekeyLogin(
            isBindMode: true,
            showClose: showClose,
            source: source,
            successLogin: _executePendingAction);
        return;
      }
      actionCallback?.call();
    }
  }

  /// 执行被前置登录限制的操作
  void _executePendingAction() {
    if (_pendingActionCallback != null) {
      _pendingActionCallback!();
      _pendingActionCallback = null; // 执行后清空回调
    }
  }

  /// 清除待执行的操作（用于正常关闭登录页面时）
  void clearPendingAction() {
    _pendingActionCallback = null;
  }

  ///获取公共配置
  void getCommonConfig() {
    HttpUtils.post(NovelApis.getCommonConfig, {}, success: (data) {
      longNovelContinue = [];
      byDebugPrint(data, tag: "");
      NovelContinueWriteModel model = NovelContinueWriteModel.fromJson(data);
      if (model.data != null) {
        if (model.data!.longNovelContinue != null) {
          longNovelContinue.addAll(model.data!.longNovelContinue!);
        }
      }
      Get.log("获取公共配置data===>$data");
      // giveWords.value = data['data']['gift_word_pack'] ?? 0;
    }, fail: (code, msg) {
      BotToast.showText(text: msg);
    });
  }


  ///获取是否可以尝试
  void getCouldUse(){

    HttpUtils.post(NovelApis.isAllowTryout, {}, success: (data) {

      if(data["data"]!=null){
        if(data["data"]["result"]!=null){
          couldTry = data["data"]["result"];
        }
      }

      Get.log("获取是否可以尝试===>$data  couldTry==>$couldTry");
    }, fail: (code, msg) {
      // BotToast.showText(text: msg);
    });
  }

  ///更新是否进入过付费页
  void updateIsEnterPayPage(bool isEnterPayPage) {
    this.isEnterPayPage.value = isEnterPayPage;
    _saveEnterPayPageState();
    update();
  }

  ///更新是否是vip购买成功后从成功页离开
  void updateIsVipBuySuccessLeave(bool isVipBuySuccessLeave) {
    this.isVipBuySuccessLeave = isVipBuySuccessLeave;
    update();
  }

  ///从缓存加载进入付费页状态
  void _loadEnterPayPageState() async {
    try {
      final cachedValueString =
      await LocalCacheManager.readJsonData(Consts.kEnterPayPage);
      if (cachedValueString.isNotEmpty) {
        final cachedValue = cachedValueString == 'true';
        isEnterPayPage.value = cachedValue;
      }
    } catch (e) {
      // 如果加载失败，保持默认值false
      isEnterPayPage.value = false;
    }
  }

  ///保存进入付费页状态到缓存
  void _saveEnterPayPageState() async {
    try {
      await LocalCacheManager.saveJsonData(
          Consts.kEnterPayPage, isEnterPayPage.value);
    } catch (e) {
      // 保存失败时忽略错误
    }
  }

  ///重置进入付费页状态（当用户成为VIP时调用）
  void resetEnterPayPageState() {
    isEnterPayPage.value = false;
    _saveEnterPayPageState();
    update();
  }

  ///从缓存加载二次付费引导状态
  void _loadSecondPayGuideState() async {
    try {
      final showState =
      await LocalCacheManager.readJsonData(Consts.kSecondPayGuideShow);
      final startTime =
      await LocalCacheManager.readJsonData(Consts.kSecondPayGuideStartTime);

      if (showState.isNotEmpty) {
        showSecondPayGuide.value = showState == 'true';
      }

      if (startTime.isNotEmpty) {
        secondPayGuideStartTime.value = startTime;
      }
    } catch (e) {
      // 如果加载失败，保持默认值
      showSecondPayGuide.value = false;
      secondPayGuideStartTime.value = '';
    }
  }

  ///保存二次付费引导状态到缓存
  void _saveSecondPayGuideState() async {
    try {
      await LocalCacheManager.saveJsonData(
          Consts.kSecondPayGuideShow, showSecondPayGuide.value);
      await LocalCacheManager.saveJsonData(
          Consts.kSecondPayGuideStartTime, secondPayGuideStartTime.value);
    } catch (e) {
      // 保存失败时忽略错误
    }
  }

  ///触发二次付费引导（从支付成功页离开时调用）
  void triggerSecondPayGuide() {
    showSecondPayGuide.value = true;
    secondPayGuideStartTime.value =
        DateTime.now().millisecondsSinceEpoch.toString();
    _saveSecondPayGuideState();
    update();
  }

  ///隐藏二次付费引导
  void hideSecondPayGuide() {
    showSecondPayGuide.value = false;
    secondPayGuideStartTime.value = '';
    _saveSecondPayGuideState();
    update();
  }


  ///检查二次付费引导是否应该显示（检查时间是否过期）
  bool shouldShowSecondPayGuide() {
    if (!showSecondPayGuide.value || secondPayGuideStartTime.value.isEmpty) {
      return false;
    }

    try {
      final startTime = int.parse(secondPayGuideStartTime.value);
      final startDateTime = DateTime.fromMillisecondsSinceEpoch(startTime);
      final currentTime = DateTime.now();

      // 计算开始时间当天的24点（第二天0点）
      final endOfDay = DateTime(startDateTime.year, startDateTime.month,
          startDateTime.day, 23, 59, 59, 999);

      // 检查当前时间是否还在开始时间的当天24点之前
      return currentTime.isBefore(endOfDay) ||
          currentTime.isAtSameMomentAs(endOfDay);
    } catch (e) {
      return false;
    }
  }



}

