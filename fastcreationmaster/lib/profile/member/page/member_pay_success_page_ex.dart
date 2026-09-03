import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/util/by_screen_utils.dart';
import 'package:fast_creation_master/core/widget/page/base_page.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:fast_creation_master/profile/member/controller/member_pay_success_controller.dart';
import 'package:fast_creation_master/profile/member/widget/member_contdown.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class MemberPaySuccessPageEx extends BasePage {
  MemberPaySuccessPageEx({super.key});

  @override
  final MemberPaySuccessController controller =
  Get.find<MemberPaySuccessController>();

  @override
  String get title => '支付成功';

  @override
  bool get hasAppBar => false;

  ///关闭按钮
  Widget _buildCloseButton() {
    return Positioned(
      top: ByScreenUtils.topSafeHeight,
      child: GestureDetector(
        onTap: () {
          controller.closePage();
          // controller.gotoDialog();
        },
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Image.asset(
            'assets/home/commercialize/commercialize_6.png',
            width: 32,
            height: 32,
          ),
        ),
      ),
    );
  }

  ///描述文案
  Widget _buildDescription() {
    return GetBuilder<MemberPaySuccessController>(
      builder: (controller) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          width: double.infinity,
          height: 152.w,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image:
              AssetImage('assets/home/commercialize/commercialize_12.png'),
              fit: BoxFit.contain,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 19.sp,
                    color: Colors.white,
                  ),
                  children: [
                    const TextSpan(
                        text: "只需要",
                        style: TextStyle(fontWeight: FontWeight.w400)),
                    TextSpan(
                      text: "¥${controller.integralPackage?.money ?? '0.00'}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                        text: "即可",
                        style: TextStyle(fontWeight: FontWeight.w400)),
                  ],
                ),
              ),
              SizedBox(height: 10.w,),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 22.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    const TextSpan(
                        text: "额外再",
                        style: TextStyle(
                          color: Color(0xFFFE5024),
                        )),
                    TextSpan(
                        text: controller.integralPackage?.title ?? '获得更多字数',
                        style: const TextStyle(
                          color: Color(0xFFFFEFC0),
                        )),
                  ],
                ),
              ),
              SizedBox(height: 16.w),
              ByWidgetsUtil.commonText(
                text: "(真半价 无套路)",
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                textColor: Colors.white,
              ),
            ],
          ),
        );
      },
    );
  }

  ///倒计时
  Widget _buildCountdown() {
    return GetBuilder<MemberPaySuccessController>(
      builder: (controller) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 20.w, top: 14.w),
                child: ByWidgetsUtil.commonText(
                    text: controller.integralPackage?.desc ?? '限时优惠',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    textColor: const Color(0xFF9F7762)),
              ),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFEEC0), // #3FFFFF
                    Color(0xFFC99758), // #7DF5F9
                  ],
                  stops: [0.38, 1.0],
                ).createShader(bounds),
                child: ByWidgetsUtil.commonText(
                  text: "新创作者专属优惠倒计时",
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  textColor: Colors.white, // 使用白色作为基础颜色，渐变会覆盖
                ),
              ),
              SizedBox(height: 9.w),
              MemberCountdown(
                fontSize: 24.sp,
                textColor: ByColorUtil.colorF1,
                bgColor: Color(0xFF161513),
                borderColor: Color(0xFFBBA591),
                borderWidth: 0.5.w,
                separatorColor: Color(0xFFBBA591),
                timeItemWidth: 42.w,
                borderRadius: 9.w,
                showMilliseconds: true,
              ),
            ],
          ),
        );
      },
    );
  }

  ///底部按钮
  Widget _buildBottomButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GetBuilder<MemberPaySuccessController>(
        builder: (controller) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                child: GestureDetector(
                  onTap: () {
                    // 点击按钮发起支付
                    controller.createWordPackageOrder();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50.w,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            'assets/home/commercialize/commercialize_13.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                    child: Center(
                      child: ByWidgetsUtil.commonText(
                        text: controller.integralPackage?.buttonTitle ?? '立即支付',
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600,
                        textColor: const Color(0xFF010101),
                      ),
                    ),
                  ),
                ),
              ),
              _buildAgreement(),
              SizedBox(height: 16.w,),
            ],
          );
        },
      ),
    );
  }

  /// 协议
  Widget _buildAgreement() {
    return Obx(() {
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
                      ? "assets/profile/member/member_2.png"
                      : "assets/profile/member/member_1.png",
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
                              text: ' 我已阅读并同意',
                              style: TextStyle(
                                fontSize: 12,
                                color: ByColorUtil.colorF2,
                              ),
                            ),
                            TextSpan(
                              text: "《会员服务协议与付费须知》",
                              style: const TextStyle(
                                color: ByColorUtil.colorF1,
                                fontSize: 12,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  if (controller.payData.wordsPackIllustrate ==
                                      null ||
                                      controller.payData
                                          .wordsPackIllustrate!.isEmpty) {
                                    return;
                                  }
                                  ByNavRouterUtils.jumpWebViewPage(
                                      Get.context!,
                                      "会员服务协议与付费须知",
                                      controller.payData.wordsPackIllustrate ?? "");
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

  @override
  Widget buildBody(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        // if (didPop) {
        //   controller.closePage();
        // }
      },
      child: Stack(
        children: [
          /// 主要内容区域
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    'assets/home/commercialize/commercialize_11.png',
                    height: 283.w,
                    width: 1.sw,
                    fit: BoxFit.fill,
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 9.w),
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFEEC0), // #3FFFFF
                          Color(0xFFC99758), // #7DF5F9
                        ],
                        stops: [0.38, 1.0],
                      ).createShader(bounds),
                      child: ByWidgetsUtil.commonText(
                        text: "新创作者字数加油包",
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w500,
                        textColor: Colors.white, // 使用白色作为基础颜色，渐变会覆盖
                      ),
                    ),
                  ),
                  _buildDescription(),
                  _buildCountdown(),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
          _buildCloseButton(),
         
        ],
      ),
    );
  }
}


