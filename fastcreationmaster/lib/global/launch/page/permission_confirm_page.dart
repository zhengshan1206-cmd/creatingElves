import 'dart:io';
import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/util/channel/channel_operate.dart';
import 'package:fast_creation_master/core/widget/view/by_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../const/asset_const.dart';
import '../../ui/colors.dart';

class PermissionConfirmPage extends StatelessWidget {
  const PermissionConfirmPage({
    super.key,
    required this.onConfirm,
    this.title,
    this.content,
    this.confirmText,
    this.cancelText,
  });

  final String? title;
  final String? content;
  final String? confirmText;
  final String? cancelText;
  final void Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(),
          Positioned.fill(
            child: Image.asset(
              "assets/global/launch/launch_bg${AssetConst.springFestival()}.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 27.w),
              color: Colors.black.withOpacity(0.7),
              alignment: Alignment.center,
              child: SizedBox(
                width: double.infinity,
                child: ByWidgetsUtil.commonContainer(
                    bgColor: ByColorUtil.colorBg2,
                    padding: EdgeInsets.only(
                        left: 16.w, right: 16.w, top: 30.h, bottom: 10.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ByWidgetsUtil.commonText(
                          text: title ?? "用户协议与隐私政策提示",
                          textColor: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                        SizedBox(height: 20.h),
                        ByWidgetsUtil.commonRichText(
                          texts: [
                            TextSpan(
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              text: content ??
                                  "感谢您信任并使用Ai小说创作精灵!\n我们将持续采取互联网行业通行的技术措施和数据安全保护措施，保护您的隐私和个人信息安全您可通过阅读完整的",
                            ),
                            TextSpan(
                              text: "《用户协议》",
                              style: const TextStyle(
                                color: ByColorUtil.colorC1,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  ByNavRouterUtils.jumpWebViewPage(
                                      context,
                                      "用户协议",
                                      "https://inchat.beiyinapp.com/api/common9/novelUserAgreement");
                                },
                            ),
                            const TextSpan(
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              text: "和",
                            ),
                            TextSpan(
                              text: "《隐私政策》",
                              style: const TextStyle(
                                color: ByColorUtil.colorC1,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  ByNavRouterUtils.jumpWebViewPage(
                                      context,
                                      "隐私政策",
                                      "https://inchat.beiyinapp.com/api/common9/novelPrivacyPolicy");
                                },
                            ),
                            const TextSpan(
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              text:
                                  "了解详情。\n在上述协议中，我们将向您说明我们如何为您提供服务并保障您的用户权益，如何收集、使用、保存、共享和保护您的相关信息，以及为您提供的访问、修改、删除和您相关的信息的方式。我们会严格按照您的授权，在上述协议约定的范围内收集、存储和使用您注册信息、设备信息、日志信息、图片信息或其他经您授权的信息。使用本产品需要接入数据网络或WLAN网络。可能产生流量费用，具体详情需请您咨询当地运营商。如您已经充分阅读、理解并接受以上两份协议的内容，请您点击“同意并继续”开始接受我们的服务。",
                            ),
                          ],
                          fontSize: 12.sp,
                          fontWeight: FontWeight.normal,
                        ),
                        SizedBox(height: 20.h),
                        SizedBox(
                          height: 48.h,
                          child: ByButton.gradientBtn(
                                    borderRadius: 12.w,
                                    title: confirmText ?? "同意并继续",
                                    fontSize: 16.sp,
                                    textColor: Colors.black,
                                    bgColor: ByColorUtil.colorC1,
                                    fontWeight: FontWeight.w600,
                                    onClick: () async {
                                      onConfirm.call();
                                    },
                                  ),
                        ),
                        SizedBox(height: 4.h,),
                        ByButton.gradientBtn(
                                  borderRadius: 12.w,
                                  bgColor: Colors.transparent,
                                  title: cancelText ?? "不同意",
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16.sp,
                                  onClick: () async {
                                    Navigator.of(context).pop();
                                    showDialog(
                                      context: context,
                                      builder: (ctx) {
                                        return ExistConfirmPage(
                                          onConfirm: onConfirm,
                                        );
                                      },
                                    );
                                  },
                                ),
                      ],
                    )),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ExistConfirmPage extends StatelessWidget {
  const ExistConfirmPage({
    super.key,
    required this.onConfirm,
    this.title,
    this.content,
    this.confirmText,
    this.cancelText,
  });

  final String? title;
  final String? content;
  final String? confirmText;
  final String? cancelText;
  final void Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(),
          Positioned.fill(
            child: Image.asset(
              "assets/global/launch/launch_bg${AssetConst.springFestival()}.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 27.w),
              color: Colors.black.withOpacity(0.5),
              alignment: Alignment.center,
              child: SizedBox(
                width: double.infinity,
                child: ByWidgetsUtil.commonContainer(
                    bgColor: ByColorUtil.colorBg1,
                    margin: EdgeInsets.symmetric(horizontal: 12.w),
                    padding: EdgeInsets.only(
                        left: 16.w, right: 16.w, top: 30.h, bottom: 20.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ByWidgetsUtil.commonText(
                          text: title ?? "确认提示",
                          textColor: ByColorUtil.colorF1,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                        SizedBox(height: 20.h),
                        ByWidgetsUtil.commonRichText(
                          texts: [
                            TextSpan(
                              text: content ?? "进入应用前，请先同意",
                            ),
                            TextSpan(
                              text: "《用户协议》",
                              style: const TextStyle(
                                color: ByColorUtil.colorC1,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  ByNavRouterUtils.jumpWebViewPage(context, "",
                                      "https://inchat.beiyinapp.com/api/common9/novelUserAgreement");
                                },
                            ),
                            const TextSpan(
                              text: "和",
                            ),
                            TextSpan(
                              text: "《隐私政策》",
                              style: const TextStyle(
                                color: ByColorUtil.colorC1,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  ByNavRouterUtils.jumpWebViewPage(context, "",
                                      "https://inchat.beiyinapp.com/api/common9/novelPrivacyPolicy");
                                },
                            ),
                            const TextSpan(
                              text: "，否则将退出应用。",
                            ),
                          ],
                          fontSize: 12.sp,
                          textColor: ByColorUtil.colorF1,
                          fontWeight: FontWeight.normal,
                        ),
                        SizedBox(height: 20.h),
                        SizedBox(
                          height: 44.h,
                          child: Row(
                            children: [
                              Expanded(
                                child: ByWidgetsUtil.commonBtn(
                                  padding: EdgeInsets.zero,
                                  borderRadius: 12.w,
                                  title: cancelText ?? "退出应用",
                                  bgColor: ByColorUtil.colorBg2,
                                  fontWeight: FontWeight.normal,
                                  textColor: ByColorUtil.colorF2,
                                  fontSize: 16.sp,
                                  onClick: () async {
                                    if (Platform.isAndroid) {
                                      SystemNavigator.pop();
                                    } else {
                                      await ChannelOperate.exitApp();
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: 20.w),
                              Expanded(
                                child: ByWidgetsUtil.commonBtn(
                                  padding: EdgeInsets.zero,
                                  borderColor: ByColorUtil.colorC1,
                                  borderRadius: 12.w,
                                  title: confirmText ?? "同意并继续",
                                  fontSize: 16.sp,
                                  bgColor: ByColorUtil.colorBg2,
                                  textColor: ByColorUtil.colorC1,
                                  fontWeight: FontWeight.w500,
                                  onClick: () async {
                                    onConfirm.call();
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    )),
              ),
            ),
          )
        ],
      ),
    );
  }
}
