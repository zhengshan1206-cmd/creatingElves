import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/profile/member/widget/scale_transition_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class NewUserDialog extends StatelessWidget {
  NewUserDialog({super.key});

  final userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Get.back();
            userController.checkPreLogin(source: 'new_user_dialog', actionCallback: () {
              if (userController.userInfoBean.value?.isVip == 0) {
                userController.jumpToPayPage(source: 'new_user_dialog');
              }
            });
          },
          child: Container(
            width: 250.w,
            height: 337.h,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/home/main/new_user_dialog_bg.png"),
                fit: BoxFit.contain,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ScaleTransitionWidget(
                  child: Container(
                    width: 160.w,
                    height: 50.h,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            "assets/home/main/new_user_btn_icon.png"),
                        fit: BoxFit.contain,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "登录领取",
                      style: TextStyle(
                        color: const Color(0xFFFFFFFF),
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                GestureDetector(
                  onTap: () {},
                  child: Center(
                    child: Text(
                      "新用户专属福利",
                      style: TextStyle(
                        color: const Color(0xFF454B3A),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        ),
        SizedBox(height: 28.h),
        GestureDetector(
          onTap: () {
            Get.back();
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