class MemberAgreeDialogEx extends StatelessWidget {
  const MemberAgreeDialogEx({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MemberPaySuccessController>();

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
                  onTap: () => Get.back(),
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

                  TextSpan(
                    text: "《会员服务协议与付费须知》",
                    style: const TextStyle(
                      color: ByColorUtil.colorF5,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        if (controller.payData.wordsPackIllustrate ==
                            null ||
                            controller.payData
                                .wordsPackIllustrate!.isEmpty) {
                          return;
                        }
                        ByNavRouterUtils.jumpWebViewPage(
                            Get.context!,
                            "会员服务协议与付费须知",
                            controller.payData.wordsPackIllustrate ?? "");
                      },
                  ),

                  // if (controller.tabCurrentIndex.value == 1)
                  //   TextSpan(
                  //     text: "《字数包说明》",
                  //     style: const TextStyle(
                  //       color: ByColorUtil.colorF5,
                  //       fontSize: 15,
                  //       fontWeight: FontWeight.w500,
                  //     ),
                  //     recognizer: TapGestureRecognizer()
                  //       ..onTap = () {
                  //         if (controller.payData.wordsPackIllustrate == null ||
                  //             controller.payData.wordsPackIllustrate!.isEmpty) {
                  //           return;
                  //         }
                  //         ByNavRouterUtils.jumpWebViewPage(Get.context!, "",
                  //             controller.payData.wordsPackIllustrate ?? "");
                  //       },
                  //   ),
                  // if (controller.tabCurrentIndex.value == 0 &&
                  //     controller
                  //         .newVipList[
                  //     controller.selectedPackageIndex.value]
                  //         .isSubscribe ==
                  //         1)
                  //   TextSpan(
                  //     text: "《自动续费服务协议》",
                  //     style: const TextStyle(
                  //       color: ByColorUtil.colorF5,
                  //       fontSize: 15,
                  //       fontWeight: FontWeight.w500,
                  //     ),
                  //     recognizer: TapGestureRecognizer()
                  //       ..onTap = () {
                  //         if (controller.payData.vipPageBean!.user.subScribeProtocolUrl
                  //             .isEmpty) return;
                  //         ByNavRouterUtils.jumpWebViewPage(
                  //             Get.context!,
                  //             "",
                  //             controller
                  //                 .payData.vipPageBean?.user.subScribeProtocolUrl ??
                  //                 "");
                  //       },
                  //   ),
                ],
              ),
            ),
            const Spacer(),
            GetBuilder<MemberPaySuccessController>(
              builder: (controller) {
                return GestureDetector(
                  onTap: () {
                    controller.agreementCheckedChanged(true);
                    Get.back();
                    controller.createWordPackageOrder();
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