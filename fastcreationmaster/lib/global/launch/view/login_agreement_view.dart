import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/global/login/controller/login_controller.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../other/event_tracking/event_tracking.dart';

typedef LoginAgreementCallback = void Function();

class LoginAgreementView extends StatelessWidget {
  const LoginAgreementView({
    super.key,
    this.btnTitle,
    this.callback,
    this.registerMember = false,
    this.isIntegral = false, //是否积分页面
    this.color1,
    this.isLoginSend = false,
  });

  final String? btnTitle;
  final LoginAgreementCallback? callback;

  final bool registerMember;

  final bool isIntegral;

  final Color? color1;

  //是否是登录页发送弹窗
  final bool isLoginSend;

  @override
  Widget build(BuildContext context) {
    // 确保在构建时加载 VIP 数据

    return Center(
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 28.w),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              color: ByColorUtil.colorBg2,
              borderRadius: BorderRadius.circular(16.w),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 40.h),
                ByWidgetsUtil.commonRichText(
                  texts: [
                    const TextSpan(
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        text: "请仔细阅读"),
                    TextSpan(children: [
                      TextSpan(
                        text: "《用户协议》",
                        style: const TextStyle(
                          color: ByColorUtil.colorC1,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // ByNavRouterUtils.jumpWebViewPage(
                            //     context,
                            //     "",
                            //     context
                            //             .read<LaunchController>()
                            //             .launchInfo
                            //             ?.config
                            //             .protocol ??
                            //         "");
                            Get.find<LoginController>()
                                .getProtocolByTitle("用户协议");
                          },
                      ),
                      const TextSpan(
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          text: "和"),
                      TextSpan(
                        text: "《隐私政策》",
                        style: const TextStyle(
                          color: ByColorUtil.colorC1,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // ByNavRouterUtils.jumpWebViewPage(
                            //     context,
                            //     "",
                            //     context
                            //             .read<LaunchController>()
                            //             .launchInfo
                            //             ?.config
                            //             .privacy ??
                            //         "");
                            Get.find<LoginController>()
                                .getProtocolByTitle("隐私政策");
                          },
                      ),
                    ]),
                    const TextSpan(
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        text: "确认是否同意"),
                  ],
                  textColor: ByColorUtil.colorC1,
                  fontSize: 14.sp,
                ),
                SizedBox(height: 38.h),
                GestureDetector(
                  onTap: () {
                    EventTracking.reportDataPoint(
                        pageTag: 'login_page_protocol_yes_btn',
                        operateType: 'click',
                        funcDetailImg: '',
                        funcDetailTag: '2',);
                    ByNavRouterUtils.goBack(context);
                    callback?.call();
                  },
                  child: Container(
                    height: 44.h,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color1 ?? ByColorUtil.colorC1,
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                    child: ByWidgetsUtil.commonText(
                      text: btnTitle ?? "同意并登录",
                      textColor: Colors.black,
                      fontSize: 14.sp,
                      bgColor: ByColorUtil.colorC1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
          Positioned(
            right: 38.w,
            top: 10.w,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                EventTracking.reportDataPoint(
                        pageTag: 'login_page_protocol_no_btn',
                        operateType: 'click',
                        funcDetailImg: '',
                        funcDetailTag: '2',);
                Get.back();
              },
              child: Container(
                  width: 25.w,
                  height: 25.w,
                  alignment: Alignment.center,
                  child: Image.asset(
                    "assets/global/common/btn_close.png",
                    width: 25.w,
                    height: 25.w,
                  )),
            ),
          )
        ],
      ),
    );
  }
}
