/*
 * @Author: cold-x
 * @Date: 2025-06-26 11:05:30
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-27 14:01:01
 * @FilePath: /fastcreationmaster/lib/home/long_novel/page/novel_record_page.dart
 * @Description: 
 */

import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:fast_creation_master/core/widget/page/base_record_page.dart';
import 'package:fast_creation_master/core/widget/view/muti_status_view.dart';
import 'package:fast_creation_master/core/widget/view/progress_bar.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:fast_creation_master/home/long_novel/bean/novel_bean.dart';
import 'package:fast_creation_master/home/long_novel/bean/novel_notify_bean.dart'
    hide TextStyle;
import 'package:fast_creation_master/home/long_novel/controller/novel_record_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/controller/user_controller.dart';
import '../../../core/util/by_screen_utils.dart';
import '../../../core/widget/view/by_button.dart';
import '../../../global/routes/app_pages.dart';
import '../../../global/routes/routes_utils.dart';
import '../view/novel_home_view.dart';

///长文、短篇小说记录页； 短故事和其他小说工具类记录在BaseRecordPage页中
// ignore: must_be_immutable
class NovelRecordPage extends BaseRecordPage {
  NovelRecordPage({
    super.key,
  });

  @override
  NovelRecordController get controller => Get.find<NovelRecordController>();

  final userController = Get.find<UserController>();

