/*
 * @Author: cold-x
 * @Date: 2025-05-28 14:51:03
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-02-25 18:54:50
 * @FilePath: /fastcreationmaster/lib/global/main/main_controller.dart
 * @Description: 
 */

import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/core/service/data_service.dart';
import 'package:fast_creation_master/core/service/page_route_service.dart';
import 'package:fast_creation_master/core/widget/view/muti_status_view.dart';
import 'package:fast_creation_master/global/launch/controller/launch_controller.dart';
import 'package:fast_creation_master/global/other/novel_words/controller/words_controller.dart';
import 'package:fast_creation_master/home/main_page/controller/home_controller.dart';
import 'package:fast_creation_master/profile/profile.dart';
import 'package:fast_creation_master/profile/profile_controller.dart';
import 'package:fast_creation_master/square/add_wechat_dialog.dart';
import 'package:fast_creation_master/square/square.dart';
import 'package:fast_creation_master/square/zone/controller/square_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../home/main_page/page/home.dart';
import '../login/controller/onekey_manager.dart';
import '../other/event_tracking/event_tracking.dart';
import '../routes/app_pages.dart';

class MainController extends GetxController {
  Rx<int> currentIndex = 0.obs;

  ///启动接口状态
  Rx<MultiStatusType> launchStatus = MultiStatusType.statusLoading.obs;

  List<Widget> tabBarPages = [];

  // 页面进入时间记录
  final Map<int, DateTime> _pageEnterTimes = {};

  // 当前活跃页面索引
  int? _currentActivePageIndex;

  // 是否正在处理路由变化（避免重复上报）
  bool _isHandlingRouteChange = false;

  LaunchController launchController = Get.find<LaunchController>();

  UserController userController = Get.find<UserController>();

  @override
  void onInit() {
    super.onInit();
    DataService.onEvent('home', {});
    fetchLaunchData();
  }

  ///加载启动数据
  void fetchLaunchData() {
    ///是否有启动接口
    if (launchController.isLaunched) {
      launchStatus.value = MultiStatusType.statusContent;
      loadData();
    } else {
      launchStatus.value = MultiStatusType.statusLoading;
      launchController.appLaunch(
        onSuccess: (p0) {
          launchStatus.value = MultiStatusType.statusContent;
          loadData();
        },
        onFail: () {
          launchStatus.value = MultiStatusType.statusNoNetWork;
        },
      );
    }
  }

  ///加载主页以及各个tab页数据
  void loadData() {
    Get.put(WordsController(), permanent: true);
    Get.put(UserController());
    Get.put(ProfileController(), permanent: true);
    Get.put(SquareController());

    tabBarPages.add(HomePage());
    tabBarPages.add(SquarePage());
    tabBarPages.add(ProfilePage());

    ///一键登录，闪验初始化, 延迟加载
    Future.delayed((const Duration(seconds: 3)), () {
      OneKeyManager.init();
    });

    // 记录首页进入时间
    recordPageEnter(0);
  }

  void tabChanged(
    int index,
  ) {
    // 如果正在处理路由变化，跳过tab切换的埋点
    if (_isHandlingRouteChange) {
      currentIndex.value = index;
      return;
    }

    // 保存当前页面的索引作为上一个页面
    final int? previousPageIndex = _currentActivePageIndex;

    // 上报上一个页面的停留时长
    if (previousPageIndex != null) {
      reportPageDuration(previousPageIndex, index);
    }

    currentIndex.value = index;

    // 记录新页面进入时间
    recordPageEnter(index);

    ///启动接口未启动时
    if (!launchController.isLaunched) {
      return;
    }

    if (index == 0) {
      Get.find<HomeController>().viewDidAppear();
    }
    if (index == 1) {
      EventTracking.reportDataPoint(
        pageTag: 'guide_page',
        operateType: 'view',
        funcDetailImg: '',
        funcDetailTag: '',
      );
      if (!Get.find<SquareController>().isShowGuideDialog) {
        Get.find<SquareController>().showGuideDialog();
      }
      if (userController.strategyAddVUrl.isNotEmpty &&
          userController.userInfoBean.value?.isVip == 1) {
            
        Get.dialog(AddWechatDialog(
          wechatUrl: userController.strategyAddVUrl,
        ));
        EventTracking.reportDataPoint(
          pageTag: 'guide_page_add_teacher_dialog',
          operateType: 'view',
          funcDetailImg: '',
          funcDetailTag: '',
        );
      }
    }
    if (index == 2) {
      final profile = Get.find<ProfileController>();
      profile.updateUserInfo();
      profile.reportData();
    }
  }

