
import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:fast_creation_master/profile/member/controller/member_center_controller.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../global/ui/colors.dart';

class BottomProtocalView extends StatelessWidget {
  BottomProtocalView({super.key, this.style = 1});

  ///显示样式 0 白字 1 为黑字
  final int style;

  final MemberCenterController controller = Get.find<MemberCenterController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final itemCount = controller.newVipList.length;
      if (itemCount == 0) {
        return Container();
      }
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          controller
              .agreementCheckedChanged(!controller.agreementChecked.value);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  controller.agreementChecked.value
                      ? "assets/profile/member/member_2.png" :
                      style == 1 ? 'assets/global/common/btn_checkbox_normal_black.png' : "assets/profile/member/member_1.png",
                  height: 14,
                  width: 14,
                  fit: BoxFit.contain,
                ),
                Flexible(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: '已阅读并同意',
                              style: TextStyle(
                                fontSize: 12,
                                color: ByColorUtil.colorF2,
                              ),
                            ),
                            if (controller.newVipList.isNotEmpty &&
                                controller.selectedPackageIndex.value <
                                    controller.newVipList.length)
                              TextSpan(
                                text: "会员付费协议",
                                style: TextStyle(
                                  color: style == 1 ? ByColorUtil.colorF7 : ByColorUtil.colorF1,
                                  fontSize: 12.sp,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    if (controller.payData.vipPageBean?.user.protocolUrl
                                            .isEmpty ??
                                        true) return;
                                    ByNavRouterUtils.jumpWebViewPage(
                                        Get.context!,
                                        "会员服务协议与付费须知",
                                        controller.payData.vipPageBean?.user
                                                .protocolUrl ??
                                            "");
                                  },
                              ),
                            if (controller.newVipList.isNotEmpty &&
                                controller.selectedPackageIndex.value <
                                    controller.newVipList.length &&
                                controller
                                        .newVipList[controller
                                            .selectedPackageIndex.value]
                                        .isSubscribe ==
                                    1)
                              TextSpan(
                                text: "、自动续费服务协议",
                                style: TextStyle(
                                  color: style == 1 ? ByColorUtil.colorF7 : ByColorUtil.colorF1,
                                  fontSize: 12.sp,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    if (controller.payData.vipPageBean?.user
                                            .subScribeProtocolUrl.isEmpty ??
                                        true) return;
                                    ByNavRouterUtils.jumpWebViewPage(
                                        Get.context!,
                                        "自动续费服务协议",
                                        controller.payData.vipPageBean?.user
                                                .subScribeProtocolUrl ??
                                            "");
                                  },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}