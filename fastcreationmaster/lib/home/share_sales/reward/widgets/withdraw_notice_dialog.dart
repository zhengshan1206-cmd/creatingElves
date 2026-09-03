import 'package:fast_creation_master/home/share_sales/reward/reward_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../profile/profile_controller.dart';

///提现说明弹窗
class WithdrawNoticeDialog extends StatelessWidget {
  const WithdrawNoticeDialog({super.key});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 1.sw - 76.w,
        height: 216.w,
        child: Center(
          child: Container(
            width: 1.sw - 76.w,
            height: 216.w,
            decoration: BoxDecoration(
                color: const Color(0XFF404044),
                borderRadius: BorderRadius.circular(24.w)),
            alignment: Alignment.center,
            padding: EdgeInsets.only(
              bottom: 20.w,
              top: 30.w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "说明",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 18.w,
                ),
                Text(
                  "提现说明具体内容",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    fontSize: 12.sp,
                  ),
                ),
                const Spacer(),
                InkResponse(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    width: 1.sw - 136.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                        color: const Color(0XFF98FC4A),
                        borderRadius: BorderRadius.circular(12.w)),
                    alignment: Alignment.center,
                    child: Text(
                      "我知道了",
                      style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0XFF000000)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

///提现成功弹窗
class WithdrawSuccessNoticeDialog extends StatelessWidget {
  const WithdrawSuccessNoticeDialog({super.key});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 1.sw - 76.w,
        height: 258.w,
        child: Center(
          child: Container(
            width: 1.sw - 76.w,
            height: 258.w,
            decoration: BoxDecoration(
                color: const Color(0XFF404044),
                borderRadius: BorderRadius.circular(24.w)),
            alignment: Alignment.center,
            padding: EdgeInsets.only(
              bottom: 20.w,
              top: 30.w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/home/share_sales/pass_icon.png",
                  width: 40.w,
                  height: 40.w,
                ),
                SizedBox(
                  height: 22.w,
                ),
                Text(
                  "提现申请成功",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(
                  height: 10.w,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 35.w,
                    right: 35.w,
                  ),
                  child: Text(
                    "提现申请成功，请耐心等待，奖励将在7个工作日到账",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Spacer(),
                    InkResponse(
                      onTap: () {
                        Get.back();
                        Get.find<RewardController>().showWithdrawPageDialog();
                      },
                      child: Container(
                        width: 114.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.w)),
                        alignment: Alignment.center,
                        child: Text(
                          "奖励提现明细",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                     SizedBox(width: 12.w,),
                    InkResponse(
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          width: 114.w,
                          height: 44.w,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFF98FC4A),
                                Color(0xFFD7F97D),
                              ],
                              stops: [0.38, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(12.0.w),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "我知道了",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        )),
                    const Spacer(),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


///提现成功弹窗
class WithdrawFailureNoticeDialog extends StatelessWidget {
  final String errorMsg;
  const WithdrawFailureNoticeDialog({super.key,required this.errorMsg,});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 1.sw - 76.w,
        height: 258.w,
        child: Center(
          child: Container(
            width: 1.sw - 76.w,
            height: 258.w,
            decoration: BoxDecoration(
                color: const Color(0XFF404044),
                borderRadius: BorderRadius.circular(24.w)),
            alignment: Alignment.center,
            padding: EdgeInsets.only(
              bottom: 20.w,
              top: 30.w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/home/share_sales/no_pass_icon.png",
                  width: 40.w,
                  height: 40.w,
                ),
                SizedBox(
                  height: 22.w,
                ),
                Text(
                  "提现申请失败",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(
                  height: 10.w,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 35.w,
                    right: 35.w,
                  ),
                  child: Text(
                    errorMsg,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Spacer(),
                    InkResponse(
                      onTap: () {
                        // Get.back();
                        Get.find<ProfileController>().getProtocolByTitle("在线客服");
                      },
                      child: Container(
                        width: 114.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.w)),
                        alignment: Alignment.center,
                        child: Text(
                          "咨询客服",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w,),
                    InkResponse(
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                          width: 114.w,
                          height: 44.w,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFF98FC4A),
                                Color(0xFFD7F97D),
                              ],
                              stops: [0.38, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(12.0.w),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "我知道了",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        )),
                    const Spacer(),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
