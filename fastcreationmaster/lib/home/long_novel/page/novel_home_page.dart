/*
 * @Author: cold-x
 * @Date: 2025-06-12 18:54:22
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-28 10:31:05
 * @FilePath: /fastcreationmaster/lib/home/long_novel/page/novel_home_page.dart
 * @Description: 小说首页页面
 */

import 'dart:io';

import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/core/service/data_service.dart';
import 'package:fast_creation_master/core/widget/view/muti_status_view.dart';
import 'package:fast_creation_master/home/long_novel/controller/novel_home_controller.dart';
import 'package:fast_creation_master/home/long_novel/view/novel_home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/util/by_screen_utils.dart';
import '../../../core/widget/page/base_page.dart';
import '../../../core/widget/view/by_button.dart';
import '../../../global/other/event_tracking/event_tracking.dart';
import '../../../global/routes/routes_utils.dart';
import '../../../global/ui/colors.dart';

// ignore: must_be_immutable
class NovelHomePage extends BasePage {
  NovelHomePage({
    super.key,
  });

  @override
  String get title => '';

  @override
  NovelHomeController get controller => Get.find<NovelHomeController>();

  @override
  bool get isGuidePage => controller.source == NovelHomeSourceType.guide;

  final userController = Get.find<UserController>();

  @override
  AppBar buildAppBar(BuildContext context) {
    double toolbarHeight = 44;
    toolbarHeight = Platform.isIOS ? 44 : kToolbarHeight;
    if(controller.source == NovelHomeSourceType.guide){
      toolbarHeight = 20;
    }
    return AppBar(
      backgroundColor: ByColorUtil.colorBg1,
      toolbarHeight: toolbarHeight,
      leading: !isGuidePage
          ? GestureDetector(
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
            )
          : null,
      actions: [
        buildActions(context),
      ],
    );
  }

