//  description:  倒计时按钮

import 'dart:async';
import 'package:fast_creation_master/global/login/controller/login_controller.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:fast_creation_master/global/launch/view/login_agreement_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../other/event_tracking/event_tracking.dart';

const String _normalText = '获取验证码'; // 默认按钮文字
const String _resendAfterText = '重新获取'; // 重新获取文字
const int _normalTime = 60; // 默认倒计时时间
const double _fontSize = 16.0; // 文字大小
const double _borderRadius = 12.0; // 边框圆角

class CountDownBtn extends StatefulWidget {
  const CountDownBtn({
    super.key,
    this.getVCode,
    this.getCodeText = _normalText,
    this.resendAfterText = _resendAfterText,
    this.textColor,
    this.bgColor,
    this.fontSize = _fontSize,
    this.borderColor,
    this.borderRadius = _borderRadius,
    this.showBorder = false,
    this.onTap,
  });

  final void Function({
    void Function(dynamic)? onSuccess,
    void Function(int, String)? onFaild,
  })? getVCode;
  final String getCodeText;
  final String resendAfterText;
  final Color? textColor;
  final Color? bgColor;
  final double? fontSize;
  final Color? borderColor;
  final double? borderRadius;
  final bool showBorder;
  final Function()? onTap;

  @override
  State<CountDownBtn> createState() => _CountDownBtnState();
}

class _CountDownBtnState extends State<CountDownBtn> {
  Timer? _countDownTimer;
  Rx<String> btnStr = _normalText.obs;
  int _countDownNum = _normalTime;
  LoginController controller = Get.put(LoginController());

  @override
  void initState() {
    super.initState();

    btnStr.value = widget.getCodeText;
  }

  /// 释放掉Timer
  @override
  void dispose() {
    _countDownTimer?.cancel();
    _countDownTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  _body() {
    return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          widget.onTap?.call();
          _getVCode();
        },
        child: Obx(
          () => Container(
            height: 50.h,
            width: 94.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ByColorUtil.colorBg2,
              borderRadius: BorderRadius.circular(10.w),
            ),
            child: Text(
              btnStr.value,
              style: TextStyle(
                fontSize: widget.fontSize,
                color: controller.vCodeBtnEnabled.value
                    ? ByColorUtil.colorC1
                    : Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        ));

    // if (widget.getVCode == null) {
    //   return Container();
    // } else {
    //   return Consumer<LoginProvider>(builder: (context, provider, child) {
    //     return GestureDetector(
    //       behavior: HitTestBehavior.opaque,
    //       onTap: () => _getVCode(),
    //       child: Container(
    //         height: 45.h,
    //         width: 80.w,
    //         alignment: Alignment.center,
    //         // padding: EdgeInsets.symmetric(horizontal: 25.w),
    //         decoration: BoxDecoration(
    //           color: provider.vCodeBtnEnabled
    //               ? ByColorUtil.TabTextColorSelected
    //               : ByColorUtil.LoginBtnBgColor.withOpacity(0.3),
    //           borderRadius: const BorderRadius.only(
    //             topRight: Radius.circular(12.0),
    //             bottomRight: Radius.circular(12.0),
    //           ),
    //         ),
    //         child: Text(
    //           btnStr,
    //           style: TextStyle(
    //             fontSize: widget.fontSize,
    //             color: const Color(0xFFF3F3F5),
    //           ),
    //         ),
    //       ),
    //     );
    //   });
    // }
  }

  _getVCode() {
    if (controller.vCodeBtnEnabled.value == false) return;

    // 检查是否同意了用户协议
    if (!controller.agreementChecked.value) {
      EventTracking.reportDataPoint(
                        pageTag: 'login_page_protocol_dialog',
                        operateType: 'view',
                        funcDetailImg: '',
                        funcDetailTag: '2',);
      // 显示协议弹窗
      showDialog(
        context: context,
        builder: (context) {
          return LoginAgreementView(
            btnTitle: "确认同意",
            isLoginSend: true,
            callback: () {
              controller.agreementCheckedStatusChanged(true);
              // 同意后继续发送验证码
              _sendVCode();
            },
          );
        },
      );
      return;
    }

    _sendVCode();
  }

  /// 实际发送验证码的方法
  void _sendVCode() {
    controller.vCodeBtnEnabled.value = false;
    if (!controller.checkVCodeBtnEnabled()) return;
    EventTracking.reportDataPoint(
                        pageTag: 'login_page_verify_btn',
                        operateType: 'click',
                        funcDetailImg: '',
                        funcDetailTag: '2',);
    controller.getVCode(
      onSuccess: (_) {
        startCountdown();
      },
      onFailed: (p0, p1) {
        controller.vCodeBtnEnabled.value = true;
      },
    );
  }

  /// 开始倒计时
  void startCountdown() {
    setState(() {
      if (_countDownTimer != null) {
        return;
      }
      // Timer的第一秒倒计时是有一点延迟的，为了立刻显示效果可以添加下一行。
      // btnStr = '重新获取(${_countDownNum--}s)';
      btnStr.value = '${_countDownNum--}s';
      _countDownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_countDownNum > 0) {
          // btnStr = '重新获取(${_countDownNum--}s)';
          btnStr.value = '${_countDownNum--}s';
        } else {
          // btnStr = _normalText;
          btnStr.value = widget.resendAfterText;
          _countDownNum = _normalTime;
          _countDownTimer?.cancel();
          _countDownTimer = null;
          controller.vCodeBtnEnabled.value = true;
        }
      });
    });
  }
}
