import 'dart:ui';

import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:fast_creation_master/profile/member/controller/member_center_controller.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../global/other/event_tracking/event_tracking.dart';

class MemberAgreeDialog extends StatelessWidget {
  const MemberAgreeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MemberCenterController>();

    return Center(
      child: Container(
        width: 327,
        height: 240,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: ByColorUtil.colorBg2,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '确认开通',
                  style: TextStyle(
                    fontSize: 20,
                    color: ByColorUtil.colorF1,
                    decoration: TextDecoration.none,
                  ),
                ),
                GestureDetector(
                  onTap: () {

                    EventTracking.reportDataPoint(
                        pageTag: 'member_page_renew_protocol_close_btn',
                        operateType: 'click',
                        funcDetailTag: controller.landingPage,
                        funcDetailImg: '',
                        extra: {
                          'pay_page_id': controller.pagePageID,
                          'vip_id': controller.getPackageID()
                        });
                    Get.back();
                  },
                  child: Image.asset(
                    'assets/profile/member/member_close_icon.png',
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: '请阅读并同意',
                    style: TextStyle(
                      fontSize: 15,
                      color: ByColorUtil.colorF1,
                    ),
                  ),
                  if (controller.tabCurrentIndex.value == 0)
                    TextSpan(
                      text: "《会员服务协议》",
                      style: const TextStyle(
                        color: ByColorUtil.colorF5,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          if (controller
                                  .payData.vipPageBean?.user.protocolUrl.isEmpty ??
                              true) return;
                          ByNavRouterUtils.jumpWebViewPage(Get.context!, "",
                              controller.payData.vipPageBean?.user.protocolUrl ?? "");
                        },
                    ),
                  if (controller.tabCurrentIndex.value == 1)
                    TextSpan(
                      text: "《字数包说明》",
                      style: const TextStyle(
                        color: ByColorUtil.colorF5,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          if (controller.payData.wordsPackIllustrate == null ||
                              controller.payData.wordsPackIllustrate!.isEmpty) {
                            return;
                          }
                          ByNavRouterUtils.jumpWebViewPage(Get.context!, "",
                              controller.payData.wordsPackIllustrate ?? "");
                        },
                    ),
                  if (controller.tabCurrentIndex.value == 0 &&
                      controller
                              .newVipList[
                                  controller.selectedPackageIndex.value]
                              .isSubscribe ==
                          1)
                    TextSpan(
                      text: "《自动续费服务协议》",
                      style: const TextStyle(
                        color: ByColorUtil.colorF5,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          if (controller.payData.vipPageBean!.user.subScribeProtocolUrl
                              .isEmpty) return;
                          ByNavRouterUtils.jumpWebViewPage(
                              Get.context!,
                              "",
                              controller
                                      .payData.vipPageBean?.user.subScribeProtocolUrl ??
                                  "");
                        },
                    ),
                ],
              ),
            ),
            const Spacer(),
            GetBuilder<MemberCenterController>(
              builder: (controller) {
                return GestureDetector(
                  onTap: () {
                    EventTracking.reportDataPoint(
                        pageTag: 'member_page_renew_protocol_open_btn',
                        operateType: 'click',
                        funcDetailTag: controller.landingPage,
                        funcDetailImg: '',
                        extra: {
                          'pay_page_id': controller.pagePageID,
                          'vip_id': controller.getPackageID()
                        });
                    controller.agreementCheckedChanged(true);
                    Get.back();
                    controller.packageBuy();
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: ByColorUtil.linearGradientMultiple(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF82D7FF),
                            const Color(0xFFBFE0FF),
                            const Color(0xFFDCC8FF),
                          ],
                          stops: [
                            0.1,
                            0.35,
                            0.92
                          ]),
                    ),
                    child: const Center(
                      child: Text(
                        '同意并继续',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: ByColorUtil.colorF7,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