  /// 记录页面进入时间
  void recordPageEnter(int index) {
    _pageEnterTimes[index] = DateTime.now();
    _currentActivePageIndex = index;
  }

  /// 记录页面进入时间（用于路由变化）
  void recordPageEnterFromRoute(int index) {
    _isHandlingRouteChange = true;
    recordPageEnter(index);
    currentIndex.value = index;
    _isHandlingRouteChange = false;
  }

  /// 上报页面停留时长
  void reportPageDuration(int pageIndex, [int? nextPageIndex]) {
    final DateTime? enterTime = _pageEnterTimes[pageIndex];
    if (enterTime == null) return;

    // 计算停留时长（秒，保留两位小数）
    final double duration =
        DateTime.now().difference(enterTime).inMilliseconds / 1000.0;

    // 获取页面路由名称
    final String pagePath = _getPagePath(pageIndex);
    final String prePagePath =
        nextPageIndex != null ? _getPagePath(nextPageIndex) : '';

    // 上报页面访问数据
    PageRouteService.reportPageView(
      duration: duration,
      pagePath: pagePath,
      prePagePath: prePagePath,
    );

    // 移除已上报的页面时间记录
    _pageEnterTimes.remove(pageIndex);

    print(
        '主页面路由上报: 页面=$pagePath, 时长=${PageRouteService.getDurationText(duration.round())}, 下一页=$prePagePath');
  }

  /// 上报主页面离开时的埋点（用于路由监听器调用）
  void reportMainPageLeave(String nextPagePath) {
    if (_currentActivePageIndex == null) return;

    final DateTime? enterTime = _pageEnterTimes[_currentActivePageIndex];
    if (enterTime == null) return;

    // 计算停留时长（秒，保留两位小数）
    final double duration =
        DateTime.now().difference(enterTime).inMilliseconds / 1000.0;

    // 获取页面路由名称
    final String pagePath = _getPagePath(_currentActivePageIndex!);

    // 上报页面访问数据
    PageRouteService.reportPageView(
      duration: duration,
      pagePath: pagePath,
      prePagePath: nextPagePath,
    );

    // 移除已上报的页面时间记录
    _pageEnterTimes.remove(_currentActivePageIndex);

    // 清空当前活跃页面索引，因为主页面已经离开
    _currentActivePageIndex = null;

    print(
        '主页面离开上报: 页面=$pagePath, 时长=${PageRouteService.getDurationText(duration.round())}, 下一页=$nextPagePath');
  }

  /// 获取页面路由路径
  String _getPagePath(int index) {
    switch (index) {
      case 0:
        return Routes.home;
      case 1:
        return Routes.square;
      case 2:
        return Routes.profile;
      default:
        return Routes.main;
    }
  }

  /// 跳转到指定页面
  void navigateToPage(int index) {
    if (index < 0 || index >= tabBarPages.length) return;

    // 如果正在处理路由变化，跳过
    if (_isHandlingRouteChange) {
      currentIndex.value = index;
      return;
    }

    // 保存当前页面的索引作为上一个页面
    final int? previousPageIndex = _currentActivePageIndex;

    // 上报当前页面停留时长
    if (previousPageIndex != null) {
      reportPageDuration(previousPageIndex, index);
    }

    currentIndex.value = index;
    recordPageEnter(index);
  }

  @override
  void onClose() {
    // 上报当前活跃页面的停留时长
    if (_currentActivePageIndex != null) {
      reportPageDuration(_currentActivePageIndex!);
    }
    super.onClose();
  }
}
