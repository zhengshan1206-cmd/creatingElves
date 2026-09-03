/*
 * @Author: cold-x
 * @Date: 2025-06-18 15:41:20
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-28 09:22:59
 * @FilePath: /fastcreationmaster/lib/home/main_page/view/novel_list_cell.dart
 * @Description: 
 */

import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/service/data_service.dart';
import 'package:fast_creation_master/home/long_novel/controller/novel_home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../../core/widget/view/by_button.dart';
import '../../../global/routes/app_pages.dart';
import '../../long_novel/view/novel_home_view.dart';
import '../bean/home_novel_bean.dart';

enum NovelListCellType {
  ///创作记录
  record,

  ///默认
  normal,
}

class NovelListCell extends StatelessWidget {
  const NovelListCell(
      {super.key,
      this.itemList,
      this.type = NovelListCellType.normal,
      this.action});

  ///类型
  final NovelListCellType? type;

  ///数据内容
  final List<HomeNovelBean>? itemList;

  ///界面操作
  final void Function(HomeNovelBean)? action;

  @override
  Widget build(BuildContext context) {
    return WaterfallFlow.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 11.w,
        mainAxisSpacing: 10.h,
      ),
      itemCount: itemList?.length,
      itemBuilder: (context, index) {
        HomeNovelBean item = itemList![index];

        ///小说在广场的状态
        int status = getNovelStatus(item.tags!);
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadiusDirectional.circular(10.w),
            color: const Color(0xFF1E1F24),
          ),
          child: GestureDetector(
            onTap: () {
              Get.toNamed(Routes.novelHome, arguments: {
                'id': item.id,
                'type': NovelHomeSourceType.square
              });
              DataService.onEvent('home_square_same_style',
                  {'id': item.id, 'type': NovelHomeSourceType.square});
              action?.call(item);
            },
            child: ClipRRect(
              borderRadius: BorderRadiusDirectional.circular(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 228.w,
                    child: Stack(
                      children: [
                        ///封面图
                        Positioned.fill(
                          child: NovelCoverView(
                            cover: item.cover,
                            title: '',
                            // title: item.title,
                          ),
                        ),

                        ///写同款、阅读数
                        Positioned(
                            left: 6.w,
                            bottom: 6.w,
                            height: 20.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 2.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.w),
                                color: Colors.black.withOpacity(0.4),
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/home/main/icon_home_write.png',
                                    width: 12.w,
                                    height: 12.w,
                                  ),
                                  SizedBox(
                                    width: 4.w,
                                  ),
                                  ByWidgetsUtil.commonText(
                                      textColor: Colors.white,
                                      fontSize: 10,
                                      text: '${item.writeNum}'),
                                  SizedBox(
                                    width: 8.w,
                                  ),
                                  Container(
                                    width: 1.w,
                                    height: 12.w,
                                    color: Colors.white.withOpacity(0.24),
                                  ),
                                  SizedBox(
                                    width: 8.w,
                                  ),
                                  Image.asset(
                                    'assets/home/main/icon_home_view.png',
                                    width: 12.w,
                                    height: 12.w,
                                  ),
                                  SizedBox(
                                    width: 4.w,
                                  ),
                                  ByWidgetsUtil.commonText(
                                      textColor: Colors.white,
                                      fontSize: 10,
                                      text: '${item.viewNum}'),
                                ],
                              ),
                            )),

                        ///右上角图标标识
                        if (item.tags!.isNotEmpty && status > 1)
                          Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 42.w,
                                height: 18.w,
                                decoration: BoxDecoration(
                                    gradient: status == 2
                                        ? const LinearGradient(colors: [
                                            Color(0xFFFF5600),
                                            Color(0xFFFF8921)
                                          ])
                                        : const LinearGradient(colors: [
                                            Color(0xFF2358FF),
                                            Color(0xFF3288F9),
                                          ]),
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(8.w),
                                        topRight: Radius.circular(8.w))),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 4.w,
                                    ),
                                    Image.asset(
                                      'assets/home/main/icon_home_${status == 2 ? 'hot' : 'new'}.png',
                                      width: 14.w,
                                      height: 14.w,
                                    ),
                                    ByWidgetsUtil.commonText(
                                        textColor: Colors.white,
                                        fontSize: 10.sp,
                                        text: status == 2 ? '最热' : '最新'),
                                  ],
                                ),
                              ))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 12.w,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: ByWidgetsUtil.commonText(
                        text: item.title ?? '',
                        textColor: Colors.white,
                        fontSize: 14),
                  ),
                  SizedBox(
                    height: 8.w,
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: SizedBox(
                        height: 36.h,
                        child: ByButton.gradientImageBtn(
                          image: 'assets/home/main/btn_home_write.png',
                          fontSize: 13,
                          textColor: const Color(0xFF162408),
                          title: "写同款",
                          borderRadius: 20.w,
                          padding: EdgeInsets.symmetric(
                              horizontal: 0.w, vertical: 0.w),
                          onClick: () {
                            Get.toNamed(Routes.novelHome, arguments: {
                              'id': item.id,
                              'type': NovelHomeSourceType.square
                            });
                            DataService.onEvent('home_square_same_style', {
                              'id': item.id,
                              'type': NovelHomeSourceType.square
                            });
                            action?.call(item);
                          },
                        ),
                      )),
                  SizedBox(
                    height: 12.w,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  ///获取小说广场状态
  ///1=普通 2=热门 3=最新  优先度 热门 > 最新 > 普通
  int getNovelStatus(List<dynamic> tags) {
    if (tags.isEmpty) {
      return 1;
    }
    if (tags.contains('2')) {
      return 2;
    } else if (tags.contains('3')) {
      return 3;
    }
    return 1;
  }
}
