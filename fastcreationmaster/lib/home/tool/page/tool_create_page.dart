/*
 * @Author: cold-x
 * @Date: 2025-06-12 10:13:19
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-06-24 13:39:08
 * @FilePath: /fastcreationmaster/lib/home/tool/page/tool_create_page.dart
 * @Description: 
 */


import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/controller/base_record_controller.dart';
import 'package:fast_creation_master/core/widget/page/base_page.dart';
import 'package:fast_creation_master/core/widget/view/muti_status_view.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../global/routes/app_pages.dart';
import '../view/tool_create_view.dart';
import '../controller/tool_create_controller.dart';

// ignore: must_be_immutable
class ToolCreatePage extends BasePage {
  ToolCreatePage({
    super.key,
    this.type});

  ///创建类型
  final CreationType? type;

  @override
  ToolCreateController get controller {
    bool register = Get.isRegistered<ToolCreateController>();
    if (register) {
      return Get.find<ToolCreateController>();
    }
    else {
      return Get.put(ToolCreateController(type: type!));
    }
  }

  @override
  String get title => controller.type.title;
  
  @override
  Widget buildActions(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.all(12.w),
        child: ByWidgetsUtil.commonText(
          bgColor: Colors.transparent,
          textColor: ByColorUtil.colorC1,
          fontWeight: FontWeight.w500,
          fontSize: 14,
          text: '创作记录', 
        ),
      ),
      onTap: () {
        Get.toNamed(Routes.record, arguments: {'type' : controller.type});
      },
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return Obx(() => MultiStatusView(
      currentStatus: controller.statusType.value,
      action: () {
        controller.fetchCreator();
      },
      child: ToolCreateView(
        type: controller.type,)
        ));
  }
  
}