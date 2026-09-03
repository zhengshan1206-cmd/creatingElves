import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:byhy_app_common_utils/app_http/apis.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:byhy_app_common_utils/app_http/intercept.dart';
import 'package:fast_creation_master/core/network/novel_apis.dart';
import 'package:fast_creation_master/core/service/data_service.dart';
import 'package:fast_creation_master/profile/member/beans/user_menus_bean.dart';
import 'package:fast_creation_master/profile/member/dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wechat_kit/wechat_kit.dart';

import '../../../core/controller/user_controller.dart';
import '../../../core/util/by_device_info_utils.dart';
import '../../launch/bean/launch_info_bean.dart';
import '../../launch/bean/login_info_bean.dart';
import '../../launch/controller/launch_controller.dart';
import '../../launch/view/login_agreement_view.dart';
import '../../other/event_tracking/event_tracking.dart';

enum LoginType { oneKey, phone, wx }

class LoginController extends GetxController {
  /// 是否勾选了用户协议
  Rx<bool> agreementChecked = false.obs;

  /// 登录方式，默认为一键登录
  Rx<LoginType> loginType = LoginType.wx.obs;

  /// 用来记录上次的页面
  List<LoginType> pages = [];

  /// 是否允许点击登陆按钮
  Rx<bool> loginEnbled = false.obs;

  /// 手机号
  Rx<String> phoneNO = ''.obs;

  /// 验证码
  String vCode = '';

  /// 是否允许点击验证码按钮
  Rx<bool> vCodeBtnEnabled = false.obs;

  ///是否只允许手机登录
  bool? onlyPhone = false;

  ///是否一键登录拿到电话信息
  Rx<bool> oneKeyGetPhone = true.obs;

  Function? loginSuccess;

  ///协议列表
  RxList<UserMenusBean> protocolList = <UserMenusBean>[].obs;

  /// 登录成功后的回调函数
  VoidCallback? onLoginSuccessCallback;

  /// 是否为账号绑定模式
  Rx<bool> isBindMode = false.obs;

  /// 手机号是否有输入
  Rx<bool> isInputedPhone = false.obs;

  ///验证码是否错误
  Rx<bool> vcodeInputRight = true.obs;

  ///是否正在登录中
  Rx<bool> isLogin = false.obs;

  final FocusNode phoneNode = FocusNode();
  final FocusNode codeNode = FocusNode();

  LoginController({
    bool isBindMode = false,
    this.showClose,
    this.onLoginSuccessCallback,
  }) {
    this.isBindMode.value = isBindMode;
  }

  final bool? showClose;

  // late final OneKeyController oneKey;

