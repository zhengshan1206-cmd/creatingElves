import 'dart:io';

import 'package:byhy_app_common_utils/app_common/consts/environment.dart';
import 'package:byhy_app_common_utils/app_http/apis.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:umeng_common_sdk/umeng_common_sdk.dart';


///数据统计，埋点上传服务
///

class DataService {

  ///上报事件
  static void onEvent(String eventName, Map<String, dynamic> params) async {
    // 这里可以使用第三方统计SDK进行事件上报
    String device = 'undefined';
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      device = androidInfo.model;
    } else if (Platform.isIOS) {
      final iosInfo = await DeviceInfoPlugin().iosInfo;
      device = iosInfo.utsname.machine;
    }
    params['device'] = device;

    ///正式环境才上报
    // if(Environment.PRODUCTION.domain == APIs.apiPrefix) {
    UmengCommonSdk.onEvent(eventName, params);
    // }
    print('友盟事件调用上报:-事件名称:$eventName- 事件参数:$params');

  }

  ///上报页面访问
  static void onPageStart(String pageName) {
    if (Environment.PRODUCTION.domain == APIs.apiPrefix) {
      UmengCommonSdk.onPageStart(pageName);
    }
  }

  ///上报页面结束
  static void onPageEnd(String pageName) {
    if (Environment.PRODUCTION.domain == APIs.apiPrefix) {
      UmengCommonSdk.onPageEnd(pageName);
    }
  }
}
