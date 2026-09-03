/*
 * @Author: cold-x
 * @Date: 2025-06-09 11:11:43
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-06-09 16:00:47
 * @FilePath: /fastcreationmaster/lib/core/util/by_device_info_utils.dart
 * @Description: 
 */
import 'dart:developer';
import 'dart:io';

import 'package:android_cn_oaid/android_cn_oaid.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:bda_signal/bda_signal.dart';
import 'package:connection_network_type/connection_network_type.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fast_creation_master/core/util/channel/channel_operate.dart';
import 'package:tuple/tuple.dart';
import 'by_package_utils.dart';

class ByDeviceInfoUtils {
  loadDeviceInfo() {
    if (Platform.isAndroid) return DeviceInfoPlugin().androidInfo;
    return DeviceInfoPlugin().iosInfo;
  }

  /// 使用 AndroidId 替代 UUID
  static Future<Tuple2<String, String>> deviceInfo() async {
    if (Platform.isAndroid) {
      final data = await ChannelOperate.getAppDeviceInfo();
      String androidId = "";
      String oaid = "";
      if (data != null) {
        androidId = data["androidId"];
        oaid = data["oId"];
      } else {
        final AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
        androidId = info.id;
      }
      if(androidId.isEmpty || isEmptyOrSameChar(androidId)) {
        androidId = oaid;
        if(androidId.isEmpty || isEmptyOrSameChar(androidId)) {
          androidId = await deviceIdentifier();
        }
      }
      if(androidId.isEmpty && data != null) {
        androidId = data["androidId"];
      }
      return Tuple2(oaid, androidId);
    }
    final IosDeviceInfo info = await DeviceInfoPlugin().iosInfo;
    return Tuple2("", info.identifierForVendor ?? "");
  }

  static bool isEmptyOrSameChar(String text) {
    return RegExp(r'^(.)\1*$').hasMatch(text.replaceAll('-', ''));
  }

  /// 获取其他设备标识
  static Future<String> deviceIdentifier() async {
    final plugin = AndroidCnOaid();
    await plugin.register();
    final supported = await plugin.isSupported();
    if (!supported) {
      return '';
    }
    String id = '';
    try {
      id = await plugin.getOAIDByManufacturer() ?? '';
      if(id.isEmpty || isEmptyOrSameChar(id)) {
        id = await plugin.getPseudoID();
      }
      return id;
    } on OaidException catch (e) {
      id = '';
    }
    return id;
  }

  static Future<dynamic> getUserDiviceInfo() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final appVersion = await ByPackageUtils.version();
      final di = await deviceInfo();
      return {
        "uuid": di.item2,
        "android": di.item2,
        "imei": di.item2,
        "oaid": di.item1,
        "brand": androidInfo.brand,
        "sys_version": androidInfo.version.release,
        "model": androidInfo.model,
        "app_versions": appVersion,
      };
    }else if (Platform.isIOS){
      log("进入到ios 获取信息===");
      final iosInfo = await DeviceInfoPlugin().iosInfo;
      final appVersion = await ByPackageUtils.version();
      final di = await deviceInfo();
      int systemBootTime = await  BdaSignal.systemBootTime();
      String appInstallTime = await  BdaSignal.appInstallTime();
      String asaToken = await BdaSignal.adToken();
      ///这里oaid 在ios里取的是idfv
      String oaid = await BdaSignal.idfv();

      // final status = await AppTrackingTransparency.requestTrackingAuthorization();
      String systemInitialTime = await BdaSignal.getDeviceInitialTime();


      String idfa =  await AppTrackingTransparency.getAdvertisingIdentifier();
      log("进入到ios 获取信息 idfa=== $idfa  系统更新时间==> $appInstallTime 系统启动时间==> $systemBootTime  系统初始化时间==> $systemInitialTime");

      return {
        "uuid": di.item2,
        "boot_time":systemBootTime.toString(),
        "mb_time":appInstallTime.toString(),
        "asa_token":asaToken,
        "sys_version": iosInfo.systemVersion,
        "oaid":oaid,
        "app_versions": appVersion,
        "model": iosInfo.utsname.machine,
        "brand": "apple",
        "idfa":idfa,
        "boot_init_time":systemInitialTime,
      };
    }
    return {
      "uuid": "",
      "android": "",
      "imei": "",
      "oaid": "",
      "brand": "",
      "sys_version": "",
      "model": "",
      "app_versions": "",
    };
  }

  static Future<String> getNetworkStatus() async {
    // If this plugin is used on Android, request the READ_PHONE_STATE permission.
    // if(ByPackageUtils.isAndroid) {
    //     await Permission.phone.request();
    // }

    NetworkStatus networkStatus =
        await ConnectionNetworkType().currentNetworkStatus();
    switch (networkStatus) {
      case NetworkStatus.unreachable:
        return 'none';
      case NetworkStatus.wifi:
        return 'wifi';
      case NetworkStatus.mobile2G:
        return '2G';
      case NetworkStatus.mobile3G:
        return '3G';
      case NetworkStatus.mobile4G:
        return '4G';
      case NetworkStatus.mobile5G:
        return '5G';
      case NetworkStatus.otherMobile:
        return 'unknown';
    }
  }
}
