/*
 * @Author: cold-x
 * @Date: 2025-05-28 14:52:08
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-29 16:52:34
 * @FilePath: /fastcreationmaster/lib/home/main_page/page/home.dart
 * @Description: 
 */

import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:fast_creation_master/core/controller/base_record_controller.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/core/widget/page/base_page.dart';
import 'package:fast_creation_master/core/widget/view/banner_view.dart';
import 'package:fast_creation_master/global/const/asset_const.dart';
import 'package:fast_creation_master/global/routes/app_pages.dart';
import 'package:fast_creation_master/home/main_page/controller/home_controller.dart';
import 'package:fast_creation_master/home/main_page/view/novel_list_cell.dart';
import 'package:fast_creation_master/home/main_page/view/novel_progress_view.dart';
import 'package:fast_creation_master/profile/member/widget/not_pay_order_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../global/other/event_tracking/event_tracking.dart';
import '../../../global/ui/colors.dart';
import '../../../profile/member/dialog/intercept.dart';
import '../../../core/util/by_screen_utils.dart';
import '../../../profile/member/widget/member_contdown.dart';

// ignore: must_be_immutable
class HomePage extends BasePage {
  HomePage({super.key});

  @override
  HomeController get controller => Get.put(HomeController());

  @override
  bool get hasAppBar => false;

  @override
  String? get routeName => '/home';

  final _userInfo = Get.find<UserController>().userInfoBean;
  final userController = Get.find<UserController>();

