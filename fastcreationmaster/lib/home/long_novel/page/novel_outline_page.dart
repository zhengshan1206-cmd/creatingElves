/*
 * @Author: cold-x
 * @Date: 2025-06-16 20:39:44
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-07-17 15:55:55
 * @FilePath: /fastcreationmaster/lib/home/long_novel/page/novel_outline_page.dart
 * @Description: 
 */

import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/widget/view/muti_status_view.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:fast_creation_master/home/long_novel/bean/novel_outline_bean.dart';
import 'package:fast_creation_master/home/long_novel/controller/novel_outline_controller.dart';
import 'package:fast_creation_master/home/long_novel/controller/outline_detail_provider.dart';
import 'package:fast_creation_master/home/long_novel/page/novel_outline_detail_page.dart';
import 'package:fast_creation_master/core/widget/view/provider_page_tracker.dart';
import 'package:fast_creation_master/home/long_novel/view/create_step_view.dart';
import 'package:fast_creation_master/home/long_novel/view/novel_home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'novel_base_page.dart';

// ignore: must_be_immutable
class NovelOutlinePage extends NovelCreateBasePage {
  NovelOutlinePage({super.key});

  @override
  String get title => '章节大纲';

  @override
  NovelOutlineController get controller => Get.find<NovelOutlineController>();

  @override
  NovelCreateStepType get stepType => NovelCreateStepType.outline;

  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        children: [
          ///顶部进度视图
          buildStepView(),
          SizedBox(
            height: 12.w,
          ),

          Expanded(
              child: Obx(() => MultiStatusView(
                    currentStatus: controller.statusType.value,
                    child: ListView.builder(
                        itemCount: controller.itemList.length,
                        itemBuilder: (context, index) {
                          OutlineBean bean = controller.itemList[index];
                          return GestureDetector(
                            onTap: () {
                              ///提交状态下的大纲无法查看详情页
                              if (bean.stage! < 2) {
                                return;
                              }
                              controller.viewDidDisappear();
                              final provider = OutlineDetailProvider();
                              ByNavRouterUtils.push(
                                context,
                                trackProviderPage(
                                  pageId: '/novel_outline_detail_page',
                                  widget: ChangeNotifierProvider(
                                    create: (context) => provider,
                                    child: NovelOutlineDetailPage(
                                      id: bean.id!,
                                    ),
                                  ),
                                ),
                              ).then((_) {
                                controller.viewDidAppear();
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: index == 0 ? 0 : 6.w, bottom: 6.w),
                              child: Container(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12.w),
                                  height: 50.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.w),
                                    color: ByColorUtil.colorBg2,
                                  ),
                                  child: Row(
                                    children: [
                                      ///是否生成结束的标识
                                      Offstage(
                                        offstage:
                                            [1, 2, 4].contains(bean.stage),
                                        child: Image.asset(
                                          'assets/home/novel/icon_checkbox_selected.png',
                                          width: 14.w,
                                          height: 14.w,
                                        ),
                                      ),
                                      if (![1, 2, 4].contains(bean.stage))
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                      Container(
                                        constraints: BoxConstraints(
                                          maxWidth: 110.w,
                                        ),
                                        child: ByWidgetsUtil.commonText(
                                            textColor: ByColorUtil.colorF1,
                                            text: '篇章${bean.index}'),
                                      ),
                                      SizedBox(
                                        width: 6.w,
                                      ),
                                      Container(
                                        child: ByWidgetsUtil.commonText(
                                            textColor: ByColorUtil.colorF2,
                                            text:
                                                '(第${bean.bindChapter?[0]}-${bean.bindChapter?[1]}章)'),
                                      ),
                                      const Spacer(),
                                      _chooseOutlineStatus(bean),
                                    ],
                                  )),
                            ),
                          );
                        }),
                  ))),
        ],
      ),
    );
  }

  _chooseOutlineStatus(OutlineBean bean) {
    ///大纲生成完毕，并且当前符合可生成细纲的篇章
    if (controller.novelStatus >= 7 &&
        bean.index == controller.currentOutlineIndex.value &&
        bean.stage! != 5) {
      return Container(
        width: 80.w,
        height: 32.w,
        decoration: BoxDecoration(
          color: ByColorUtil.colorC1,
          borderRadius: BorderRadius.circular(16.w),
        ),
        child: Center(
          child:
              ByWidgetsUtil.commonText(textColor: Colors.black, text: '生成细纲'),
        ),
      );
    }
    switch (bean.stage) {
      ///生成失败
      case 4:
        return Container();

      ///生成中
      case 2:
      case 5:
        return GenerateProgressView(
          progressText: bean.stage! == 2 ? '生成中' : '细纲生成中',
          progress: -1,
        );

      ///等待生成
      case 1:
        return ByWidgetsUtil.commonText(
            textColor: ByColorUtil.colorF2, text: '等待生成中~');

      ///生成完成
      default:
        return Row(
          children: [
            if (bean.stage == 6)
              ByWidgetsUtil.commonText(
                  textColor: ByColorUtil.colorC1, text: '查看详情'),
            SizedBox(
              width: 4.w,
            ),
            Image.asset(
              'assets/home/novel/icon_novel_detail.png',
              width: 14.w,
              height: 14.w,
            ),
          ],
        );
    }
  }
}
