/*
 * @Author: cold-x
 * @Date: 2025-07-25 13:51:53
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-02-24 19:05:41
 * @FilePath: /fastcreationmaster/lib/profile/member/dialog/intercept.dart
 * @Description: 
 */



import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/core/util/by_screen_utils.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:fast_creation_master/home/main_page/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/service/data_service.dart';
import '../../../global/routes/app_pages.dart';
import '../../../global/routes/routes_utils.dart';
import '../widget/member_contdown.dart';

///拦截类型
enum InterceptType {
  ///引导页灵感拦截(9.0.3)
  guideBriefIntercept,
  ///小说未完成引导继续创作拦截(9.0.3)
  novelContinue,
  ///新用户首次打开app，首页弹窗(9.0.5)
  guideNewUserWriting,
}

extension InterceptTypeExt on InterceptType {
  String get imageName {
    switch (this) {
      case InterceptType.guideBriefIntercept:
        return "icon_business_guide_novel";
      case InterceptType.novelContinue:
        return "icon_business_novel_continue";
      case InterceptType.guideNewUserWriting:
        return 'icon_business_give_words_continue';
    }
  }

  String get btnTitle {
    switch (this) {
      case InterceptType.guideBriefIntercept:
        return "AI继续帮我写";
      case InterceptType.novelContinue:
        return "我要继续写";
      case InterceptType.guideNewUserWriting:
        return '去写小说';
    }
  }
}

///付费流程拦截视图
class InterceptView extends StatelessWidget {
  const InterceptView({
    super.key,
    required this.type,
    this.close,
    this.action});
  ///类型
  final InterceptType type;
  ///继续 的回调
  final VoidCallback? action;
  final VoidCallback? close;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: const Color(0xFF000000).withOpacity(0.7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 12.w + ByScreenUtils.topSafeHeight,
            ),
            GestureDetector(
              onTap: () {
                Get.back();
                close?.call();
              },
              child: SizedBox(
                width: 40,
                height: 40,
                child: Image.asset(
                  'assets/global/common/btn_close.png',
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(
              height: 77.h,
            ),
            Stack(
              children: [
                Positioned(
                  child: Image.asset(
                    'assets/business/${type.imageName}.png',
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  bottom: 65.w,
                  left: 103.w,
                  child: GestureDetector(
                    onTap: () {
                      action?.call();
                    },
                    child: Container(
                      width: 170.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        gradient: ByColorUtil.colorG1(),
                        borderRadius: BorderRadius.circular(22.w),
                      ),
                      child: Center(
                        child: ByWidgetsUtil.commonText(
                            text: type.btnTitle,
                            fontSize: 20.sp,
                            fontFamily: 'AlimamaShuHeiTi',
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

///首页付费引导条
class PayDiscountPopView extends StatelessWidget{
  const PayDiscountPopView({
    super.key,
    required this.type,
    this.action,
    this.timeOut,
    this.cancel,

    this.bannerBean,
  });

  final int type;   ///0 新手底部引导  1 付费页二次弹窗拦截取消底部引导
  final VoidCallback? action;
  final VoidCallback? cancel;
  final VoidCallback? timeOut;

  final BannerBean? bannerBean;

  @override
  Widget build(BuildContext context) {
    Get.log('===新手底部引导=== $type');
    final HomeController homeController = Get.find<HomeController>();
    if(homeController.halfPriceWordCountPackage.value&&homeController.userInfoBean!=null){
      ///展示限时半价
      Get.log('===展示限时半价===');
      if(homeController.userInfoBean!.isVip==1){
        return GestureDetector(
          onTap: () {
            Get.toNamed(Routes.memberPaySuccess, arguments: {'isBackHome': false});
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
                      homeController.closeHalfPricePackage();
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
                    homeController.closeHalfPricePackage();
                  },
                  child: Image.asset(
                    "assets/home/main/dialog_close.png",
                    width: 20.w,
                    height: 20.w,
                  ),
                ),
              ),
            ],
          )
        );
      }
    }
    return GestureDetector(
      onTap: () {
        UserController userController = Get.find<UserController>();
        if(type==0&&bannerBean!=null){
          Get.log("===底部banner的数据=== ${bannerBean!.toJson()}");
          userController.checkPreLogin(
              source: 'banner',
              actionCallback: () {
                DataService.onEvent('banner_click', {'source': "home"});
                NavigateUtils.navigateTo(bannerBean!,fromBanner:true, );
              });
          return;
        }
        action?.call();
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
                    Color(0xFFE9FD37),
                    Color(0xFFFEBF31),
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
                type: type,
                timeOut: timeOut,
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
              // child: Image.asset(
              //   type == 0 ? "assets/home/main/home_bottom_bg.png" : 'assets/business/icon_business_cancelpay_discount.png',
              //   width: double.infinity,
              //   height: 60.h,
              //   fit: BoxFit.fill,
              // ),

              child:type==0?_showBottomBannerView(): Image.asset(
                 'assets/business/icon_business_cancelpay_discount.png',
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
                // 点击关闭按钮，关闭底部运营条
                cancel?.call();
              },
              child: Image.asset(
                "assets/home/main/dialog_close.png",
                width: 20.w,
                height: 20.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showBottomBannerView(){
    if(bannerBean!=null){
      return CachedNetworkImage(imageUrl: bannerBean!.imgUrl,
        width: double.infinity,
        height: 60.h,
        fit: BoxFit.fill,
      );
    }
    return Image.asset(
      "assets/home/main/home_bottom_bg.png",
      width: double.infinity,
      height: 60.h,
      fit: BoxFit.fill,
    );
  }

}