/*
 * @Author: cold-x
 * @Date: 2025-06-04 16:46:31
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-09-05 16:40:55
 * @FilePath: /fastcreationmaster/lib/global/routes/routes_utils.dart
 * @Description: 
 */

import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:fast_creation_master/core/controller/base_record_controller.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/global/main/main_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

import 'app_pages.dart';

BannerBean bannerBeanFromJson(String str) =>
    BannerBean.fromJson(json.decode(str));

String bannerBeanToJson(BannerBean data) => json.encode(data.toJson());

class BannerBean {
  int id;
  String title;
  String imgUrl;
  String jumpUrl;
  String jumpParam;
  int type;
  String des;

  BannerBean({
    required this.id,
    required this.title,
    required this.imgUrl,
    required this.jumpUrl,
    required this.jumpParam,
    required this.type,
    required this.des,
  });

  factory BannerBean.fromJson(Map<String, dynamic> json) => BannerBean(
        id: json["id"],
        title: json["title"],
        imgUrl: json["img_url"],
        jumpUrl: json["jump_url"],
        jumpParam: json["jump_param"],
        type: json["type"],
        des: json["des"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "img_url": imgUrl,
        "jump_url": jumpUrl,
        "jump_param": jumpParam,
        "type": type,
        "des": des,
      };
}

class NavigateUtils {
  static void navigateTo(BannerBean data, {Map<String, dynamic>? arguments,bool? fromBanner }) {
    final url = data.jumpUrl;
    final String params = data.jumpParam;
    if (data.type == 1 || data.type == 2) {
      /// 路由跳转
      NavigateUtils.jumptoPage(data.jumpUrl, params,fromBanner);
    } else if (data.type == 3) {
      //视频播放
    } else if (data.type == 4) {
      //跳转外链
      ByNavRouterUtils.jumpWebViewPage(Get.context!, data.des, url);
    }
  }

  static void jumptoPage(String routeName, String arguments,bool? fromBanner,) {
    switch (routeName) {
      ///小说创作页
      case Routes.novelCreate:
        Get.toNamed(routeName, arguments: {
          'novel_type': arguments.contains('short_novel')
              ? CreationType.shortNovel
              : arguments.contains('long_novel')
                  ? CreationType.novel
                  : CreationType.shortStory
        });
        break;

      ///短故事、文案等创作页
      case Routes.toolCreation:
        Get.toNamed(routeName, arguments: {
          'type': arguments.toCreationType(),
        });
        break;

      ///横版会员中心
      case Routes.memberCenter:

      ///竖版会员中心
      case Routes.memberCenterVertical:

      ///新版付费页
      case _ when routeName.startsWith(Routes.payCenterPage):
        Get.find<UserController>()
            .jumpToPayPage(source: 'banner', payPage: routeName,fromBanner: fromBanner,arguments: arguments,);
        break;

      ///攻略详情页
      case Routes.squareDetails:
        final int id = int.parse(arguments);
        Get.toNamed(routeName, arguments: {"id": id});
    }
  }

  /// 跳转到主页面
  /// [index] 页面索引：0-首页，1-广场，2-我的
  static void navigateToMainPage(int index) {
    if (index < 0 || index > 2) return;

    // 如果当前在主页面，直接切换tab
    if (Get.currentRoute == Routes.main) {
      try {
        final mainController = Get.find<MainController>();
        mainController.navigateToPage(index);
      } catch (e) {
        print('主页面控制器未找到: $e');
        // 如果找不到控制器，使用路由跳转
        Get.toNamed(Routes.main, arguments: {'index': index});
      }
    } else {
      // 不在主页面，跳转到主页面并指定tab
      Get.toNamed(Routes.main, arguments: {'index': index});
    }
  }

  /// 跳转到首页
  static void navigateToHome() {
    navigateToMainPage(0);
  }

  /// 跳转到广场
  static void navigateToSquare() {
    navigateToMainPage(1);
  }

  /// 跳转到我的
  static void navigateToProfile() {
    navigateToMainPage(2);
  }

  /// 回到主页后跳转至指定路由页面
  static void navigateToPageAfterBacktoMain(String routeName, dynamic args) {
    bool returnCreate = false;
    Get.until((route) {
      if (route.settings.name == routeName) {
        returnCreate = true;
      }
      return route.settings.name == routeName ||
          route.settings.name == Routes.main;
    });
    if (!returnCreate) {
      Get.toNamed(routeName, arguments: args);
    }
  }

  /// 通过路由名称导航（有则返回，无则跳转）
  static void navigateToNamed(String targetRouteName, dynamic args) {
    final navigator = Navigator.of(Get.context!);
    final allRoutes = navigator.widget.pages.map((page) => page.name).toList();
    bool hasTarget = allRoutes.contains(targetRouteName);

    if (hasTarget) {
      Get.until((route) => route.settings.name == targetRouteName);
    } else {
      Get.toNamed(targetRouteName, arguments: args);
    }
  }
}
