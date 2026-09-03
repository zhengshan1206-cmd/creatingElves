/*
 * @Author: cold-x
 * @Date: 2025-09-09 13:46:49
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-09-09 13:50:12
 * @FilePath: /fastcreationmaster/lib/core/service/refresh_manager.dart
 * @Description: 
 */


import 'package:easy_refresh/easy_refresh.dart';

import '../util/page_helper.dart';

///上下拉刷新控制器
class RefreshManager {

  final EasyRefreshController _easyRefreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  EasyRefreshController get refreshController => _easyRefreshController;

  final PageHelper _pageHelper = PageHelper();

  PageHelper get pageHelper => _pageHelper;

  void refreshSuccess(bool isRefresh, bool hasMore) {
    if (isRefresh) {
      _easyRefreshController.finishRefresh(IndicatorResult.success, false);
      if (hasMore) {
        _easyRefreshController.resetFooter();
      }
    } else {
      _easyRefreshController.finishLoad(
          hasMore ? IndicatorResult.success : IndicatorResult.noMore, true);
    }
  }

  void refreshFailed(bool isRefresh) {
    if (isRefresh) {
      _easyRefreshController.finishRefresh(IndicatorResult.fail, false);
    } else {
      _easyRefreshController.finishLoad(IndicatorResult.fail, false);
    }
  }
}