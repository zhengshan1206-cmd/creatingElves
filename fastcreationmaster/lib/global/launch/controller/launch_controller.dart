import 'package:byhy_app_common_utils/app_common/aes/byhy_aes_storage_utils.dart';
import 'package:byhy_app_common_utils/app_common/attribution/by_ascribe_util.dart';
import 'package:byhy_app_common_utils/app_common/by_common_utils.dart';
import 'package:byhy_app_common_utils/app_common/consts/const_keys.dart';
import 'package:byhy_app_common_utils/app_http/apis.dart';
import 'package:byhy_app_common_utils/app_http/dio_utils.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:byhy_app_common_utils/app_http/intercept.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/global/initialize/initialize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:get/get.dart';

import '../../../core/cache/cache.dart';
import '../../../core/util/by_device_info_utils.dart';
import '../../../core/util/by_package_utils.dart';
import '../../const/const.dart';
import '../../other/event_tracking/event_tracking.dart';
import '../../routes/app_pages.dart';
import '../bean/launch_info_bean.dart';
import '../page/permission_confirm_page.dart';

typedef LaunchSuccessCallback = void Function(LaunchInfoBean);
typedef LaunchFailCallback = void Function();

class LaunchController extends GetxController {
  LaunchInfoBean? launchInfo;

  bool isLaunched = false;

  ///是否加载过启动页

  ///启动页检查
  void checkAgreement() async {
    ///是否同意隐私授权
    // final checked = ByStorageUtils.getBool(Consts.kPrivacyChecked) ?? false;
    final checked =
        await LocalCacheManager.readJsonData(Consts.kSPPrivacyChecked);
    print('是否看过隐私协议：_____$checked');

    if (checked.isNotEmpty) {
      Future.delayed(const Duration(seconds: 1), () {
        appLaunch(isFirshLaunch: true);
        launchSuccessful();
      });
    } else {
      showCheckDialog();
    }
  }

  ///失败启动，检查隐私页
  void showCheckDialog() {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (ctx) {
        return PermissionConfirmPage(
          onConfirm: () async {
            Get.back();
            // bool? istrue = await ByStorageUtils.saveBool(Consts.kPrivacyChecked, true);
            LocalCacheManager.saveJsonData(Consts.kSPPrivacyChecked, '1');
            appLaunch(isFirshLaunch: true);
            launchSuccessful();
          },
        );
      },
    );
  }

  ///成功启动后
  void launchSuccessful() {
    ///网络链路正常后初始化sdk
    InitializeManager.initSDK();

    ///是否看过引导页
    final guideChecked =
        ByStorageUtils.getBool(Consts.kLaunchGuideCheck) ?? false;
    print('是否看过引导页：_____$guideChecked');
    if (guideChecked) {
      ///用户是否登录
      ///
      ///
      ///
      ///待开发
      Get.offNamed(Routes.main);
    } else {
      Get.offNamed(Routes.guide);
    }
  }

  ///启动接口
  void appLaunch({
    bool? isFirshLaunch = false,
    LaunchSuccessCallback? onSuccess,
    LaunchFailCallback? onFail,
  }) async {
    final imei = await ByDeviceInfoUtils.deviceInfo();
    final String system =
        ByPackageUtils.isAndroid ? Consts.kSystemAndroid : Consts.kSystemIOS;
    Map params = {};
    params = {
      "uuid": imei.item2,
      "app_version": ByStorageUtils.getString(ConstKeys.kAppVersion) ?? "5.0.0",
      "sys": system,
    };

    HttpUtils.request(
      Method.post,
      APIs.launch,
      forceData: false,
      showMsgWhenFailed: true,
      params,
      success: (data) async {
        final responseData = data["data"];
        final LaunchInfoBean launchInfoBean =
            LaunchInfoBean.fromJson(responseData);
        launchInfo = launchInfoBean;
        final token = launchInfoBean.token;

        /// 保存token
        setToken(token)?.then((onValue) {
          if (onValue) {
            /// 上报设备信息
            DeviceInfoUpload.uploadUserDeviceInfo();
            Get.find<UserController>().initInfo();
            // if (isFirshLaunch!) {
            //   launchSuccessful();
            // }
            isLaunched = true;

            /// 回调
            onSuccess?.call(launchInfoBean);
            if (isFirshLaunch!) {
              EventTracking.reportDataPoint(
                pageTag: 'tourist',
                operateType: 'view',
                funcDetailImg: '',
                funcDetailTag: '',
              );
            }
          }
        });
      },
      fail: (code, msg) {
        // if (isFirshLaunch!) {
        //   Get.offNamed(Routes.launchFail);
        // }
        ByCommonUtils.debugPrintObj("onError: code: $code");
        ByCommonUtils.debugPrintObj("onError: msg: $msg");
        FlutterBugly.uploadException(message: "启动接口失败", detail: msg);
        onFail?.call();
      },
    );
  }
}

/// 上报用户设备信息
class DeviceInfoUpload {
  /// 有推送token时加入推送token
  static void uploadUserDeviceInfo({String? pushToken}) async {
    await ByAscribeUtil.iniBDConvert();
    final params = await ByDeviceInfoUtils.getUserDiviceInfo();
    if (pushToken != null) {
      params["um_device_tokens"] = pushToken;
    }
    HttpUtils.post(APIs.deviceInfo, params, success: (data) {
      Get.log("~~~~~上报设备信息成功$data,$pushToken");
    }, fail: (code, msg) {
      FlutterBugly.uploadException(message: "上报用户设备信息", detail: msg);
    });
  }
}
