/*
 * @Author: cold-x
 * @Date: 2025-05-30 14:31:59
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-06-13 16:25:09
 * @FilePath: /fastcreationmaster/lib/core/controller/base_controller.dart
 * @Description: 
 */


import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../util/page_helper.dart';
import '../widget/view/muti_status_view.dart';

abstract class BaseController extends GetxController{

  final EasyRefreshController _easyRefreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  EasyRefreshController get refreshController => _easyRefreshController;

  final PageHelper _pageHelper = PageHelper();

  PageHelper get pageHelper => _pageHelper;

  ///内容状态
  Rx<MultiStatusType> statusType = MultiStatusType.statusContent.obs;


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

  void unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}