import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:fast_creation_master/profile/member/widget/scale_transition_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../global/other/event_tracking/event_tracking.dart';

class HomeMarketingDialog extends StatelessWidget {
  HomeMarketingDialog({super.key});

  final userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 320.w,
          height: 320.h,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image:
                  AssetImage("assets/home/main/home_marketing_dialog_bg.png"),
              fit: BoxFit.contain,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  EventTracking.reportDataPoint(
                        pageTag: 'home_pop_up_open_btn',
                        operateType: 'click',
                        funcDetailImg: '',
                        funcDetailTag: '0',);
                  userController.checkPreLogin(source: 'home_marketing_dialog', actionCallback: () {
                    Get.back();
                    userController.jumpToPayPage(source: 'home_marketing_dialog');
                  });
                },
                child: ScaleTransitionWidget(
                  child: Container(
                    width: 170.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(22.w),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "立即领取",
                      style: TextStyle(
                        color: ByColorUtil.colorC1,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Center(
                  child: Text(
                    "我放弃",
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.3),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
        SizedBox(height: 28.h),
        GestureDetector(
          onTap: () {
            Get.back();
            EventTracking.reportDataPoint(
                        pageTag: 'home_pop_up_btn',
                        operateType: 'click',
                        funcDetailImg: '',
                        funcDetailTag: '0',);
          },
          child: Center(
            child: Image.asset(
              "assets/home/main/dialog_close.png",
              width: 44.w,
              height: 44.h,
            ),
          ),
        )
      ],
    );
  }
}
