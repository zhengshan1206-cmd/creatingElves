import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/core/service/data_service.dart';
import 'package:fast_creation_master/core/widget/page/base_page.dart';
import 'package:fast_creation_master/core/widget/view/muti_status_view.dart';
import 'package:fast_creation_master/global/routes/app_pages.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fast_creation_master/square/zone/controller/square_zone_controller.dart';
import 'package:fast_creation_master/square/widgets/strategy_list_item.dart';

import '../../global/routes/routes_utils.dart';

// ignore: must_be_immutable
class SquareZonePage extends BasePage {
  SquareZonePage(
      {super.key, this.id = 0, this.menutitle = "", this.iconUrl = ""}) {
    _controller = Get.put(SquareZoneController(id: id, iconUrl: iconUrl));
  }

  final int id;
  final String menutitle;
  final String iconUrl;
  late final SquareZoneController _controller;

  @override
  String get title => menutitle;

  @override
  bool get hasAppBar => false;

  @override
  Widget buildBody(BuildContext context) {
    return Stack(
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
              width: double.infinity,
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    child: Image.asset(
                      "assets/profile/profile_left-icon.png",
                      width: 16,
                      height: 16,
                    ),
                  ),
                ),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ClipRRect(
                    //   borderRadius: BorderRadius.circular(12),
                    //   child: Image.network(
                    //     _controller.iconUrl,
                    //     width: 24,
                    //     height: 24,
                    //     fit: BoxFit.cover,
                    //     errorBuilder: (context, error, stackTrace) {
                    //       return Container(
                    //         width: 24,
                    //         height: 24,
                    //         color: ByColorUtil.colorBg2,
                    //         child: const Icon(
                    //           Icons.image_not_supported_outlined,
                    //           color: Colors.grey,
                    //           size: 16,
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),
                    const SizedBox(width: 4),
                    Text(
                      menutitle,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: ByColorUtil.colorF1,
                      ),
                    )
                  ],
                ),
                centerTitle: true,
                actions: const [],
              ),
            ),
            Obx(
              () => _controller.bannerList.isEmpty ||
                      !_controller.showBanner.value
                  ? const SizedBox.shrink()
                  : Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 12.w),
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
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
                                      Get.find<UserController>().checkPreLogin(
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
                          right: 20.w,
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
            Expanded(
              child: Obx(
                () => MultiStatusView(
                  currentStatus: _controller.statusType.value,
                  action: () {
                    _controller.getStrategyGuideList(isRefresh: true);
                  },
                  child: _squareListView(),
                ),
              ),
            )
          ],
        ),
      ],
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

            Get.log("===当前的type=== ${_controller.type}");

            return StrategyListItemEx(
              strategy: strategy,
              onTap: () {
                DataService.onEvent('square_list_click', {
                  'id': strategy.id,
                  'type': 'square-item',
                  'index': index,
                });
                // TODO: 处理点击事件
                Get.toNamed(Routes.squareDetails,
                    arguments: {"id": strategy.id, "wechat": strategy.wechat});
              },
              type: _controller.type,
            );
          },
        ),
      ),
    );
  }
}
