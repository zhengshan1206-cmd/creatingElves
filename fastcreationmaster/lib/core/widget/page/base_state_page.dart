/*
 * @Author: cold-x
 * @Date: 2025-06-25 20:15:29
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-06-25 20:29:55
 * @FilePath: /fastcreationmaster/lib/core/widget/page/base_state_page.dart
 * @Description: 
 */


import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../global/ui/colors.dart';

class BaseStatePage extends StatefulWidget {
  const BaseStatePage({super.key});

  @override
  State<BaseStatePage> createState() => _BaseStatePageState();
}

class _BaseStatePageState extends State<BaseStatePage> {

  ///是否显示导航栏
  bool get hasAppBar => true;
  
  String get title => '';

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: Colors.transparent,
      leading: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Get.back();
        },
        child: Container(
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
          fontSize: 17,
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