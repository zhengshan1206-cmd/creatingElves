/*
 * @Author: cold-x
 * @Date: 2025-05-28 14:52:08
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-07-18 11:32:59
 * @FilePath: /fastcreationmaster/lib/core/widget/page/base_page.dart
 * @Description: 
 */

import 'dart:io';

import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../global/routes/app_pages.dart';

// ignore: must_be_immutable
class BasePage extends GetView {
  BasePage({
    super.key,
    this.parentRouteName,
    this.routeName,
  });
  String title = '';
  String? parentRouteName;
  String? routeName;

  ///是否显示导航栏
  bool hasAppBar = true;
  ///是否是引导页
  bool isGuidePage = false;

  @override
  Widget build(BuildContext context) {
    parentRouteName = Get.parameters['route'];
    return Scaffold(
      backgroundColor: ByColorUtil.colorBg1,
      appBar: hasAppBar ? buildAppBar(context) : null,
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return Center(
        child: Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 32),
    ));
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: ByColorUtil.colorBg1,
      toolbarHeight: Platform.isIOS ? 44 : kToolbarHeight,
      leading: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if(isGuidePage) {
            Get.offAllNamed(Routes.main);
          }
          else {
            Get.back();
          }
        },
        child: isGuidePage ? Container(
          width: 56,
          height: 32,
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: Image.asset(
              "assets/global/common/btn_close.png",
              width: 32,
              height: 32,
            ),
          ),
        ) : Container(
          width: 56,
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: Image.asset(
              "assets/global/common/btn_back.png",
              width: 16,
              height: 16,
            ),
          ),
        ),
      ),
      title: ByWidgetsUtil.commonText(
          text: title,
          textColor: Colors.white,
          fontSize: 17.sp,
          fontWeight: FontWeight.w500),
      actions: [
        buildActions(context),
      ],
    );
  }

  Widget buildActions(BuildContext context) {
    return Container();
  }
}
