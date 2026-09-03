/*
 * @Author: cold-x
 * @Date: 2025-05-28 14:55:08
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-02-24 18:27:48
 * @FilePath: /fastcreationmaster/lib/square/square.dart
 * @Description: 
 */

import 'dart:io';
import 'dart:ui';

import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/core/service/data_service.dart';
import 'package:fast_creation_master/core/util/by_screen_utils.dart';
import 'package:fast_creation_master/global/routes/app_pages.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:fast_creation_master/square/add_wechat_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fast_creation_master/square/zone/controller/square_controller.dart';
import 'package:fast_creation_master/square/widgets/strategy_list_item.dart';

import '../global/other/event_tracking/event_tracking.dart';
import '../global/routes/routes_utils.dart';
import 'beans/strategy_list_bean.dart';

class SquarePage extends StatelessWidget {
  SquarePage({super.key});

  final SquareController _controller = Get.find<SquareController>();
  final userController = Get.find<UserController>();

  // 添加路由名称支持
  String? get routeName => '/square';

  ///body
  Widget _bodyView() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxScrolled) {
        return [
          // SliverToBoxAdapter(
          //   child: SizedBox(
          //     height: ByScreenUtils.topSafeHeight,
          //   ),
          // ),
          _zoneView(),
        ];
      },
      body: _squareListView(),
    );
  }

  ///专区
  Widget _zoneView() {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => _controller.bannerList.isEmpty ||
                      !_controller.showBanner.value
                  ? const SizedBox.shrink()
                  : Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 16.w),
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: 105,
                              viewportFraction: 1.0,
                              autoPlay: _controller.bannerList.length > 1,
                              autoPlayInterval: const Duration(seconds: 3),
                              enableInfiniteScroll:
                                  _controller.bannerList.length > 1,
                            ),
                            items: _controller.bannerList.map((banner) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return GestureDetector(
                                    onTap: () {
                                      userController.checkPreLogin(
                                          source: 'square',
                                          actionCallback: () {
                                            NavigateUtils.navigateTo(banner);
                                          });
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        banner.imgUrl,
                                        width: double.infinity,
                                        height: 105,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        Positioned(
                          top: 10.w,
                          right: 10.w,
                          child: GestureDetector(
                            onTap: () {
                              _controller.closeBanner();
                            },
                            child: Image.asset(
                                "assets/home/main/dialog_close.png",
                                width: 20.w,
                                height: 20.w,
                                fit: BoxFit.contain),
                          ),
                        )
                      ],
                    ),
            ),

            ///这是以前的营销 番茄 七猫专区
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 80,
              child: Obx(
                () {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _controller.zoneListHeader.length,
                    itemBuilder: (context, index) {
                      final zone = _controller.zoneListHeader[index];
                      return Container(
                        margin: EdgeInsets.only(
                            right:
                                index == _controller.zoneListHeader.length - 1
                                    ? 0
                                    : 8),
                        width:
                            (MediaQuery.of(context).size.width - 24 - 16) / 2,
                        child: _menuView(zone.title, zone.iconUrl, zone.id,
                            zone.bgUrl, zone.key, index),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(
              height: 16.w,
            ),
            Obx((){
              return _titleView(_controller.title1.value, clickEvent: () {
                Get.log("系列课id===> ${_controller.courseId}");
                userController.checkPreLogin(
                    source: 'square',
                    actionCallback: () {
                      DataService.onEvent('square_list_click', {
                        'id': _controller.courseId,
                        'type': 'xi_lie_ke',
                      });
                      Get.toNamed(Routes.squareZone, arguments: {
                        "id": _controller.courseId,
                        "menutitle": _controller.title1.value,
                        "iconUrl": "",
                        "type": "xi_lie_ke"
                      });
                    });
              }, title1: "查看更多");
            }),

            const SizedBox(height: 12),

            Obx(() {
              return Column(
                children: [
                  ..._controller.courseZoneList.asMap().entries.map((entry) =>
                      _tutorialView(bean: entry.value, index: entry.key))
                ],
              );
            }),

            // _tutorialView(),
            // const SizedBox(height: 12),
            // _tutorialView(),
            const SizedBox(height: 12),
            _titleView('大家都在看', clickEvent: () {
              userController.checkPreLogin(
                  source: 'square',
                  actionCallback: () {
                    Get.toNamed(Routes.squareZone, arguments: {
                      "id": 0,
                      "menutitle": "大家都在看",
                      "iconUrl": "",
                      "type": "all_look"
                    });
                  });
            }, title1: "全部"),
          ],
        ),
      ),
    );
  }

  ///系列课
  Widget _tutorialView({
    required StrategyListBean bean,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        userController.checkPreLogin(
            source: 'square',
            actionCallback: () {
              DataService.onEvent('square_list_click', {
                'id': bean.id,
                'type': 'square-item',
                'index': index,
              });
              Get.toNamed(Routes.squareDetails,
                  arguments: {"id": bean.id, "type": "xi_lie_ke"});
            });
      },
      child: Container(
        height: 100.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: ByColorUtil.colorBg2,
        ),
        margin: EdgeInsets.only(bottom: 12.w),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(24),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: bean.iconUrl,
                    width: 100.w,
                    height: 100.w,
                    fit: BoxFit.fill,
                  ),
                ),
                if (bean.isFree == 2)
                  Positioned(
                      right: 0,
                      child: Image.asset(
                        "assets/square/vip_exclusive.png",
                        width: 52.w,
                        height: 18.w,
                      ))
              ],
            ),
            const SizedBox(
              width: 12,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 230.w,
                  child: ByWidgetsUtil.commonText(
                      text: bean.name,
                      fontSize: 15.sp,
                      textColor: ByColorUtil.colorF1,
                      maxLines: 1),
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    Image.asset(
                      'assets/square/icon_square_date_clock.png',
                      width: 12,
                      height: 12,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    ByWidgetsUtil.commonText(
                        text: bean.createdAt,
                        fontSize: 12.sp,
                        textColor: ByColorUtil.colorF2,
                        maxLines: 1),
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.w),
                      child: CachedNetworkImage(
                        imageUrl: bean.authorAvatar,
                        width: 20.w,
                        height: 20.w,
                      ),
                    ),
                    SizedBox(
                      width: 6.w,
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 130.w),
                      child: ByWidgetsUtil.commonText(
                          text: bean.authorName,
                          textColor: ByColorUtil.colorF2,
                          maxLines: 1),
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    InkResponse(
                      onTap: () {
                        // Get.dialog(AddWechatDialog(
                        //   wechatUrl: bean.wechat,
                        // ));
                        userController.checkPreLogin(
                            source: 'square',
                            actionCallback: () {
                              if (userController.userInfoBean.value?.isVip ==
                                  0) {
                                userController.jumpToPayPage(source: 'square');
                              } else {
                                ByNavRouterUtils.jumpWebViewPage(
                                    Get.context!, "微信客服", bean.wechat);
                              }
                            });
                      },
                      child: Container(
                        width: 68.w,
                        height: 22.h,
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0XFF98FC4A)),
                          borderRadius: BorderRadius.circular(15.w),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "添加老师",
                          style: TextStyle(
                            color: Color(0XFF98FC4A),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  ///菜单
  Widget _menuView(String title, String image, int id, String? bgUrl,
      String? key, int index) {
    return GestureDetector(
      onTap: () {
        EventTracking.reportDataPoint(
                        pageTag: 'guide_page_top_func',
                        operateType: 'click',
                        funcDetailImg: '',
                        funcDetailTag: id.toString(),
                      );
        userController.checkPreLogin(
            source: 'square',
            actionCallback: () {
              DataService.onEvent('square_list_click', {'id': id, 'type': key});
              Get.toNamed(Routes.squareZone, arguments: {
                "id": id,
                "menutitle": title,
                "iconUrl": image,
                "type": key
              });
            });
      },
      child: Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(bgUrl ?? ""),
            fit: BoxFit.cover,
          ),
        ),
        // child: Container(
        //   padding: const EdgeInsets.only(left: 16, top: 36),
        //   child: Row(children: [
        //     Text(
        //       title,
        //       style: const TextStyle(
        //         fontSize: 12,
        //         fontWeight: FontWeight.w500,
        //         color: ByColorUtil.colorF6,
        //       ),
        //     ),
        //     const SizedBox(width: 4),
        //     Image.asset(
        //       'assets/square/square_3.png',
        //       width: 8,
        //       height: 8,
        //     ),
        //   ]),
        // ),
      ),
    );
  }

  ///标题
  Widget _titleView(
    String zoneTitle, {
    required String title1,
    required VoidCallback clickEvent,
  }) {
    return InkResponse(
      onTap: () {
        clickEvent();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            zoneTitle,
            style: TextStyle(
              fontSize: 18.sp,
              color: ByColorUtil.colorF1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 2),
          Image.asset(
            'assets/profile/profile_trend_13.png',
            width: 12,
            fit: BoxFit.fitWidth,
          ),
          const Spacer(),
          InkResponse(
            onTap: () {
              clickEvent();
            },
            child: Row(
              children: [
                Text(
                  title1,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.64),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Image.asset(
                  "assets/square/go_more_icon.png",
                  width: 8.w,
                  height: 8.w,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  ///广场列表
  Widget _squareListView() {
    return EasyRefresh(
      onRefresh: () async {
        _controller.getStrategyGuideList(isRefresh: true);
      },
      onLoad: () async {
        _controller.getStrategyGuideList(isRefresh: false);
      },
      child: Obx(
        () => ListView.builder(
          padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 12.w),
          itemCount: _controller.strategyList.length,
          itemBuilder: (context, index) {
            final strategy = _controller.strategyList[index];
            return StrategyListItemEx(
              strategy: strategy,
              onTap: () {
                EventTracking.reportDataPoint(
                        pageTag: 'guide_page_click',
                        operateType: 'click',
                        funcDetailImg: '',
                        funcDetailTag: strategy.id.toString(),
                      );
                userController.checkPreLogin(
                    source: 'square',
                    actionCallback: () {
                      DataService.onEvent('square_list_click', {
                        'id': strategy.id,
                        'type': 'square-item',
                        'index': index
                      });
                      Get.toNamed(Routes.squareDetails,
                          arguments: {"id": strategy.id});
                    });
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColorUtil.colorBg1,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: Image.asset(
                'assets/square/square_rigth_bg.png',
                height: 286,
                fit: BoxFit.fitHeight,
              ),
            ),
            Column(
              children: [
                SizedBox(
                  height: ByScreenUtils.topSafeHeight + 12,
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Image.asset(
                    'assets/square/square_title.png',
                    width: double.infinity,
                    height: 30,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(
                  height: 22,
                ),
                Expanded(child: _bodyView()),
              ],
            ),

            ///赚钱
            if (Platform.isAndroid)
              Positioned(
                right: 12,
                top: 12 + ByScreenUtils.topSafeHeight,
                child: SizedBox(
                  width: 117.w,
                  height: 32.w,
                  child: GestureDetector(
                    onTap: () {
                      // Get.toNamed(Routes.memberCenter);
                      userController.checkPreLogin(
                          source: 'home',
                          actionCallback: () {
                            Get.toNamed(
                              Routes.shareSales,
                            );
                          });
                    },
                    child: Image.asset(
                      "assets/home/share_sales/invite_icon.png",
                      width: 117.w,
                      height: 32.w,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
