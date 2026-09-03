/*
 * @Author: cold-x
 * @Date: 2025-06-05 17:44:46
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-07-16 17:27:15
 * @FilePath: /fastcreationmaster/lib/home/tool/page/name_finish_page.dart
 * @Description: 
 */
import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/controller/base_record_controller.dart';
import 'package:fast_creation_master/core/widget/page/base_page.dart';
import 'package:fast_creation_master/core/widget/view/by_button.dart';
import 'package:fast_creation_master/core/widget/view/muti_status_view.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:fast_creation_master/home/tool/bean/tool_bean.dart';
import 'package:fast_creation_master/home/tool/controller/name_finish_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/util/by_screen_utils.dart';
import '../../../global/routes/app_pages.dart';

// ignore: must_be_immutable
class NameFinishPage extends BasePage {
  NameFinishPage({super.key});

  @override
  NameFinishController get controller => Get.find<NameFinishController>();

  ///获取标题
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
        Get.toNamed(Routes.record, arguments: {'type': controller.type});
      },
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(12.w),
        child: Obx(
          () => MultiStatusView(
            currentStatus: controller.statusType.value,
            action: () {
              controller.fetchNames();
            },
            child: Column(
              children: [
                Expanded(
                    child: SingleChildScrollView(
                  child: Column(
                    children: newMethod,
                  ),
                )),
                SizedBox(
                  height: 12.w,
                ),
                SizedBox(
                  height: 48.w,
                  child: ByButton.gradientBtn(
                      padding: EdgeInsets.zero,
                      bgColor: ByColorUtil.color2E3038,
                      textColor: ByColorUtil.colorC1,
                      title: '不满意，继续生成',
                      onClick: () {
                        controller.createNames();
                      }),
                ),
                SizedBox(
                  height: 4.w + ByScreenUtils.bottomSafeHeight,
                )
              ],
            ),
          ),
        ));
  }

  List<Widget> get newMethod {
    return [
      Obx(() => SizedBox(
            height: controller.itemList.length * 60.w,
            child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  ToolBean item = controller.itemList[index];
                  return ByButton.toolNameGrandiant(item.content ?? '');
                },
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: 12.w,
                  );
                },
                itemCount: controller.itemList.length),
          )),
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.w),
          color: ByColorUtil.colorBg2,
        ),
        child: Column(
          children: [
            for (String id in controller.itemTitles.keys)
              Container(
                padding: EdgeInsetsDirectional.only(bottom: 12.h),
                child: _descriptionView(controller.itemTitles[id] ?? '',
                    controller.params['values'][id] ?? ''),
              ),
            _descriptionView('生成数量', '${controller.params['generate_num']}'),
          ],
        ),
      ),
      SizedBox(
        height: 12.w,
      ),
    ];
  }

  ///说明组件
  ///一行
  Widget _descriptionView(String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ByWidgetsUtil.commonText(
          text: title,
          textColor: Colors.white,
          fontSize: 14,
        ),
        const Spacer(),
        Container(
          alignment: Alignment.centerRight,
          constraints: BoxConstraints(
            maxWidth: 247.w,
          ),
          child: ByWidgetsUtil.commonText(
            text: content,
            textAlign: TextAlign.right,
            maxLines: 999,
            textColor: const Color(0xFFA0A0A7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