  @override
  Widget buildActions(BuildContext context) {
    return Obx(() {
      return controller.novelList.isNotEmpty
          ? super.buildActions(context)
          : Container();
    });
  }

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        // _buildCategoryView(),
        // const SizedBox(
        //   height: 4,
        // ),
        //非vip才显示
        if (userController.userInfoBean.value?.isVip == 0) _hintTextView(),
        // Expanded(
        //   child: PageView.builder(
        //     itemCount: controller.pageTitles.length,
        //     controller: controller.pageController,
        //     itemBuilder: (context, index) {
        //       return buildContentView(index);
        //     },
        //     onPageChanged: (value) {
        //       controller.onPageChanged(value);
        //     },
        //   ),
        // ),
        Expanded(child: buildContentView(0)),
      ],
    );
  }

  ///记录分类
  Widget _buildCategoryView() {
    return Container(
      height: 44.w,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
      child: Row(
        children: [
          for (int i = 0; i < controller.pageTitles.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  ///点击分类
                  if (controller.pageController.page != i) {
                    controller.onPageChanged(i);
                    controller.pageAnimating = true;
                    controller.pageController
                        .animateToPage(i,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut)
                        .whenComplete(() {
                      controller.pageAnimating = false;
                    });
                  }
                },
                child: Obx(() => Container(
                      height: 28.w,
                      margin: EdgeInsets.only(right: i == 3 ? 0 : 12.w),
                      decoration: controller.pageIndex.value == i
                          ? BoxDecoration(
                              gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFCBF203),
                                    Color(0xFF0181FC)
                                  ]),
                              borderRadius: BorderRadius.circular(14.w),
                            )
                          : BoxDecoration(
                              color: ByColorUtil.colorBg2,
                              borderRadius: BorderRadius.circular(14.w),
                            ),
                      child: Center(
                        child: ByWidgetsUtil.commonText(
                            textColor: controller.pageIndex.value == i
                                ? ByColorUtil.colorF8
                                : ByColorUtil.colorF2,
                            text: controller.pageTitles[i]),
                      ),
                    )),
              ),
            )
        ],
      ),
    );
  }

  ///记录页内容
  Widget buildContentView(int index) {
    return Column(
      children: [
        Expanded(
          child: EasyRefresh(
            controller: controller.refreshManagers[index].refreshController,
            onRefresh: () {
              controller.fetchNovelRecordList(
                  true, controller.refreshManagers[index]);
            },
            onLoad: () {
              controller.fetchNovelRecordList(
                  false, controller.refreshManagers[index]);
            },
            child: Padding(
              padding: EdgeInsets.only(
                  left: 12.w, right: 12.w, bottom: 12.w, top: 12.w),
              child: Obx(() => MultiStatusView(
                    emptyActionType: EmptyActionType.all,
                    emptyText: '暂无创作记录',
                    emptyActionText: '去创作',
                    currentStatus: controller.statusType.value,
                    emptyAction: () {
                      NavigateUtils.navigateToPageAfterBacktoMain(
                          Routes.novelCreate, {
                        'novel_type': controller.type,
                      });
                    },
                    action: () {
                      controller.fetchNovelRecordList(
                          true, controller.refreshManagers[index]);
                    },
                    child: GridView.builder(
                        padding: EdgeInsets.zero,
                        clipBehavior: Clip.none,
                        // shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 11.w,
                          crossAxisSpacing: 11.w,
                          childAspectRatio: 200 / 375, // 宽高比
                        ),
                        itemCount: controller.novelList.length,
                        itemBuilder: (context, index) {
                          NovelBean bean = controller.novelList[index];
                          return GestureDetector(
                            onTap: () {
                              if (controller.isManaging.value) {
                                if (bean.pauseStatus == 1 || bean.stage == 10) {
                                  controller.updateDeleteRecordIds(bean.id!);
                                } else {
                                  BotToast.showText(text: '小说完成后或断更后支持删除哦。');
                                }
                              } else {
                                controller.gotoPage(bean,
                                    goNovelHome: true, stage: bean.stage);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadiusDirectional.circular(10.w),
                                color: const Color(0xFF1E1F24),
                              ),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadiusDirectional.circular(10.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 228.w,
                                      child: Stack(
                                        children: [
                                          ///状态设置
                                          Positioned.fill(
                                            child: _setNovelStatus(bean),
                                          ),

                                          Obx(() => Positioned.fill(
                                                  child: Offstage(
                                                offstage: !(controller
                                                        .isManaging.value &&
                                                    (bean.pauseStatus == 1 ||
                                                        bean.stage == 10) &&
                                                    controller.deleteRecordIds
                                                        .contains(bean.id)),
                                                child: Container(
                                                  color: ByColorUtil.colorF8
                                                      .withOpacity(0.64),
                                                ),
                                              ))),

                                          ///生成失败、完成、断更的标签
                                          if ([3, 6, 9, 10]
                                                  .contains(bean.stage) ||
                                              bean.pauseStatus != 2 ||
                                              bean.chapterStage == 4 ||
                                              bean.contentStage == 4)
                                            Positioned(
                                              left: 0,
                                              top: 0,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8.w,
                                                    vertical: 6.w),
                                                decoration: BoxDecoration(
                                                    color: bean.stage == 10
                                                        ? ByColorUtil.colorC1
                                                        : ByColorUtil.colorG4,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(10.w),
                                                      bottomRight:
                                                          Radius.circular(10.w),
                                                    )),
                                                child: ByWidgetsUtil.commonText(
                                                    text: controller
                                                        .setStatusTag(bean),
                                                    textColor: bean.stage == 10
                                                        ? Colors.black
                                                        : ByColorUtil.colorF1,
                                                    fontSize: 12),
                                              ),
                                            ),

                                          Obx(() => Positioned(
                                                right: 8.w,
                                                top: 8.w,
                                                child: Offstage(
                                                  offstage: !(controller
                                                          .isManaging.value &&
                                                      (bean.pauseStatus == 1 ||
                                                          bean.stage == 10)),

                                                  ///管理选择和未选中的按钮
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      controller
                                                          .updateDeleteRecordIds(
                                                              bean.id!);
                                                    },
                                                    child: SizedBox(
                                                      width: 20.w,
                                                      height: 20.w,
                                                      child: Image.asset(
                                                        controller
                                                                .deleteRecordIds
                                                                .contains(
                                                                    bean.id)
                                                            ? 'assets/global/common/btn_record_selected.png'
                                                            : 'assets/global/common/btn_record.png',
                                                        width: 20.w,
                                                        height: 20.w,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 12.w,
                                    ),

                                    ///标题
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.w),
                                      child: ByWidgetsUtil.commonText(
                                          text: bean.title ?? '',
                                          textColor: ByColorUtil.colorF1,
                                          fontSize: 14),
                                    ),
                                    SizedBox(
                                      height: 8.w,
                                    ),

                                    ///简介
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.w),
                                      child: ByWidgetsUtil.commonText(
                                          maxLines: 2,
                                          text: bean.introduce ?? '',
                                          textColor: ByColorUtil.colorF2,
                                          fontSize: 12),
                                    ),
                                    SizedBox(
                                      height: 12.w,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                  )),
            ),
          ),
        ),
        Obx(() => Offstage(
              offstage: !controller.isManaging.value,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Container(
                  height: 56.w + ByScreenUtils.bottomSafeHeight,
                  padding: EdgeInsets.only(
                      top: 4.w, bottom: ByScreenUtils.bottomSafeHeight + 4.w),
                  child: SizedBox(
                    height: 48.w,
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
              ),
            )),
      ],
    );
  }

  ///设置状态
  _setNovelStatus(NovelBean bean) {
    ///小说暂停状态 并且未完成时
    if (bean.pauseStatus != 2 && bean.stage! != 10) {
      return NovelCoverView(
        cover: bean.cover,
        title: bean.title,
      );
    }
    switch (bean.stage) {
      ///已提交
      case 1:

      ///灵感生成中
      case 2:

      ///5=大纲生成中
      case 5:
        return _buildGeneratingView(bean.stage == 5 ? '大纲' : '灵感');

      ///灵感生成完成
      case 4:

      ///大纲生成成功
      case 7:
        return _buildCompeleView(bean);

      ///灵感生成失败
      case 3:

      ///大纲生成失败
      case 6:
        return _buildFailedView(bean);

      ///正文生成中【包含细纲生成，正文生成】
      case 8:

        ///优先级：失败的优先展示
        ///正文生成有失败时
        if (bean.contentStage == 4) {
          return _buildFailedView(bean);
        }

        ///细纲生成有失败时
        if (bean.chapterStage == 4) {
          return _buildFailedView(bean);
        }

        ///有正文时
        if (bean.contentStage! > 1 ||
            (bean.contentStage == 1 && bean.chapterStage == 1)) {
          double progress = bean.generateChapters! / bean.chaptersNum!;
          return _buildStatusBgView(children: [
            ByWidgetsUtil.commonRichText(
                textColor: ByColorUtil.colorC1,
                texts: [
                  TextSpan(
                      text: '${(progress * 100).floor()}',
                      style: const TextStyle(fontSize: 24)),
                  const TextSpan(text: '%'),
                ]),
            SizedBox(
              height: 4.w,
            ),
            SizedBox(
                width: 123.w,
                height: 4.w,
                child: ProgressBar(
                  trackColor: ByColorUtil.colorL1,
                  progressGradiantColor: const LinearGradient(colors: [
                    ByColorUtil.colorC1,
                    Color(0xFF0BBA92),
                    Color(0xFF0181FC)
                  ]),
                  progress: progress,
                )),
            SizedBox(
              height: 8.w,
            ),
            ByWidgetsUtil.commonText(
                textColor: ByColorUtil.colorF1, text: '正文生成中，请稍等'),
          ]);
        }

        ///没有正文并且细纲在生成中
        if (bean.contentStage == 1 && bean.chapterStage == 2) {
          return _buildGeneratingView('细纲');
        }

        ///没有正文并且没有正在生成的细纲
        if (bean.contentStage == 1 && [3, 5].contains(bean.chapterStage)) {
          return _buildCompeleView(bean);
        }
        return Container();

      ///暂停中
      case 9:

      ///生成完成
      case 10:

        ///封面图
        return NovelCoverView(
          cover: bean.cover,
          title: bean.title,
        );
      case 11:
      default:
        return Container();
    }
  }

  ///生成中
  Widget _buildGeneratingView(String title) {
    return _buildStatusBgView(children: [
      CupertinoActivityIndicator(
        color: ByColorUtil.colorC1,
        radius: 15.w,
      ),
      SizedBox(
        height: 20.0.w,
      ),
      ByWidgetsUtil.commonText(
          text: '$title生成中，请稍等', textColor: ByColorUtil.colorC1),
    ]);
  }

  ///生成失败
  Widget _buildFailedView(NovelBean bean) {
    return _buildStatusBgView(children: [
      SizedBox(
        height: 44.w,
      ),
      Image.asset(
        'assets/home/novel/icon_novel_record_failed.png',
        width: 80.w,
        height: 80.w,
      ),
      SizedBox(
        height: 4.w,
      ),
      ByWidgetsUtil.commonText(textColor: ByColorUtil.colorF2, text: '生成失败'),
      const Spacer(),
      GestureDetector(
        onTap: () {
          controller.gotoPage(bean, goNovelHome: bean.stage! >= 8);
        },
        child: Container(
          width: 100.w,
          height: 36.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.w),
              color: ByColorUtil.colorC1),
          child: Center(
            child: ByWidgetsUtil.commonText(
                fontWeight: FontWeight.w500,
                textColor: Colors.black,
                text: '重新生成'),
          ),
        ),
      ),
      SizedBox(
        height: 20.w,
      ),
    ]);
  }

  ///阶段生成完成
  Widget _buildCompeleView(NovelBean bean) {
    final String title = bean.stage == 4
        ? '灵感生成完成'
        : bean.stage == 7
            ? '大纲生成完成'
            : '距离生成小说正文就差最后一步了';
    final String next = bean.stage == 4
        ? '生成大纲'
        : bean.stage == 7
            ? '生成细纲'
            : '一键成文';
    return _buildStatusBgView(children: [
      SizedBox(
        height: 60.w,
      ),
      Image.asset(
        'assets/home/main/icon_novel_record_finish.png',
        width: 40.w,
        height: 40.w,
      ),
      SizedBox(
        height: 8.w,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: ByWidgetsUtil.commonText(
            textColor: ByColorUtil.colorF1,
            text: title,
            textAlign: TextAlign.center,
            maxLines: 2),
      ),
      const Spacer(),
      GestureDetector(
        onTap: () {
          controller.gotoPage(bean);
        },
        child: Container(
          width: 100.w,
          height: 36.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.w),
              color: ByColorUtil.colorC1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ByWidgetsUtil.commonText(
                  fontWeight: FontWeight.w500,
                  textColor: Colors.black,
                  text: next),
              SizedBox(
                width: 4.w,
              ),
              Image.asset(
                'assets/global/common/icon_detail_black.png',
                width: 12.w,
                height: 12.w,
              ),
            ],
          ),
        ),
      ),
      SizedBox(
        height: 20.w,
      ),
    ]);
  }

  ///状态背景
  Widget _buildStatusBgView({children = const <Widget>[]}) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
                ByColorUtil.colorC1,
                Color(0xFF0BBA92),
                Color(0xFF0181FC)
              ]),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            color: ByColorUtil.colorBg1.withOpacity(0.64),
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

      print("Building hint view with ${bannerList.length} items");

      return Container(
        height: 44.w,
        decoration: BoxDecoration(color: Color(0XFF1E1F24).withOpacity(0.5)),
        alignment: Alignment.center,
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
