/*
 * @Author: cold-x
 * @Date: 2025-06-06 11:11:43
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-09-09 16:09:17
 * @FilePath: /fastcreationmaster/lib/core/widget/page/base_record_page.dart
 * @Description: 
 */

import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:fast_creation_master/core/controller/base_record_controller.dart';
import 'package:fast_creation_master/core/widget/view/by_button.dart';
import 'package:fast_creation_master/core/widget/view/muti_status_view.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:fast_creation_master/home/long_novel/bean/novel_bean.dart';
import 'package:fast_creation_master/home/long_novel/bean/novel_notify_bean.dart'
    hide TextStyle;
import 'package:fast_creation_master/home/long_novel/view/novel_home_view.dart';
import 'package:fast_creation_master/home/tool/bean/tool_bean.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import '../../../core/widget/page/base_page.dart';
import '../../../global/routes/app_pages.dart';
import '../../../global/routes/routes_utils.dart';
import '../../controller/user_controller.dart';
import '../../service/data_service.dart';
import '../../util/by_screen_utils.dart';

// ignore: must_be_immutable
class BaseRecordPage extends BasePage {
  BaseRecordPage({
    super.key,
  });

  @override
  String get title => '创作记录';

  final userController = Get.find<UserController>();

  @override
  BaseRecordController get controller => Get.find<BaseRecordController>();