  @override
  void onInit() {
    super.onInit();
    getProtocolList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(Get.context!).requestFocus(phoneNode);
    });

    ///是否在审核
    agreementChecked.value = !Get.find<UserController>().isAudit();
  }

  @override
  void dispose() {
    cancelSubscribeWXLoginResp();
    // 清理其他资源
    _clearPhoneAndPwd();

    // 如果是正常关闭（不是登录成功），清除待执行的操作
    if (onLoginSuccessCallback == null) {
      Get.find<UserController>().clearPendingAction();
    }
    super.dispose();
  }

  ///游客身份进入付费页
  void visitorForPayPage() {
    // 清除待执行的操作
    Get.find<UserController>().clearPendingAction();
    Get.back();
    Get.find<UserController>().jumpToPayPage();
  }

  ///更改验证手机号
  changePhoneNO(String phone) {
    phoneNO.value = phone;
    isInputedPhone.value = true;
    vCodeBtnEnabled.value = checkVCodeBtnEnabled();
    loginEnbled.value = checkLoginBtnEnabled();
  }

  ///更改验证验证码
  changeVCode(String code) {
    vCode = code;
    loginEnbled.value = checkLoginBtnEnabled();
    // 验证是否为4位数字
    if (RegExp(r'^\d{4}$').hasMatch(code)) {
      if (!agreementChecked.value) {
        EventTracking.reportDataPoint(
                        pageTag: 'login_page_protocol_dialog',
                        operateType: 'view',
                        funcDetailImg: '',
                        funcDetailTag: '2',);
        showDialog(
          context: Get.context!,
          builder: (context) {
            return LoginAgreementView(
              callback: () {
                FocusScope.of(context).unfocus();
                agreementCheckedStatusChanged(true);
                if (isBindMode.value) {
                  bindPhone();
                } else {
                  loginWithVCode(context);
                }
              },
            );
          },
        );
      } else {
        if (!loginEnbled.value) return;
        if (isBindMode.value) {
          bindPhone();
        } else {
          loginWithVCode(Get.context!);
        }
      }
    }
  }

  /// 检查登录按钮是否可用
  checkLoginBtnEnabled() => (phoneNO.value.length == 11 && vCode.length == 4);

  /// 检查验证码按钮是否可用
  checkVCodeBtnEnabled() =>
      (phoneNO.value.length == 11 || !isInputedPhone.value);

  /// 更新用户协议勾选状态
  agreementCheckedStatusChanged(bool checked) {
    if(Get.find<UserController>().isAudit()) {
      agreementChecked.value = checked;
    }
  }

  /// 订阅微信登陆响应
  StreamSubscription<WechatResp>? _respSubs;
  WechatAuthResp? authResp;

  /// 订阅微信登陆
  void subscribeWXLoginResp(BuildContext context) {
    // if (!Platform.isAndroid) return;
    cancelSubscribeWXLoginResp();
    _respSubs = WechatKitPlatform.instance.respStream().listen((resp) {
      if (resp is WechatAuthResp) {
        authResp = resp;
        print("response: ${resp.toJson()}");

        /// 微信登陆成，则调用服务器的微信登陆接口
        if (resp.isSuccessful) {
          _loginByWX(context);
        } else {
          // EasyLoading.dismiss();
        }
      } else if (resp is WechatPayResp) {
        // EasyLoading.dismiss();
      }
    });
  }

  /// 取消订阅微信登陆
  void cancelSubscribeWXLoginResp() {
    _respSubs?.cancel();
    _respSubs = null;
  }

  /// 微信登陆
  wxLogin() async {
    final isInstalled = await WechatKitPlatform.instance.isInstalled();
    if (!isInstalled) {
      // BotToast.showText(text: "请先安装微信");
      return;
    }

    // EasyLoading.show();

    await WechatKitPlatform.instance.auth(
      scope: <String>[WechatScope.kSNSApiUserInfo],
      state: "auth",
    );
    // EasyLoading.dismiss();
  }

  /// 微信登陆
  _loginByWX(BuildContext context) {
    final code = authResp?.code ?? "";
    if (code.isEmpty) {
      // BotToast.showText(text: "微信登陆失败，请稍后再试");
      // EasyLoading.dismiss();
      return;
    }
    HttpUtils.post(
      APIs.loginByWX,
      {
        "code": code,
      },
      success: (data) async {
        // byDebugPrint("${data['data']}", tag: "WX登陆:");
        await _handleLoginResponse(data);
      },
      fail: (code, msg) {
        // FlutterBugly.uploadException(message: "微信登录", detail: msg);
        // EasyLoading.dismiss();
        // BotToast.showText(text: msg);
      },
    );
  }

  /// 手机号登陆,获取验证码
  void getVCode({
    void Function(dynamic)? onSuccess,
    void Function(int, String)? onFailed,
  }) async {
    final imei = await ByDeviceInfoUtils.deviceInfo();
    HttpUtils.post(
      APIs.sendVCode,
      {
        "phone": phoneNO.value,
        "uuid": imei.item2,
      },
      success: (data) {
        FocusScope.of(Get.context!).requestFocus(codeNode);
        BotToast.showText(text: data["message"]);
        onSuccess?.call(data);
      },
      fail: (code, msg) {
        onFailed?.call(code, msg);
        BotToast.showText(text: msg);
      },
    );
  }

  /// 一键登录
  oneclickv2(String smsToken) {
    String sys = Platform.isAndroid
        ? 'android'
        : Platform.isIOS
            ? 'ios'
            : 'pc';
    EventTracking.reportDataPoint(
                        pageTag: 'login_page_one_click_btn',
                        operateType: 'click',
                        funcDetailImg: '',
                        funcDetailTag: '1',);
    HttpUtils.post(
      APIs.oneclickv2,
      {"sms_token": smsToken, 'sys': sys},
      success: (data) async {
        await _handleLoginResponse(data, isOnekey: true);
      },
      fail: (code, msg) {
        DataService.onEvent('login_fail', {'method': 'onekey', 'msg': msg});
      },
    );
  }

  void loginWithVCode(
    BuildContext context, {
    String? code,
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) async {
    // EasyLoading.show();
    if (isLogin.value) {
      return;
    }
    EventTracking.reportDataPoint(
                        pageTag: 'login_page_one_click_btn',
                        operateType: 'click',
                        funcDetailImg: '',
                        funcDetailTag: '2',);
    final imei = await ByDeviceInfoUtils.deviceInfo();
    isLogin.value = true;
    HttpUtils.post(
      APIs.loginByPhone,
      {
        "phone": phoneNO.value,
        "code": code ?? vCode,
        "uuid": imei.item2,
      },
      success: (data) async {
        isLogin.value = false;
        await _handleLoginResponse(data);
        if (data["status"] == 200) {
          onSuccess?.call();
        } else {
          vcodeInputRight.value = false;
        }
      },
      fail: (code, msg) {
        DataService.onEvent('login_fail', {'method': 'phone', 'msg': msg});
        isLogin.value = false;
        vcodeInputRight.value = false;
        onFailed?.call(code, msg);
        BotToast.showText(text: msg);
      },
    );
  }

  /// 登录成功后的处理
  void handleLoginSuccess() {
    // 执行登录成功回调
    if (onLoginSuccessCallback != null) {
      onLoginSuccessCallback!();
    }
    // 延迟销毁控制器，确保页面已经完全关闭
    Future.delayed(const Duration(milliseconds: 100), () {
      if (Get.isRegistered<LoginController>()) {
        Get.delete<LoginController>();
      }
    });
  }

  Future<void> _handleLoginResponse(data, {bool isOnekey = false}) async {
    // 根据是否为绑定模式显示不同的提示
    final successMessage = isBindMode.value ? '绑定成功' : '登录成功';
    BotToast.showText(text: successMessage);

    if (data["status"] != 200) return;

    print('~~~~~~登录成功');
    DataService.onEvent('login_success', {
      'method': isOnekey ? 'onekey' : 'phone',
      'type': isOnekey,
      'status': data["status"]
    });

    if (isBindMode.value) {
      Get.find<UserController>().reloadUserInfo(
        successAction: (userInfo) {
          // 确保登录成功后正确销毁页面和控制器
          if (!isOnekey) {
            Get.back();
          }
          handleLoginSuccess();
        },
      );
      return;
    }
    final LoginInfoBean userInfo = LoginInfoBean.fromJson(data["data"]);
    userInfo.isFormal = 1;

    LaunchInfoBean? launchInfo = Get.find<LaunchController>().launchInfo;
    launchInfo?.userId = userInfo.userId;
    launchInfo?.isVip = userInfo.isVip;
    launchInfo?.token = userInfo.token;
    launchInfo?.isFormal = userInfo.isFormal ?? 1;
    launchInfo?.canBoundCode = userInfo.canBoundCode;

    // _clearPhoneAndPwd();

    setToken(userInfo.token)?.then((onValue) {
      if (onValue) {
        Get.find<UserController>().reloadUserInfo(
          successAction: (userInfo) {
            // 确保登录成功后正确销毁页面和控制器
            if (!isOnekey) {
              Get.back();
            }
            handleLoginSuccess();
          },
        );

        // ByNavRouterUtils.pushAndRemoveUntil(Get.context!, MainPage());
      }
    });
  }

  /// 清除手机号和验证码
  void _clearPhoneAndPwd() {
    phoneNO.value = "";
    vCode = "";
    agreementChecked.value = false;
    loginEnbled.value = false;
  }

  ///成功登录更新用户信息
  void setLoginSuccess() {
    loginSuccess = () async {
      // await Get.find<UserController>().reloadUserInfo(goBack: () {
      //   closeOneKeyLogin();
      // });
    };
  }

  ///一键登录授权页关闭
  void closeOneKeyLogin() {
    // EasyLoading.dismiss();
    Get.back();
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
        ByNavRouterUtils.jumpWebViewPage(Get.context!, title, bean.url);
      }
    } catch (e) {}
  }

  /// 绑定手机号
  void bindPhone({int? confirm, bool isOnekey = false, String smsToken = ''}) {
    String sys = Platform.isAndroid
        ? 'android'
        : Platform.isIOS
            ? 'ios'
            : 'pc';
    if (isLogin.value) {
      return;
    }
    EventTracking.reportDataPoint(
                        pageTag: 'login_page_one_click_btn',
                        operateType: 'click',
                        funcDetailImg: '',
                        funcDetailTag: '2',);
    isLogin.value = true;
    HttpUtils.post(
      isOnekey ? APIs.onekeyBindPhone : APIs.bindPhone,
      isOnekey
          ? {'sms_token': smsToken, "is_confirm": confirm ?? 0, 'sys': sys}
          : {
              "phone": phoneNO.value,
              "is_confirm": confirm ?? 0,
              "code": vCode,
            },
      success: (data) async {
        isLogin.value = false;
        await _handleLoginResponse(data, isOnekey: isOnekey);
      },
      fail: (code, msg) {
        isLogin.value = false;
        vcodeInputRight.value = false;
        // 如果返回status为100，用户选择确定后需要传此参数，值为1
        if (code == 100) {
          Get.dialog(
            ConfirmDialog(
              title: '温馨提示',
              content: '该手机号已绑定其他账号，是否继续绑定？',
              confirmText: '继续绑定',
              cancelText: '取消',
              onConfirm: () {
                bindPhone(confirm: 1, isOnekey: isOnekey, smsToken: smsToken);
              },
              onCancel: () {},
            ),
          );
          return;
        }
        BotToast.showText(text: msg);
      },
    );
  }
}
