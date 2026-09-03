import 'dart:async';

import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/widget/view/by_button.dart';
import 'package:fast_creation_master/global/launch/bean/launch_info_bean.dart';
import 'package:fast_creation_master/global/launch/controller/launch_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/controller/user_controller.dart';
import '../../../core/util/by_screen_utils.dart';
import '../../../core/widget/view/progress_bar.dart';
import '../../ui/colors.dart';
import '../controller/launch_error_controller.dart';


class LaunchErrorPage extends StatefulWidget {
  const LaunchErrorPage({super.key});

  @override
  State<LaunchErrorPage> createState() => _LaunchErrorPageState();
}

class _LaunchErrorPageState extends State<LaunchErrorPage> {
  final controller = Get.put(LaunchErrorController());

  Timer? _timer;

  /// 超时时间 10s
  int timeout = 10;

  /// 已花费时间
  double timeCost = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _initTimer();
  }

  void _initTimer() {
    _timer?.cancel();

    /// 初始化一个定时器，每0.5秒，让进度增加0.1
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      controller.progress.value += 0.006;
      timeCost += 0.1;
      final faild = controller.launchFaild.value == true && timeCost >= 3.0;
      if (timeCost >= timeout || faild) {
        _timer?.cancel();

        /// 请求超时
        controller.launching.value = false;
        controller.launchFaild.value = false;
        controller.progress.value = 0.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxW = ByScreenUtils.screenWidth - 27.w * 2;
    return Scaffold(
      backgroundColor: ByColorUtil.colorBg1,
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Image.asset(
              "assets/home/main/icon_home_bg.png",
              fit: BoxFit.fitWidth,
            ),
          ),
          Positioned.fill(
              child: Column(
            children: [
              SizedBox(height: 240.h),
              Image.asset(
                "assets/global/common/icon_network_error.png",
                width: 180.w,
                fit: BoxFit.fitWidth,
              ),
              SizedBox(height: 35.h),
              ByWidgetsUtil.commonText(
                text: "网络异常，请检查网络后重试",
                fontSize: 12.sp,
                fontWeight: FontWeight.normal,
                textColor: ByColorUtil.colorF2,
              ),

              SizedBox(height: 15.h),

              ByWidgetsUtil.commonText(
                text: "如有问题,可拨打客服热线协助您解决",
                fontSize: 12.sp,
                fontWeight: FontWeight.normal,
                textColor: ByColorUtil.colorF2,
              ),

              SizedBox(height: 5.h),
              ByWidgetsUtil.commonText(
                text: "（人工客服时间 早9:00-晚23:00）",
                fontSize: 12.sp,
                fontWeight: FontWeight.normal,
                textColor: ByColorUtil.colorF2,
              ),

              SizedBox(height: 10.h),

              GestureDetector(
                onTap: () async{
                  ///todo 拨打电话
                  final Uri launchUri = Uri(
                    scheme: 'tel',
                    path: "4008698538",
                  );
                  if (await canLaunchUrl(launchUri)) {
                    await launchUrl(launchUri);
                  }
                },
                child: ByWidgetsUtil.commonText(
                  text: "400-869-8538",
                  fontSize: 26.sp,
                  fontWeight: FontWeight.normal,
                  textColor: ByColorUtil.colorF2,
                ),
              ),

              SizedBox(height: 20.h),
              Obx(() => Offstage(
                    offstage: controller.launching.value == true,
                    child: controller.reTryCount.value >= 3
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildRetryBtn(context),
                              SizedBox(width: 10.w),
                              SizedBox(
                                height: 32.h,
                                child: ByButton.gradientBtn(
                                  title: "联系在线客服",
                                  textColor: Colors.black,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12.w),
                                  fontSize: 14.sp,
                                  borderRadius: 8.sp,
                                  onClick: () {
                                    ByNavRouterUtils.jumpWebViewPage(
                                      context,
                                      "",
                                      "https://inchat.beiyinapp.com/index/kf/nouser",
                                      isRisk: false,
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              const Spacer(),
                              _buildRetryBtn(context),
                              const Spacer(),
                            ],
                          ),
                  )),
              // SizedBox(height: 18.h),
              Obx(() => Offstage(
                    offstage: controller.launching.value == false,
                    child: Container(
                      height: 32.h,
                      padding: EdgeInsets.symmetric(horizontal: 142.w),
                      child: Container(
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0.w),
                          gradient: ByColorUtil.colorG1(),
                        ),
                        child: ByWidgetsUtil.activityIndicator(
                          radius: 9.w,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  )),

              const Spacer(),
              Obx(() => Offstage(
                    offstage: controller.launching.value == false,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      alignment: Alignment.centerLeft,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Obx(() => Positioned(
                                left: (maxW - 0.w) * controller.progress.value,
                                child: Image.asset(
                                  "assets/global/launch/ai_clip_progress.gif",
                                  height: 40.h,
                                  width: 24.w,
                                  // fit: BoxFit.fitHeight,
                                ),
                              )),
                          SizedBox(
                            width: maxW - 27.w,
                            height: 40.h,
                          )
                        ],
                      ),
                    ),
                  )),
              SizedBox(height: 5.h),
              SizedBox(
                width: maxW,
                height: 5.h,
                child: Obx(() => Offstage(
                      offstage: controller.launching.value == false,
                      child: ProgressBar(
                          progress: controller.progress.value),
                    )),
              ),
              SizedBox(height: 120.h),
            ],
          ))
        ],
      ),
    );
  }

  SizedBox _buildRetryBtn(BuildContext context) {
    return SizedBox(
      height: 32.h,
      child: ByButton.gradientBtn(
        title: "立即重试",
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        fontSize: 14.sp,
        textColor: Colors.black,
        borderRadius: 8.sp,
        onClick: () {
          timeCost = 0;
          controller.launching.value = true;
          controller.progress.value = 0.0;
          controller.reTryCount.value = controller.reTryCount.value + 1;

          _initTimer();

          final launchController = Get.find<LaunchController>();
          launchController.appLaunch(
            isFirshLaunch: true,
            onSuccess: (LaunchInfoBean bean) {
              timeCost = 0;
              final userController = Get.find<UserController>();
              _timer?.cancel();
              userController.reloadUserInfo(
                successAction: (userInfo) {
                  controller.progress.value = 1.0;
                  Future.delayed(const Duration(milliseconds: 50), () {
                    controller.launching.value = false;
                    controller.progress.value = 0.0;
                    launchController.launchSuccessful();
                  });
                },
              );
            },
            onFail: () {
              controller.launchFaild.value = true;
              if (timeCost >= 3.0) {
                timeCost = 0;
                controller.launching.value = false;
                controller.launchFaild.value = false;
                controller.progress.value = 0.0;
                _timer?.cancel();
              }
            },
          );
        },
      ),
    );
  }
}