  @override
  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ///如果是管理状态，点击取消管理，否则返回
          controller.isManaging.value
              ? controller.cancelManaging()
              : Get.back();
        },
        child: Container(
          width: 56,
          height: 30,
          padding: EdgeInsets.only(left: 12.w),
          alignment: Alignment.centerLeft,
          child: Obx(() => Padding(
                padding: const EdgeInsets.all(0.0),
                child: controller.isManaging.value
                    ? ByWidgetsUtil.commonText(
                        bgColor: Colors.transparent,
                        textColor: ByColorUtil.colorC1,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        text: '取消',
                      )
                    : Image.asset(
                        "assets/global/common/btn_back.png",
                        width: 16,
                        height: 16,
                      ),
              )),
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

  @override
  Widget buildActions(BuildContext context) {
    return Obx(() {
      return ([CreationType.novel, CreationType.shortNovel]
                  .contains(controller.type) ||
              controller.recordList.isNotEmpty)
          ? GestureDetector(
              child: Container(
                padding: EdgeInsets.all(12.w),
                child: ByWidgetsUtil.commonText(
                  bgColor: Colors.transparent,
                  textColor: ByColorUtil.colorC1,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  text: controller.updateManagingText(),
                ),
              ),
              onTap: () {
                controller.updateManagingStatus();
              },
            )
          : Container();
    });
  }

  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (![CreationType.folkNovel, CreationType.shortStory]
              .contains(controller.type))
            ByWidgetsUtil.commonText(
                text: '最近7天', fontSize: 12, textColor: ByColorUtil.colorF2),
          if (![CreationType.folkNovel, CreationType.shortStory]
              .contains(controller.type))
            SizedBox(
              height: 12.w,
            ),
          if (userController.userInfoBean.value?.isVip == 0) _hintTextView(),
          Expanded(
              child: EasyRefresh(
            ///下拉刷新
            onRefresh: () {
              controller.fetchRecordList(true);
            },

            ///上拉加载更多
            onLoad: () {
              controller.fetchRecordList(false);
            },
            controller: controller.refreshController,
            child: Obx(() => MultiStatusView(
                  emptyActionType: EmptyActionType.all,
                  emptyText: '暂无创作记录',
                  emptyActionText: '去创作',
                  currentStatus: controller.statusType.value,
                  emptyAction: () {
                    if (controller.type == CreationType.shortStory) {
                      NavigateUtils.navigateToPageAfterBacktoMain(
                          Routes.novelCreate, {
                        'novel_type': CreationType.shortStory,
                      });
                    } else {
                      NavigateUtils.navigateToPageAfterBacktoMain(
                          Routes.toolCreation, {
                        'novel_type': controller.type,
                      });
                    }
                  },
                  action: () {
                    controller.fetchRecordList(true);
                  },
                  child: ListView.builder(
                      itemCount: controller.recordList.length,
                      itemBuilder: (context, index) {
                        final item = controller.recordList[index];
                        return Padding(
                          padding: EdgeInsets.only(top: index == 0 ? 0 : 12.w),
                          child: Slidable(
                            key: ValueKey(item.id),
                            // 滑动方向和配置
                            enabled: !controller.isManaging.value,
                            endActionPane: ActionPane(
                              extentRatio: 0.2,
                              openThreshold: 0.2,
                              closeThreshold: 0.7,
                              dragDismissible: false,
                              motion: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color(0x3DFE5024),
                                ),
                                child: Center(
                                    child: GestureDetector(
                                  ///删除
                                  onTap: () {
                                    controller.deleteRecordIds.value = [
                                      item.id!
                                    ];
                                    controller.deleteRecordAction();
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/global/common/btn_record_delete.png',
                                        width: 20.w,
                                        height: 20.w,
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      ByWidgetsUtil.commonText(
                                          text: '删除',
                                          textColor: const Color(0xFFFE5024),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400)
                                    ],
                                  ),
                                )),
                              ),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {},
                                  label: '',
                                  autoClose: true,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Obx(() => Offstage(
                                      offstage: !controller.isManaging.value,

                                      ///管理选择和未选中的按钮
                                      child: GestureDetector(
                                        onTap: () {
                                          controller
                                              .updateDeleteRecordIds(item.id!);
                                        },
                                        child: Container(
                                          width: 20.w,
                                          constraints: BoxConstraints(
                                            minHeight: 60.w,
                                          ),
                                          child: Image.asset(
                                            controller.deleteRecordIds
                                                    .contains(item.id)
                                                ? 'assets/global/common/btn_record_selected.png'
                                                : 'assets/global/common/btn_record.png',
                                            width: 20.w,
                                            height: 20.w,
                                          ),
                                        ),
                                      ),
                                    )),
                                Obx(() => SizedBox(
                                      width: controller.isManaging.value
                                          ? 12.w
                                          : 0,
                                    )),
                                Expanded(
                                  child: _chooseCell(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                )),
          )),
          Obx(() => Offstage(
                offstage: !controller.isManaging.value,
                child: Container(
                  height: 56.w + ByScreenUtils.bottomSafeHeight,
                  padding: EdgeInsets.only(
                      bottom: ByScreenUtils.bottomSafeHeight + 4.w),
                  child: SizedBox(
                    height: 56.w,
                    child: ByButton.gradientImageBtn(
                        image: 'assets/global/common/btn_record_delete.png',
                        textColor: ByColorUtil.colorG4,
                        bgColor: ByColorUtil.color2E3038,
                        title: '删除',
                        onClick: () {
                          controller.deleteRecordAction();
                        }),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  ///根据类型选择组件
  Widget _chooseCell(int index) {
    switch (controller.type) {
      case CreationType.novelName:
      case CreationType.penName:

        ///小说名、笔名
        return toolCell(index);
      case CreationType.shortVideoScript:
      case CreationType.douyinAssistant:
      case CreationType.xhsAssistant:
      case CreationType.novelPromotion:

        ///短视频脚本、抖音标题小助手、小红书标题小助手、小说推广
        return promotionCell(index);
      case CreationType.folkNovel:

        ///旧版短故事
        return folkNovelCell(index);
      case CreationType.shortStory:

        ///新版短故事小说
        return shortStoryCell(index);
      default:
        return Container();
    }
  }

  ///短故事
  Widget shortStoryCell(int index) {
    final NovelBean item = controller.recordList[index];
    return GestureDetector(
      onTap: () {
        controller.clickCellEvent(item);
      },
      child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: ByColorUtil.colorBg2,
            borderRadius: BorderRadius.circular(10.w),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 69,
                height: 92,
                child: _setNovelStatus(item),
              ),
              const SizedBox(
                width: 12,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ByWidgetsUtil.commonText(
                      text: item.title ?? '',
                      textColor: ByColorUtil.colorF1,
                      fontSize: 17.sp),
                  const SizedBox(
                    height: 6,
                  ),
                  Row(
                    children: [
                      ByWidgetsUtil.commonText(
                          text: '${item.realityWords}字',
                          textColor: ByColorUtil.colorF2,
                          fontSize: 12.sp),
                      const SizedBox(
                        width: 4,
                      ),
                      Container(
                        width: 1,
                        height: 12,
                        color: ByColorUtil.colorF3.withOpacity(0.4),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      ByWidgetsUtil.commonText(
                          text: item.createTime ?? '',
                          textColor: ByColorUtil.colorF2,
                          fontSize: 12.sp),
                    ],
                  ),
                  const SizedBox(
                    height: 6,
                  ),

                  ///标签
                  Row(
                    children: [
                      for (int i = 0;
                          i < (item.tags!.length > 3 ? 3 : item.tags!.length);
                          i++)
                        Padding(
                          padding: EdgeInsets.only(
                              left: i == 0 ? 0 : 2.0.w, right: 2.w),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 6.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(8.w),
                            ),
                            child: ByWidgetsUtil.commonText(
                              textColor: ByColorUtil.colorF2,
                              fontSize: 12,
                              text: item.tags![i],
                            ),
                          ),
                        ),
                    ],
                  )
                ],
              )
            ],
          )),
    );
  }

  ///设置状态
  _setNovelStatus(NovelBean bean) {
    switch (bean.stage) {
      ///生成成功
      case 7:

      ///生成失败
      case 3:

      ///生成失败
      case 6:
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              NovelCoverView(
                cover: bean.cover,
                title: bean.title,
                radio: 0.5.w,
              ),
              Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    height: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                        color: [4, 7].contains(bean.stage)
                            ? ByColorUtil.colorC1
                            : ByColorUtil.colorG4,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            bottomRight: Radius.circular(6))),
                    child: ByWidgetsUtil.commonText(
                        text: [4, 7].contains(bean.stage) ? '已完成' : '生成失败',
                        fontSize: 11.sp,
                        textColor: [4, 7].contains(bean.stage)
                            ? ByColorUtil.colorF8
                            : ByColorUtil.colorF1,
                        fontWeight: FontWeight.w500),
                  ))
            ],
          ),
        );

      ///生成中
      case 1:
      case 2:
      case 4:
      case 5:
        return _buildStatusBgView(children: [
          const CupertinoActivityIndicator(
            color: ByColorUtil.colorC1,
            radius: 8,
          ),
          SizedBox(
            height: 8.w,
          ),
          ByWidgetsUtil.commonText(
              fontSize: 12.sp, textColor: ByColorUtil.colorF1, text: '生成中'),
        ]);
    }
  }

  ///状态背景
  Widget _buildStatusBgView({children = const <Widget>[]}) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(colors: [
                ByColorUtil.colorC1,
                Color(0xFF0BBA92),
                Color(0xFF0181FC)
              ]),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: ByColorUtil.colorBg1.withOpacity(0.64),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: children,
              ),
            ),
          ),
        )
      ],
    );
  }

  ///短故事
  Widget folkNovelCell(int index) {
    ToolBean item = controller.recordList[index];
    return GestureDetector(
      onTap: () {
        controller.clickCellEvent(item);
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: ByColorUtil.colorBg2,
          borderRadius: BorderRadius.circular(10.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // ByWidgetsUtil.commonText(
                //     textColor: Colors.white,
                //     fontSize: 17,
                //     text: item.title ?? ''),
                Expanded(
                  child: Text(
                    item.title ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                // const Spacer(),
                for (int i = 0;
                    i < (item.tag!.length > 3 ? 3 : item.tag!.length);
                    i++)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.0.w),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      child: ByWidgetsUtil.commonText(
                        textColor: ByColorUtil.colorF2,
                        fontSize: 12,
                        text: item.tag![i],
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(
              height: 12.w,
            ),
            ByWidgetsUtil.commonText(
                textColor: ByColorUtil.colorF2,
                fontSize: 12,
                maxLines: 4,
                text: item.content ?? ''),
          ],
        ),
      ),
    );
  }

  ///小说名、笔名
  Widget toolCell(int index) {
    ToolBean item = controller.recordList[index];
    return GestureDetector(
        onTap: () {
          controller.clickCellEvent(item);
        },
        child: ByButton.toolNameGrandiant(item.content ?? ''));
  }

  ///推广文案
  Widget promotionCell(int index) {
    ToolBean item = controller.recordList[index];
    return GestureDetector(
      onTap: () {
        controller.clickCellEvent(item);
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: ByColorUtil.colorBg2,
          borderRadius: BorderRadius.circular(10.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ByWidgetsUtil.commonText(
                textColor: ByColorUtil.colorF2,
                fontSize: 12,
                maxLines: 4,
                text: item.content ?? ''),
            SizedBox(
              height: 12.w,
            ),
            Row(
              children: [
                ByWidgetsUtil.commonText(
                    textColor: ByColorUtil.colorF2,
                    fontSize: 12,
                    text: '${item.word}字'),
                const Spacer(),
                ByWidgetsUtil.commonText(
                    textAlign: TextAlign.right,
                    textColor: ByColorUtil.colorF2,
                    fontSize: 12,
                    text: item.createDate ?? ''),
              ],
            )
          ],
        ),
      ),
    );
  }

  ///跑马灯提示文本效果
  Widget _hintTextView() {
    return Obx(() {
      // 检查是否有通知数据
      if (!controller.hasNotifyData) {
        return const SizedBox.shrink();
      }

      List<NovelNotifyItem> bannerList = controller.notifyList;

      // 确保有数据且数据有效
      if (bannerList.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        height: 44.w,
        decoration: BoxDecoration(color: Color(0XFF1E1F24).withOpacity(0.5)),
        alignment: Alignment.center,
        margin: EdgeInsets.only(
          bottom: 12.w,
        ),
        child: CarouselSlider(
          options: CarouselOptions(
              height: 35,
              viewportFraction: 1.0,
              autoPlay: bannerList.length > 1,
              autoPlayInterval: const Duration(seconds: 5),
              enableInfiniteScroll: bannerList.length > 1,
              scrollPhysics: const ClampingScrollPhysics(),
              scrollDirection: Axis.vertical),
          items: bannerList.map(
            (banner) {
              return Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () {
                      userController.checkPreLogin(
                          source: 'profile_creation_details',
                          actionCallback: () {
                            userController.jumpToPayPage(
                                isWordsEmpty: false, source: 'profile_creation_details');
                          });
                    },
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 12,
                        ),
                        Image.asset(
                          "assets/square/small_notice_icon.png",
                          width: 20.w,
                          height: 20.w,
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Expanded(
                          child: Text(
                            banner.complete,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          "立即充值",
                          style: TextStyle(
                            color: Color(0XFF98FC4A),
                            fontSize: 14.sp,
                          ),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Image.asset(
                          'assets/home/share_sales/open_business_icon.png',
                          width: 8,
                          height: 8,
                        ),
                        SizedBox(
                          width: 12.w,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ).toList(),
        ),
      );
    });
  }
}