  ///非vip才显示文案提示
  Widget _hintTextView() {
    return Container(
      padding: EdgeInsets.only(left: 0.w, right: 0.w, top: 0.w, bottom: 12.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ByWidgetsUtil.commonText(
                text: "您的剩余字数",
                fontSize: 12,
                textColor: ByColorUtil.colorF1.withOpacity(0.64),
              ),
              ByWidgetsUtil.commonText(
                text: " 只够0.5部小说",
                fontSize: 12,
                textColor: ByColorUtil.colorG4,
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              userController.checkPreLogin(
                source: 'novel_manage',
                actionCallback: () {
                  userController.jumpToPayPage(source: 'novel_manage');
                },
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ByWidgetsUtil.commonText(
                  text: "立即充值",
                  fontSize: 12,
                  textColor: Color(0XFF98FC4A),
                ),
                const SizedBox(
                  width: 4,
                ),
                Image.asset(
                  'assets/home/share_sales/open_business_icon.png',
                  width: 8,
                  height: 8,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget buildActions(BuildContext context) {
    return Obx(() => controller.bannerList.isNotEmpty &&
            controller.source != NovelHomeSourceType.guide
        ? GestureDetector(
            onTap: () {
              EventTracking.reportDataPoint(
                        pageTag: 'home_book_detail_contract_btn',
                        operateType: 'click',
                        funcDetailImg: '',
                        funcDetailTag: controller.novelID.toString());
              userController.checkPreLogin(
                  source: 'home',
                  actionCallback: () {
                    DataService.onEvent(
                        'banner_click', {'source': 'management'});
                    NavigateUtils.navigateTo(controller.bannerList.first);
                  });
            },
            child: Container(
              height: 32.w,
              padding: EdgeInsets.only(right: 12.w),
              constraints: BoxConstraints(maxWidth: 200.w),
              child: Image.network(
                controller.bannerList.first.imgUrl,
                height: 32.w,
                fit: BoxFit.fitHeight,
              ),
            ),
          )
        : Container());
  }

  @override
  Widget buildBody(BuildContext context) {
    return PopScope(
      canPop: !isGuidePage,
      child: Obx(
        () => MultiStatusView(
          currentStatus: controller.statusType.value,
          action: () {
            controller.fetchLaunchData();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Expanded(child: NovelHomeView()),
              SizedBox(
                height: 10.w,
              ),
              if (controller.novelBean.value?.pauseStatus == 3)
                SizedBox(
                  height: 36.w,
                  child: Center(
                    child: ByWidgetsUtil.commonText(
                      text: '当前生成中的内容完成后将断更。',
                      fontSize: 12,
                      textColor: ByColorUtil.colorG4,
                    ),
                  ),
                ),
              Obx(
                () {
                  return (controller.novelBean.value == null ||
                          (controller.novelBean.value!.stage! == 10 &&
                              controller.source == NovelHomeSourceType.normal))
                      ? Container()
                      : Padding(
                          padding: EdgeInsets.only(
                              left: 12.w,
                              right: 12.w,
                              top:
                                  controller.source == NovelHomeSourceType.guide
                                      ? 0
                                      : 4.w,
                              bottom: ByScreenUtils.bottomSafeHeight + 4.w),
                          child: controller.source != NovelHomeSourceType.normal
                              ? SizedBox(
                                  height: controller.source ==
                                          NovelHomeSourceType.guide
                                      ? 72.w
                                      : 56.w,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: controller.source ==
                                                NovelHomeSourceType.guide
                                            ? 18.w
                                            : 0,
                                        left: 0,
                                        right: 0,
                                        height: 48.w,
                                        child: ByButton.gradientImageBtn(
                                            image:
                                                'assets/home/main/btn_home_write.png',
                                            fontSize: 17,
                                            textColor: const Color(0xFF162408),
                                            title: "写同款",
                                            imageSize: 24.w,
                                            fontWeight: FontWeight.w600,
                                            onClick: () {
                                              controller.goWriteSame();
                                            }),
                                      ),

                                      ///底部圆角图标
                                      if (controller.source ==
                                              NovelHomeSourceType.guide &&
                                          controller.guideNovelBean.value!
                                              .bottomPrompt!.isNotEmpty)
                                        Positioned(
                                            right: 0.w,
                                            top: 23.w,
                                            child: SizedBox(
                                              width: 16.w,
                                              height: 16.w,
                                              child: Image.asset(
                                                'assets/home/novel/icon_bottomright_red_16.png',
                                                width: 16.w,
                                                height: 16.w,
                                              ),
                                            )),

                                      ///底部平台提示词
                                      if (controller.source ==
                                              NovelHomeSourceType.guide &&
                                          controller.guideNovelBean.value!
                                              .bottomPrompt!.isNotEmpty)
                                        Positioned(
                                          right: 0.w,
                                          top: 0.w,
                                          child: Container(
                                              height: 24.w,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 6.w),
                                              decoration: BoxDecoration(
                                                  gradient:
                                                      const LinearGradient(
                                                          colors: [
                                                        Color(0xFFFE5024),
                                                        Color(0xFFFF9A81)
                                                      ]),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(12.w),
                                                    bottomLeft:
                                                        Radius.circular(12.w),
                                                    topRight:
                                                        Radius.circular(12.w),
                                                  )),
                                              child: Center(
                                                child: ByWidgetsUtil.commonText(
                                                    text: controller
                                                            .guideNovelBean
                                                            .value
                                                            ?.bottomPrompt ??
                                                        '',
                                                    textColor:
                                                        ByColorUtil.colorF1,
                                                    fontSize: 11.sp),
                                              )),
                                        ),
                                    ],
                                  ),
                                )
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // 只在显示继续生成按钮且非会员时显示提示文案
                                    if (userController
                                            .userInfoBean.value?.isVip !=
                                        1)
                                      _hintTextView(),
                                    Opacity(
                                      opacity: controller.novelBean.value
                                                  ?.pauseStatus ==
                                              3
                                          ? 0.3
                                          : 1.0,
                                      child: ByButton.gradientBtn(
                                        gradient: !controller
                                                .canContinueGenerateNovel()
                                            ? ByColorUtil.colorVIP()
                                            : ByColorUtil.colorG1(),
                                        fontSize: 17,
                                        textColor: const Color(0xFF162408),
                                        title: !controller
                                                .canContinueGenerateNovel()
                                            ? "立即充值"
                                            : '继续生成',
                                        fontWeight: FontWeight.w600,
                                        onClick: () {
                                          userController.checkPreLogin(
                                            source: 'novel_home',
                                            actionCallback: () {
                                              ///字数不够时
                                              if (!controller
                                                  .canContinueGenerateNovel()) {
                                                Get.find<UserController>()
                                                    .jumpToPayPage(
                                                  source:
                                                      'novel_home_words_unable',
                                                );
                                              } else {
                                                ///暂停状态时
                                                if (controller.novelBean.value!
                                                        .pauseStatus! ==
                                                    1) {
                                                  controller
                                                      .continuePausedNovel(
                                                    onSuccess: () {
                                                      controller.gotoPage();
                                                    },
                                                  );
                                                } else {
                                                  controller.gotoPage();
                                                }
                                              }
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