  @override
  Widget buildBody(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true, // 移除顶部安全区域
      child: Stack(
        children: [
          Positioned.fill(
              child: Column(
            children: [
              Image.asset("assets/home/main/icon_home_bg.png",
                  fit: BoxFit.contain),
            ],
          )),
          Positioned.fill(
            child: Column(
              children: [
                _buildNavView(),
                Expanded(
                  child: EasyRefresh(
                    controller: controller.refreshController,
                    onLoad: () {
                      controller.fetchNovelList();
                    },
                    child: SingleChildScrollView(
                      child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 16.w),
                          child: Column(
                            children: [
                              _buildTopWidget(),
                              SizedBox(
                                height: 12.h,
                              ),
                              _buildToolView(),
                              Obx(() => controller.bannerList.isEmpty ||
                                      !controller.showBanner.value
                                  ? SizedBox(
                                      height: 24.h,
                                    )
                                  : SizedBox(
                                      height: 12.h,
                                    )),
                              _buildBannerView(),
                              _buildPromoteView(),
                              SizedBox(
                                height: 24.h,
                              ),
                              _buildCreationCases(),
                            ],
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),

          ///1.小说进度气泡（不展开控制下方气泡展开和隐藏）气泡一
          Obx(() => (controller.novelProgressList.isNotEmpty &&
                  !controller.showOrderNotPay.value)
              ? Positioned(
                  bottom: 160.w,
                  right: 12.w,
                  child: AnimatedOpacity(
                    opacity: controller.showBubbleOne.value ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    child: NovelProgressView(
                      progress: controller.progress.value,
                      tasksCount: controller.novelProgressList.length,
                      check: () {
                        // 点击气泡一，显示气泡二并隐藏底部运营条和气泡一
                        controller.showExpandedBubble();
                      },
                      title: controller.progressTitle.value,
                    ),
                  ),
                )
              : Container()),

          ///2.小说进度气泡（展开和隐藏）气泡二
          Obx(
            () => (controller.novelProgressList.isNotEmpty &&
                    !controller.showOrderNotPay.value)
                ? Positioned(
                    bottom: 0.w,
                    right: 12.w,
                    child: AnimatedOpacity(
                      opacity: controller.showBubbleTwo.value ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 400),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        transform: Matrix4.translationValues(
                          controller.showBubbleTwo.value ? 0 : 200.w,
                          0,
                          0,
                        ),
                        child: NovelProgressView(
                          progress: controller.progress.value,
                          tasksCount: controller.novelProgressList.length,
                          check: () {
                            userController.checkPreLogin(
                                source: 'home',
                                actionCallback: () {
                                  Get.toNamed(Routes.novelHome, arguments: {
                                    'id': controller.currentID.value
                                  })!
                                      .then((_) {
                                    controller.viewDidAppear();
                                  });
                                });
                          },
                          onClose: () {
                            // 关闭气泡二，显示底部运营条和气泡一
                            controller.showBottomOperation();
                          },
                          title: controller.progressTitle.value,
                        ),
                      ),
                    ),
                  )
                : Container(),
          ),

          Obx(() {
            final bool showSecond = controller.showSecondDialog();
            final bool halfPriceWordCount =
                controller.halfPriceWordCountPackage.value;
            bool showOrderNotPay = controller.showOrderNotPay.value;
            if (showOrderNotPay) {
              return SizedBox();
            }
            return (showSecond &&
                        controller.showCancelPaySecondTime.value == 1) ||
                    (controller.userController.userInfoBean.value != null &&
                        controller.userController.userInfoBean.value!.isVip ==
                            0 &&
                        !showSecond)
                ? Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: controller.novelProgressList.isNotEmpty
                        ? _writeCompleteNovelBanner(showSecond: showSecond)
                        : AnimatedOpacity(
                            opacity: controller.showBottomOperationView.value
                                ? 1.0
                                : 0.0,
                            duration: const Duration(milliseconds: 400),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutCubic,
                              height: controller.showBottomOperationView.value
                                  ? 82.h
                                  : 0,
                              transform: Matrix4.translationValues(
                                controller.showBottomOperationView.value
                                    ? 0
                                    : Get.width,
                                0,
                                0,
                              ),

                              ///付费引导条
                              child: PayDiscountPopView(
                                bannerBean: controller.bottomBanner,
                                type: showSecond ? 1 : 0,
                                action: () {
                                  userController.checkPreLogin(
                                      source: 'home',
                                      actionCallback: () {
                                        userController.jumpToPayPage(
                                            showSKUDialog: showSecond,
                                            source: 'home_bottom_operation');
                                      });
                                },
                                timeOut: () {
                                  if (showSecond) {
                                    controller.showCancelPaySecondTime.value =
                                        2;
                                  } else {
                                    controller.closeBottomOperation();
                                  }
                                },
                                cancel: () {
                                  if (showSecond) {
                                    controller.showCancelPaySecondTime.value =
                                        2;
                                  } else {
                                    controller.closeBottomOperation();
                                  }
                                },
                              ),
                            ),
                          ),
                  )
                : Container();
          }),

          ///半价弹窗
          Obx(() {
            bool showHalfPrice = controller.halfPriceWordCountPackage.value;
            bool showOrderNotPay = controller.showOrderNotPay.value;
            if (showOrderNotPay) {
              return SizedBox();
            }
            return Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _showHalfPrice(),
            );
          }),

          ///15分钟未支付订单
          Obx((){
              bool showOrderNotPay = controller.showOrderNotPay.value;
              return Positioned(child: _showOrderNotPay(),
                  left: 0,
                  right: 0,
                  bottom: 0,
            );
          }),
        ],
      ),
    );
  }

  ///banner位
  Widget _buildBannerView() {
    return Obx(
      () => controller.bannerList.isEmpty || !controller.showBanner.value
          ? const SizedBox.shrink()
          : BannerView(
              source: 'home',
              bannerList: controller.bannerList,
              close: () {
                controller.closeBanner();
              },
            ),
    );
  }

  ///顶部导航栏视图
  Widget _buildNavView() {
    return Container(
      height: ByScreenUtils.topSafeHeight + 44.w,
      padding: EdgeInsets.only(
          left: 12.w, right: 12.w, top: ByScreenUtils.topSafeHeight),
      child: Row(
        children: [
          Image.asset(
            "assets/home/main/icon_home_top_ai_square.png",
            width: 140.w,
            height: 30.w,
            fit: BoxFit.fitWidth,
          ),
          const Spacer(),

          ///todo 这里需要放置赚钱icon
          // Obx(() {
          //   return _userInfo.value?.isVip == 0
          //       ? SizedBox(
          //           width: 96.w,
          //           height: 32.w,
          //           child: GestureDetector(
          //             ///开通Vip
          //             onTap: () {
          //               // Get.toNamed(Routes.memberCenter);
          //               userController.checkPreLogin(
          //                 source: 'home',
          //                 actionCallback: () {
          //                 userController.jumpToPayPage(
          //                   back: () {
          //                     controller.viewDidAppear();
          //                   },
          //                 );
          //               });
          //             },
          //             child: Stack(
          //               children: [
          //                 Image.asset(
          //                   "assets/home/main/btn_home_top_vip_bg.png",
          //                   width: 96.w,
          //                   height: 32.w,
          //                 ),
          //                 Center(
          //                   child: Row(
          //                     children: [
          //                       const SizedBox(
          //                         width: 12,
          //                       ),
          //                       Image.asset(
          //                         "assets/home/main/icon_home_top_vip.png",
          //                         width: 20.w,
          //                         height: 20.w,
          //                       ),
          //                       const SizedBox(
          //                         width: 4,
          //                       ),
          //                       ByWidgetsUtil.commonText(
          //                         text: '开通会员',
          //                         fontFamily: 'AlimamaShuHeiTi',
          //                         fontSize: 12.sp,
          //                         textColor: const Color(0xFF191B1D),
          //                       )
          //                     ],
          //                   ),
          //                 )
          //               ],
          //             ),
          //           ),
          //         )
          //       : const SizedBox();
          // }),
        ],
      ),
    );
  }

  ///banner位按钮
  Widget _buildTopWidget() {
    return SizedBox(
      width: double.infinity,
      height: 146.w,
      child: Stack(
        children: [
          ///左上角长文小说
          GestureDetector(
            onTap: () {
              EventTracking.reportDataPoint(
                        pageTag: 'home_top_func',
                        operateType: 'click',
                        funcDetailImg: '',
                        funcDetailTag: '',
                        extra: {'source': 1});
              Get.toNamed(Routes.novelCreate)!.then((_) {
                controller.viewDidAppear();
              });
            },
            child: SizedBox(
              width: 169.w,
              height: 146.w,
              child: Stack(
                children: [
                  Image.asset(
                    "assets/home/main/icon_home_longnovel_bg${AssetConst.springFestival()}.png",
                    width: 169.w,
                    height: 146.w,
                  ),
                  Container(
                      padding: EdgeInsets.only(top: 12.w, left: 12.w),
                      child: ByWidgetsUtil.commonText(
                          text: '长文小说',
                          fontFamily: 'AlimamaShuHeiTi',
                          fontSize: 18.sp)),
                  Container(
                      padding: EdgeInsets.only(top: 41.w, left: 12.w),
                      child: ByWidgetsUtil.commonText(
                          text: '日更10万字', fontSize: 12.sp)),
                  Padding(
                    padding: EdgeInsets.only(top: 102.w, left: 12.w),
                    child: Container(
                        width: 88.w,
                        height: 28.w,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.w)),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 10.w,
                            ),
                            ByWidgetsUtil.commonText(
                                text: '开始创作',
                                textColor: AssetConst.springFestival().isEmpty ? const Color(0xFF7BB109) : ByColorUtil.colorG5,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600),
                            SizedBox(
                              width: 4.w,
                            ),
                            Image.asset(
                              "assets/home/main/icon_home_banner_detail_green${AssetConst.springFestival()}.png",
                              width: 8.w,
                              height: 8.w,
                            ),
                          ],
                        )),
                  ),
                ],
              ),
            ),
          ),

          //右上角短篇创作
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: () {
                EventTracking.reportDataPoint(
                        pageTag: 'home_top_func',
                        operateType: 'click',
                        funcDetailImg: '',
                        funcDetailTag: '',
                        extra: {'source': 2});
                Get.toNamed(Routes.novelCreate,
                        arguments: {'novel_type': CreationType.shortNovel})!
                    .then((_) {
                  controller.viewDidAppear();
                });
              },
              child: SizedBox(
                  width: 181.w,
                  height: 68.w,
                  child: Stack(
                    children: [
                      Image.asset(
                        "assets/home/main/icon_home_shortnovel_bg${AssetConst.springFestival()}.png",
                        width: 181.w,
                        height: 68.w,
                      ),
                      Container(
                          padding: EdgeInsets.only(top: 11.w, left: 21.w),
                          child: Row(
                            children: [
                              ByWidgetsUtil.commonText(
                                  text: '短篇创作',
                                  fontFamily: 'AlimamaShuHeiTi',
                                  fontSize: 18.sp),
                              SizedBox(
                                width: 4.w,
                              ),
                              Container(
                                width: 16.w,
                                height: 16.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0.w),
                                ),
                                child: Center(
                                    child: SizedBox(
                                  width: 6.w,
                                  height: 6.w,
                                  // color: Colors.pink,
                                  child: Image.asset(
                                      "assets/home/main/icon_home_banner_detail_blue${AssetConst.springFestival()}.png",
                                      fit: BoxFit.contain),
                                )),
                              ),
                            ],
                          )),
                      SizedBox(
                        height: 4.w,
                      ),
                      Container(
                          padding: EdgeInsets.only(top: 40.w, left: 21.w),
                          child: ByWidgetsUtil.commonText(
                              text: '知乎/豆瓣/小红书', fontSize: 12.sp)),
                    ],
                  )),
            ),
          ),

          ///右下角短故事
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                EventTracking.reportDataPoint(
                        pageTag: 'home_top_func',
                        operateType: 'click',
                        funcDetailImg: '',
                        funcDetailTag: '',
                        extra: {'source': 3});
                Get.toNamed(Routes.novelCreate,
                        arguments: {'novel_type': CreationType.shortStory})!
                    .then((_) {
                  controller.viewDidAppear();
                });
              },
              child: SizedBox(
                width: 191.w,
                height: 68.w,
                child: Stack(
                  children: [
                    Image.asset(
                      "assets/home/main/icon_home_folkstory_bg${AssetConst.springFestival()}.png",
                      width: 191.w,
                      height: 68.w,
                    ),
                    Container(
                        padding: EdgeInsets.only(top: 11.w, left: 31.w),
                        child: Row(
                          children: [
                            ByWidgetsUtil.commonText(
                                text: '短故事',
                                fontFamily: 'AlimamaShuHeiTi',
                                fontSize: 18.sp),
                            SizedBox(
                              width: 4.w,
                            ),
                            SizedBox(
                              width: 16.w,
                              height: 16.w,
                              child: Image.asset(
                                  "assets/home/main/icon_home_banner_detail_lightblue${AssetConst.springFestival()}.png",
                                  fit: BoxFit.contain),
                            ),
                          ],
                        )),
                    SizedBox(
                      height: 4.w,
                    ),
                    Container(
                        padding: EdgeInsets.only(top: 40.w, left: 31.w),
                        child: ByWidgetsUtil.commonText(
                            text: '番茄/七猫/知乎', fontSize: 12.sp)),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  ///工具视图
  Widget _buildToolView() {
    return SizedBox(
      height: 60.w,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.toolBoxTitles.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                userController.checkPreLogin(
                    source: 'home_toolbox_$index',
                    actionCallback: () {
                      if (_userInfo.value?.isVip == 0) {
                        userController.jumpToPayPage(
                            source: 'home_toolbox_$index');
                        return;
                      }

                      ///工具模块跳转
                      controller.jumpToToolModule(index);
                    });
              },
              child: Padding(
                padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 4.w, right: index == 2 ? 0 : 4.w),
                child: SizedBox(
                  width: 112.w,
                  height: 60.w,
                  child: Stack(
                    children: [
                      Image.asset(
                        "assets/home/main/${controller.toolBoxBgNames[index]}",
                        width: 112.w,
                        height: 60.w,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 44.w, top: 14.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ByWidgetsUtil.commonText(
                                text: controller.toolBoxTitles[index],
                                textColor: Colors.white,
                                fontFamily: 'AlimamaShuHeiTi',
                                fontSize: 14.sp),
                            SizedBox(
                              height: 2.w,
                            ),
                            ByWidgetsUtil.commonText(
                                textColor: Colors.white.withOpacity(0.5),
                                text: controller.toolBoxBriefs[index],
                                fontWeight: FontWeight.w400,
                                fontSize: 10.sp)
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
            // );
          }),
    );
  }

  ///推广视图
  Widget _buildPromoteView() {
    return Column(
      children: [
        Row(
          children: [
            ByWidgetsUtil.commonText(
                text: "社媒推广",
                fontSize: 18.sp,
                textColor: const Color(0xFFEBF8FF),
                fontWeight: FontWeight.w600),
            Image.asset(
              "assets/home/main/icon_home_title_decoration.png",
              width: 11.5.w,
              height: 19.w,
            ),
          ],
        ),
        SizedBox(
          height: 13.h,
        ),
        SizedBox(
          height: 44.w,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    ///跳转社媒推广助手
                    controller.jumpToPromotionModule(index);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: index == 0 ? 0 : 4.w,
                        right: index == 2 ? 0 : 4.w),
                    child: SizedBox(
                      width: index == 1 ? 128.w : 116.w,
                      height: 60.w,
                      child: Stack(
                        children: [
                          Image.asset(
                            "assets/home/main/${controller.promotionBgNames[index]}",
                            width: index == 1 ? 128.w : 116.w,
                            height: 60.w,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 12.w, top: 13.5.w),
                            child: ByWidgetsUtil.commonText(
                                text: controller.promotionTitles[index],
                                textColor: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 12.sp),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),
        )
      ],
    );
  }

  ///创作广场
  Widget _buildCreationCases() {
    return Obx(() => Column(
          children: [
            Row(
              children: [
                ByWidgetsUtil.commonText(
                    text: "创作广场",
                    fontSize: 18.sp,
                    textColor: const Color(0xFFEBF8FF),
                    fontWeight: FontWeight.w600),
                Image.asset(
                  "assets/home/main/icon_home_title_decoration.png",
                  width: 11.5.w,
                  height: 19.w,
                ),
              ],
            ),
            SizedBox(
              height: 13.h,
            ),
            Skeletonizer(
                enabled: controller.itemList.isEmpty,
                child: NovelListCell(
                  itemList: controller.itemList.isEmpty
                      ? controller.skeletonizerData
                      : controller.itemList,
                  action: (item) {
                    EventTracking.reportDataPoint(
                        pageTag: 'home_book_same_btn',
                        operateType: 'click',
                        funcDetailImg: '',
                        funcDetailTag: item.id.toString(),
                        extra: {'source': 1});
                  },
                )),
          ],
        ));
  }

  ///写完小说就能赚钱
  Widget _writeCompleteNovelBanner({
    required bool showSecond,
  }) {
    String earnMoneyBgUrl = Get.find<UserController>().earnMoneyBgUrl;
    Get.log(
        "====writeCompleteNovelBanner ${controller.writeCompleteNovelBanner.value}");
    if (!controller.writeCompleteNovelBanner.value) {
      return AnimatedOpacity(
        opacity: controller.showBottomOperationView.value ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 400),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          height: controller.showBottomOperationView.value ? 82.h : 0,
          transform: Matrix4.translationValues(
            controller.showBottomOperationView.value ? 0 : Get.width,
            0,
            0,
          ),

          ///付费引导条
          child: PayDiscountPopView(
            // bannerBean: controller.bottomBanner,
            type: showSecond ? 1 : 0,
            action: () {
              userController.checkPreLogin(
                  source: 'home',
                  actionCallback: () {
                    userController.jumpToPayPage(
                        showSKUDialog: showSecond,
                        source: 'home_bottom_operation');
                  });
            },
            timeOut: () {
              if (showSecond) {
                controller.showCancelPaySecondTime.value = 2;
              } else {
                controller.closeBottomOperation();
              }
            },
            cancel: () {
              if (showSecond) {
                controller.showCancelPaySecondTime.value = 2;
              } else {
                controller.closeBottomOperation();
              }
            },
          ),
        ),
      );
    }
    return Padding(
        padding: EdgeInsets.only(left: 12.w, bottom: 9.w),
        child: GestureDetector(
          onTap: () {
            userController.checkPreLogin(
                source: 'home',
                actionCallback: () {
                  userController.jumpToPayPage(
                      showSKUDialog: showSecond,
                      source: 'home_bottom_operation');
                });
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              earnMoneyBgUrl.isEmpty
                  ? Image.asset(
                      "assets/home/main/write_complete_novel_banner.png",
                      width: 351.w,
                      height: 44.w,
                    )
                  : CachedNetworkImage(
                      imageUrl: earnMoneyBgUrl,
                      width: 351.w,
                      height: 44.w,
                    ),
              Positioned(
                  right: 0.w,
                  bottom: 24.w,
                  child: GestureDetector(
                      onTap: () {
                        controller.closeWriteCompleteNovelBanner();
                        Get.log("===点击了===");
                      },
                      child: Container(
                        width: 36.w,
                        height: 36.w,
                        alignment: Alignment.center,
                        // color: Colors.red,
                        child: Image.asset(
                          "assets/home/main/close_bottom_banner.png",
                          width: 12.w,
                          height: 12.w,
                        ),
                      )))
            ],
          ),
        ));
  }

  ///展示限时半价
  Widget _showHalfPrice() {
    if (controller.halfPriceWordCountPackage.value == false) {
      return const SizedBox();
    }
    return GestureDetector(
        onTap: () {
          Get.toNamed(Routes.memberPaySuccess,
              arguments: {'isBackHome': false});
        },
        child: Stack(
          children: [
            SizedBox(height: 82.h),
            Positioned(
              top: 0.h,
              right: 20.w,
              child: Container(
                height: 32.h,
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6.w),
                    topRight: Radius.circular(6.w),
                  ),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFF6DB9C),
                      Color(0xFFD88331),
                    ],
                  ),
                ),
                child: MemberCountdown(
                  fontSize: 14.sp,
                  textColor: ByColorUtil.colorF1,
                  bgColor: Colors.black,
                  separatorColor: ByColorUtil.colorF1,
                  timeItemWidth: 24.w,
                  borderRadius: 4.w,
                  showMilliseconds: true,
                  type: 0,
                  timeOut: () {
                    controller.closeHalfPricePackage();
                  },
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 60.h,
                padding: EdgeInsets.symmetric(horizontal: 7.w),
                child: Image.asset(
                  'assets/home/commercialize/commercialize_9.png',
                  width: double.infinity,
                  height: 60.h,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Positioned(
              top: 20.w,
              left: 12.w,
              child: GestureDetector(
                onTap: () {
                  controller.closeHalfPricePackage();
                },
                child: Image.asset(
                  "assets/home/main/dialog_close.png",
                  width: 20.w,
                  height: 20.w,
                ),
              ),
            ),
          ],
        ));
  }

  ///展示订单未支付 15分钟有效期
  Widget _showOrderNotPay() {
    if (!controller.showOrderNotPay.value) {
      return const SizedBox();
    }

    Get.log("===展示订单未支付  ${controller.notPayOrderModel!.data.params.orderId}");
    return NotPayOrderWidget(
      notPayOrderParams: controller.notPayOrderModel!.data.params,
      closeNotPayOrderEvent: () {
        controller.closeNotPayOrderWidget();
      },
    );
  }
}
