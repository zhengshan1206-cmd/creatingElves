/*
 * @Author: cold-x
 * @Date: 2025-08-20 18:06:02
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-28 11:37:41
 * @FilePath: /fastcreationmaster/lib/core/widget/view/banner_view.dart
 * @Description: 
 */


import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/core/service/data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../global/other/event_tracking/event_tracking.dart';
import '../../../global/routes/routes_utils.dart';

class BannerView extends StatelessWidget {
  const BannerView({
    super.key,
    required this.bannerList,
    this.showClose = true,
    this.height = 80,
    this.imgFit = BoxFit.cover,
    required this.source,
    this.close});

  final void Function()? close;
  final List<dynamic> bannerList;
  final bool? showClose;
  final double? height;
  final BoxFit? imgFit;
  final String source; ///banner位置

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 12.w),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // 横向滑动时阻止冒泡
              if (notification is ScrollStartNotification ||
                  notification is ScrollUpdateNotification) {
                if (notification.metrics.axis == Axis.horizontal) {
                  return true; // 阻止事件冒泡到父级
                }
              }
              return false;
            },
            child: CarouselSlider(
              options: CarouselOptions(
                height: height,
                viewportFraction: 1.0,
                autoPlay: bannerList.length > 1,
                autoPlayInterval: const Duration(seconds: 3),
                enableInfiniteScroll: bannerList.length > 1,
                scrollPhysics: const ClampingScrollPhysics(), // 推荐加上
              ),
              items: bannerList.map(
                (banner) {
                  return Builder(
                    builder: (BuildContext context) {
                      return GestureDetector(
                        onTap: () {
                          EventTracking.reportDataPoint(
                              pageTag: 'banner_click',
                              operateType: 'click',
                              funcDetailImg: banner.imgUrl ?? '',
                              funcDetailTag: banner.id.toString(),
                              extra: {'position': source});
                          userController.checkPreLogin(
                              source: 'banner',
                              actionCallback: () {
                                DataService.onEvent('banner_click', {'source': source});
                                NavigateUtils.navigateTo(banner);
                              });
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            banner.imgUrl,
                            width: double.infinity,
                            height: height,
                            fit: imgFit,
                          ),
                        ),
                      );
                    },
                  );
                },
              ).toList(),
            ),
          ),
        ),
        if (showClose!)
          Positioned(
            top: 4.w,
            right: 4.w,
            child: GestureDetector(
              onTap: () {
                EventTracking.reportDataPoint(
                              pageTag: 'banner_close',
                              operateType: 'click',
                              funcDetailImg: '',
                              funcDetailTag: '',
                              extra: {'position': source});
                close?.call();
              },
              child: Image.asset("assets/home/main/dialog_close.png",
                  width: 20.w, height: 20.w, fit: BoxFit.contain),
            ),
          )
      ],
    );
  }
}