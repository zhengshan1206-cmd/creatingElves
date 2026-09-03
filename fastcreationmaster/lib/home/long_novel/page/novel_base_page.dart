/*
 * @Author: cold-x
 * @Date: 2025-06-05 15:00:35
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-07-11 17:45:17
 * @FilePath: /fastcreationmaster/lib/home/long_novel/page/novel_base_page.dart
 * @Description: 长文小说基础页
 */

import 'package:fast_creation_master/core/controller/base_record_controller.dart';
import 'package:fast_creation_master/core/widget/page/base_page.dart';
import 'package:fast_creation_master/home/long_novel/view/create_step_view.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class NovelCreateBasePage extends BasePage {
  NovelCreateBasePage({
    super.key,
  });

  @override
  String get title => '长文小说';

  ///类型
  CreationType type = CreationType.novel;

  NovelCreateStepType stepType = NovelCreateStepType.brief;

  ///头部进度视图
  Widget buildStepView(){
    return CreateStepView(currentStep: stepType.rawValue);
  }

  // @override
  // Widget buildActions(BuildContext context) {
  //   return GestureDetector(
  //     child: Container(
  //       padding: EdgeInsets.all(12.w),
  //       child: ByWidgetsUtil.commonText(
  //         bgColor: Colors.transparent,
  //         textColor: ByColorUtil.colorC1,
  //         fontWeight: FontWeight.w500,
  //         fontSize: 14,
  //         text: '创作记录', 
  //       ),
  //     ),
  //     onTap: () {
  //       Get.toNamed(Routes.novelRecord, arguments: {'type':  type});
  //     },
  //   );
  // }
}
