/*
 * @Author: cold-x
 * @Date: 2025-05-30 14:29:21
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-02-25 19:29:59
 * @FilePath: /fastcreationmaster/lib/global/login/page/login_page.dart
 * @Description: 登录页面
 */

import 'dart:io';

import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/widget/page/base_page.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/global/launch/controller/launch_controller.dart';
import 'package:fast_creation_master/global/login/controller/login_controller.dart';
import 'package:fast_creation_master/global/login/binbing/login_binding.dart';
import 'package:fast_creation_master/global/routes/app_pages.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../launch/view/login_agreement_view.dart';
import '../../other/event_tracking/event_tracking.dart';
import '../view/countdown_button.dart';
import '../view/login_textfield.dart';

///登录页面
// ignore: must_be_immutable
class LoginPage extends BasePage {
  LoginPage({
    super.key,
    this.type,
  });
  LoginType? type;

  @override
  bool get hasAppBar => false;

  @override
  LoginController get controller {
    // 确保控制器正确初始化
    if (!Get.isRegistered<LoginController>()) {
      LoginBinding().dependencies();
    }
    return Get.find<LoginController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ByColorUtil.colorBg1,
      body: buildBody(context),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          child: Padding(
          padding: EdgeInsets.all(24.w),
          child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              height: type == LoginType.wx ? 204.h : 102.h,
            ),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.w),
                  child: Image.asset(
                    'assets/icon.png',
                    width: 80.w,
                    height: 80.w,
                  ),
                ),
                SizedBox(
                  width: 12.w,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ByWidgetsUtil.commonRichText(texts: [
                      TextSpan(
                          text: controller.isBindMode.value ? '绑定解锁' : '登录解锁',
                          style: TextStyle(
                              color: ByColorUtil.colorF1,
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w700)),
                      TextSpan(
                          text: '0基础',
                          style: TextStyle(
                              color: const Color(0xFFFEA324),
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w700)),
                      TextSpan(
                          text: '写小说',
                          style: TextStyle(
                              color: ByColorUtil.colorF1,
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w700)),
                    ]),
                    Row(
                      children: [
                        ByWidgetsUtil.commonText(
                            text: '赚钱秘籍',
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            textColor: const Color(0xFFFEA324)),
                        SizedBox(
                          width: 4.w,
                        ),
                        Image.asset(
                          'assets/global/login/icon_login_coin.png',
                          width: 22,
                          height: 22,),
                      ],
                    )
                  ],
                )
              ],
            ),

            SizedBox(
              height: 40.h,
            ),

            Image.asset(
              'assets/global/login/icon_login_business_tip.png',
              width: 132.w,
              height: 29.w,
            ),
            SizedBox(height: 2.h,),

            _buildPhoneLoginView(context),

            const Spacer(),
            
            checkProtocalView(),

            //   Obx(() => Offstage(
            //     offstage: !codeNode.hasFocus ||
            //       !phoneNode.hasFocus,
            //   child: SizedBox(height: 30.h),
            // )),
          ]),
        )),
        Image.asset(
          'assets/global/login/icon_login_bg.png',
          fit: BoxFit.contain,
        ),
        if(controller.showClose!)
        closeView(),
        if (type != LoginType.phone) phoneLoginView(),
        if(Platform.isIOS && !controller.isBindMode.value && Get.find<LaunchController>().launchInfo?.verConfig.allowTouristsVip == 1)
        visitorPay(),
      ],
    );
  }

  ///手机号码登录
  Widget _buildPhoneLoginView(BuildContext context) {
    return Column(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoginTextField(
              hintText: "请输入手机号",
              focusNode: controller.phoneNode,
              maxLength: 11,
              keyboardType: TextInputType.number,
              inputCallBack: (value) {
                controller.changePhoneNO(value);
              },
            ),
            SizedBox(height: 3.h),
            Obx(() => Offstage(
                  offstage: controller.checkVCodeBtnEnabled(),
                  child: Row(
                    children: [
                      // Image.asset(
                      //   "assets/mine/icon_info.png",
                      //   width: 12.w,
                      //   height: 12.w,
                      //   fit: BoxFit.contain,
                      // ),
                      SizedBox(width: 5.w),
                      ByWidgetsUtil.commonText(
                        text: "请输入正确的手机号码",
                        fontSize: 12.sp,
                        textColor: ByColorUtil.colorG4,
                      ),
                    ],
                  ),
                )),
          ],
        ),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            color: ByColorUtil.colorBg2,
            borderRadius: BorderRadius.circular(12.w),
          ),
          child: Stack(
            children: [
              Positioned(
                child: LoginTextField(
                  // text: provider.vCode,
                  hintText: "请输入验证码",
                  focusNode: controller.codeNode,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  inputCallBack: (value) {
                    controller.changeVCode(value);
                  },
                ),
              ),
              SizedBox(
                width: 10.w,
              ),
              Positioned(
                right: 4,
                top: 4,
                bottom: 4,
                child: SizedBox(
                  width: 94.w,
                  child: const CountDownBtn(
                    fontSize: 14,
                    textColor: ByColorUtil.colorC1,
                    resendAfterText: "重新发送",
                    showBorder: true,
                    // getVCode: controller.getVCode,
                  ),
                ),
              ),
            ],
          ),
        ),
        Obx(() => Offstage(
                  offstage: controller.vcodeInputRight.value,
                  child: Row(
                    children: [
                      SizedBox(width: 5.w),
                      ByWidgetsUtil.commonText(
                        text: "验证码错误",
                        fontSize: 12.sp,
                        textColor: ByColorUtil.colorG4,
                      ),
                    ],
                  ),
                )),
        SizedBox(height: 35.h),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (!controller.loginEnbled.value) return;
            FocusScope.of(context).unfocus();
            if (!controller.agreementChecked.value) {
              EventTracking.reportDataPoint(
                        pageTag: 'login_page_protocol_dialog',
                        operateType: 'view',
                        funcDetailImg: '',
                        funcDetailTag: '2',);
              showDialog(
                context: context,
                builder: (context) {
                  return LoginAgreementView(
                    callback: () {
                      FocusScope.of(context).unfocus();
                      controller.agreementCheckedStatusChanged(true);
                      if (controller.isBindMode.value) {
                        controller.bindPhone();
                      } else {
                        controller.loginWithVCode(context);
                      }
                    },
                  );
                },
              );
            } else {
              if (!controller.loginEnbled.value) return;
              if (controller.isBindMode.value) {
                controller.bindPhone();
              } else {
                controller.loginWithVCode(context);
              }
            }
          },
          child: Obx(() => Container(
                height: 48.h,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: controller.loginEnbled.value
                      ? ByColorUtil.colorC1
                      : ByColorUtil.colorC1.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12.w),
                ),
                child: Obx(
                  () => !controller.isLogin.value
                      ? Text(
                          controller.isBindMode.value ? "绑定" : "登录",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : CupertinoActivityIndicator(
                          color: Colors.black,
                          radius: 10.w,
                        ),
                ),
              )),
        ),
        if(controller.isBindMode.value)
        SizedBox(height: 12.w,),
        if(controller.isBindMode.value)
        ByWidgetsUtil.commonText(
          text: '*绑定账户后，可在任何设备恢复已购内容', 
          textColor: ByColorUtil.colorF1.withOpacity(0.5)),
      ],
    );
  }

  ///用户协议与隐私
  Widget checkProtocalView() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        controller
            .agreementCheckedStatusChanged(!controller.agreementChecked.value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            const Spacer(),
            if(Get.find<UserController>().isAudit())
            Obx(() => Image.asset(
                  controller.agreementChecked.value
                      ? "assets/global/common/btn_record_selected.png"
                      : "assets/global/common/btn_record.png",
                  width: 10,
                  height: 10,
                )),
            const SizedBox(width: 8),
            ByWidgetsUtil.commonRichText(
              texts: [
                const TextSpan(text: "已阅读并同意"),
                TextSpan(
                  text: "《用户协议》",
                  style: const TextStyle(
                    color: ByColorUtil.colorC1,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      controller.getProtocolByTitle("用户协议");
                    },
                ),
                const TextSpan(text: "和"),
                TextSpan(
                  text: "《隐私政策》",
                  style: const TextStyle(
                    color: ByColorUtil.colorC1,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      controller.getProtocolByTitle("隐私政策");
                    },
                ),
              ],
              fontSize: 12.sp,
              textColor: ByColorUtil.colorF2.withOpacity(0.6),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  ///其他手机号登录按钮
  Widget phoneLoginView() {
    return Positioned(
        top: MediaQuery.of(Get.context!).padding.top,
        right: 12.w,
        child: GestureDetector(
          child: Container(
            padding: EdgeInsets.all(12.w),
            child: ByWidgetsUtil.commonText(
              bgColor: Colors.transparent,
              textColor: ByColorUtil.colorC1,
              fontWeight: FontWeight.w500,
              fontSize: 14,
              text: '其他手机号登录',
            ),
          ),
          onTap: () {
            Get.toNamed(Routes.loginPhone);
          },
        ));
  }

  ///关闭按钮
  Widget closeView() {
    return Positioned(
      top: MediaQuery.of(Get.context!).padding.top,
      child: GestureDetector(
        onTap: () {
          // 清除待执行的操作
          Get.find<UserController>().clearPendingAction();
          Get.back();
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 45.w,
          height: 45.w,
          alignment: Alignment.center,
          margin: EdgeInsets.only(left: 6.w),
          child: Image.asset(
            "assets/global/common/btn_close.png",
            width: 36,
            height: 36,
          ),
        ),
      ),
    );
  }

  ///游客购买
  Widget visitorPay() {
    return Positioned(
      top: MediaQuery.of(Get.context!).padding.top,
      right: 24.w,
      child: GestureDetector(
        onTap: () {
          // 清除待执行的操作
          controller.visitorForPayPage();
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 45.w,
          alignment: Alignment.centerRight,
          child: ByWidgetsUtil.commonText(
            text: '不登录直接购买',
            textColor: ByColorUtil.colorF1.withOpacity(0.5))
        ),
      ),
    );
  }
}
