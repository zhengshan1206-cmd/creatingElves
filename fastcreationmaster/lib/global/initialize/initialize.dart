/*
 * @Author: cold-x
 * @Date: 2025-05-30 14:29:37
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-09-02 19:54:35
 * @FilePath: /fastcreationmaster/lib/global/initialize/initialize.dart
 * @Description: 初始化器
 */

import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:byhy_app_common_utils/app_common/aes/byhy_aes_storage_utils.dart';
import 'package:byhy_app_common_utils/app_common/consts/build_config.dart';
import 'package:byhy_app_common_utils/app_common/consts/const_keys.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:sp_util/sp_util.dart';
import 'package:umeng_common_sdk/umeng_common_sdk.dart';
import 'package:wechat_kit/wechat_kit.dart';

import '../../core/util/by_package_utils.dart';
import '../ui/colors.dart';

class WxLoginConfig {
  static const String kWechatAppID = 'wxa5307a7d6724b57a';
  static const String kWechatUniversalLink = 'https://inchat.beiyinapp.com/app/';
  static const String kWechatAppSecret = '84e9b5e662b7723530bb07e085b85c0e';
  static const String kWechatMiniAppID = 'your wechat miniAppId';
}

///App 初始化器
class InitializeManager {

  ///初始化SDK
  static void initSDK() async {
    
    initUmeng();

    initBugly();

    if(Platform.isIOS) {
      await _requestTrackingAuthorization();
    }
  }

  ///初始化组件
  static void initializition() async {
    // 设置状态栏透明
    initStatusBar();

    /// 初始化PF
    await _initPF();

    initEasyRefresh();

    final version = await ByPackageUtils.version();
    await ByStorageUtils.saveString(ConstKeys.kAppVersion, version);
    await ConstKeys().initUserAgentData();

    await WechatKitPlatform.instance.registerApp(
      appId: WxLoginConfig.kWechatAppID,
      universalLink: WxLoginConfig.kWechatUniversalLink,
    );
    // 确保微信支付SDK初始化完成
    // if (Platform.isAndroid) {
      // try {
      //   await WechatKitPlatform.instance.registerApp(
      //     appId: WxLoginConfig.kWechatAppID,
      //     universalLink: WxLoginConfig.kWechatUniversalLink,
      //   );
      //   // 等待一小段时间确保初始化完成
      //   await Future.delayed(const Duration(milliseconds: 500));
      // } catch (e) {
      //   print("微信支付初始化失败: $e");
      // }
    // }
  }
  // 请求广告追踪授权
  static Future<void> _requestTrackingAuthorization() async {
    // 1. 检查 iOS 版本是否支持（需 iOS 14+）
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      // 2. 显示授权弹窗（会触发系统弹窗）
      Future.delayed(const Duration(milliseconds: 500),() async{
        await AppTrackingTransparency.requestTrackingAuthorization();
      }); 
    }
    
    // // 3. 授权后可获取 IDFA（可选）
    // if (await AppTrackingTransparency.trackingAuthorizationStatus == TrackingStatus.authorized) {
    //   final idfa = await AdvertisingId.id;
    //   print("用户已授权，IDFA: $idfa");
    // } else {
    //   print("用户未授权或设备不支持");
    // }
  }

  static void initStatusBar() {
    // 设置状态栏透明
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // 状态栏透明
        statusBarIconBrightness: Brightness.light, // 状态栏图标颜色（深色/浅色）
        systemNavigationBarColor: ByColorUtil.colorBg1, // 半透明蓝色
        systemNavigationBarDividerColor: Colors.transparent, // 分隔线颜色
      ),
    );
  }

  ///异常捕捉bugly初始化
  static void initBugly() {
    FlutterBugly.init(
      androidAppId: 'fed8bb52d5',
      iOSAppId: '01289bbe2b',
    );
  }

  ///初始化友盟统计
  static void initUmeng() {
    //初始化组件化基础库, 所有友盟业务SDK都必须调用此初始化接口。
    UmengCommonSdk.initCommon('685dfc1379267e021095f628', '685dfe6abc47b67d83982b67', '${BuildConfig.instance.channelType.code}');
    // UmengCommonSdk.onProfileSignIn("12345");
    // 自动采集页面信息
    UmengCommonSdk.setPageCollectionModeAuto();
  }

  ///初始化本地化组件
  static Future<void> _initPF() async {
    await SpUtil.getInstance(); // 这里也要 await
  }

  ///初始化上下拉刷新
  static void initEasyRefresh() {
    EasyRefresh.defaultHeaderBuilder = () => ClassicHeader(
          textStyle: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.5),
          ),
          messageStyle: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.5),
          ),
          succeededIcon: Icon(
            Icons.done,
            color: ByColorUtil.colorC1.withOpacity(0.5),
          ),
          triggerOffset: 40,
          dragText: "下拉刷新",
          armedText: '释放开始刷新',
          readyText: '刷新中...',
          processingText: '刷新中...',
          processedText: '刷新成功',
          noMoreText: '没有更多数据了',
          failedText: '刷新失败',
          messageText: '最后更新 %T',
        );
    EasyRefresh.defaultFooterBuilder = () => ClassicFooter(
          // backgroundColor: Colors.red,
          dragText: '上拉加载更多',
          armedText: '释放开始加载',
          readyText: '加载中...',
          processingText: '加载中...',
          processedText: '加载成功',
          noMoreText: '没有更多数据了',
          failedText: '加载失败',
          messageText: '最后更新 %T',
          textStyle: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.5),
          ),
          messageStyle: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.5),
          ),
          succeededIcon: Icon(
            Icons.done,
            color: ByColorUtil.colorC1.withOpacity(0.5),
          ),
        );
  }
}
