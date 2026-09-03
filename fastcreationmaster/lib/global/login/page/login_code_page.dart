/*
 * @Author: cold-x
 * @Date: 2025-07-21 10:15:59
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-07-29 16:46:36
 * @FilePath: /fastcreationmaster/lib/global/login/page/login_code_page.dart
 * @Description: 
 */

import 'dart:async';

import 'package:byhy_app_common_utils/app_common/consts/environment.dart';
import 'package:byhy_app_common_utils/app_http/apis.dart';
import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/global/login/controller/login_controller.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


///登录验证码获取填写页面
class LoginCodePage extends StatefulWidget {
  const LoginCodePage({
    super.key,
    required this.phoneNumber});

  final String phoneNumber; ///手机号

  @override
  State<LoginCodePage> createState() => _LoginCodePageState();
}

class _LoginCodePageState extends State<LoginCodePage> {

  final LoginController loginC = Get.find<LoginController>();

  ///验证码是否验证正确
  bool verificationValid = true;

  // 存储四个输入框的控制器
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  
  // 存储四个输入框的焦点节点
  final List<FocusNode> _focusNodes = List.generate(
    4,
    (_) => FocusNode(),
  );
  
  // 倒计时相关变量
  int _countdownSeconds = 0;
  late Timer? _timer;

  @override
  void initState() {
    super.initState();
    if(Environment.PRODUCTION.domain == APIs.apiPrefix) {
      _getVerificationCode();
    }
    else {
      _retryCode();
    }

    ///获取第一个弹窗焦点
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    });
  }
  
  /// 启动重新获取倒计时
  void _retryCode() {
    if (_countdownSeconds > 0) return;
    setState(() {
      _countdownSeconds = 60;
    });
    // 启动倒计时
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _timer != null) {
        setState(() {
          if (_countdownSeconds > 0) {
            _countdownSeconds--;
          } else {
            _stopCounting();
          }
        });
      }
    });
  }

  ///停止倒计时
  void _stopCounting() {
    _timer?.cancel();
    _timer = null;
  }

  // 获取接收验证码
  void _getVerificationCode() {
    loginC.getVCode(onSuccess: (p0) {
      _retryCode();
    },onFailed: (p0, p1) {

    },);
  }

  @override
  void dispose() {
    // 释放资源
    FocusScope.of(context).unfocus();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _stopCounting();
    super.dispose();
  }

  // // 自动填充验证码
  // void _autoFillCode(String code) {
  //   if (code.length != 4) return;
  //   for (int i = 0; i < 4; i++) {
  //     _controllers[i].text = code[i];
  //     if (i < 3) {
  //       FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
  //     } else {
  //       FocusScope.of(context).unfocus();
  //     }
  //   }
  // }

  // 处理输入变化，自动跳转到下一个输入框
  void _handleTextChange(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 3) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        FocusScope.of(context).unfocus();
      }
      // 验证码输入完成，可以进行验证
      _loginWithVCode();
    } else if (index > 0) {
      // 如果删除了当前字符，回到上一个输入框
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  String hidePhoneNumber(String phone) {
  // 正则匹配手机号中间4位并替换为*
    return phone.replaceAllMapped(
      RegExp(r'(\d{3})(\d{4})(\d{4})'), 
      (match) => '${match[1]}****${match[3]}'
    );
  }
  void _loginWithVCode() {
    String code = '';
    for (int i = 0; i < 4; i++) {
      final String text = _controllers[i].text;
      if(text.isEmpty) {
        return;
      }
      code += text;
    }
    // 验证是否为4位数字
    if (RegExp(r'^\d{4}$').hasMatch(code)) {
      loginC.loginWithVCode(context, 
      code: code, 
      onSuccess: () {
        Get.back();
        _stopCounting();
      },
      onFailed: (p0, p1) {
        if(mounted){
          setState(() {
            verificationValid = false;
          });
        }
      },);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColorUtil.colorBg1,
      body: buildBody(context));
  }

  ///关闭按钮
  Widget backView() {
    return Positioned(
      top: MediaQuery.of(Get.context!).padding.top,
      child: GestureDetector(
        onTap: () {
          Get.back();
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 52.w,
          height: 44.w,
          alignment: Alignment.center,
          child: Image.asset(
            "assets/global/common/btn_back.png",
            width: 16,
            height: 16,
          ),
        ),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          child: Image.asset(
            'assets/global/login/icon_login_bg.png',
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
            child: Padding(
          padding: EdgeInsets.all(24.w),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              height: 108.h,
            ),
            ByWidgetsUtil.commonText(
                textColor: ByColorUtil.colorC1,
                fontSize: 24.sp,
                maxLines: 1,
                text: '请输入短信验证码',),
            SizedBox(height: 6.h,),
            Row(
              children: [
                ByWidgetsUtil.commonText(
                textColor: ByColorUtil.colorF2,
                fontSize: 12.sp,
                maxLines: 1,
                text: '验证码已发送至手机',),
                ByWidgetsUtil.commonText(
                textColor: ByColorUtil.colorF1,
                fontSize: 12.sp,
                maxLines: 1,
                text: hidePhoneNumber(widget.phoneNumber),),
                const Spacer(),

                // 获取验证码按钮
                GestureDetector(
                  onTap: () {
                    if (_countdownSeconds == 0) {
                      _getVerificationCode();
                    }
                  },
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: 20,
                      minWidth: 100
                    ),
                    child: ByWidgetsUtil.commonText(
                      textColor: _countdownSeconds > 0
                          ? ByColorUtil.colorF2
                          : ByColorUtil.colorC1,
                      fontSize: 12.sp,
                      maxLines: 1,
                      textAlign: TextAlign.right,
                      text: _countdownSeconds > 0
                          ? '重新发送($_countdownSeconds秒)'
                          : '获取验证码',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20.h,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) {
                return Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: ByColorUtil.colorF1.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16.w),
                  ),
                  child: Center(
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 32.sp, color: ByColorUtil.colorC1),
                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) => _handleTextChange(value, index),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 20.h,),
            Offstage(
              offstage: verificationValid,
              child: Row(
                children: [
                  Image.asset(
                    "assets/global/common/icon_novel_warning.png",
                    width: 16,
                    height: 16,
                  ),
                  SizedBox(width: 6.w,),
                  ByWidgetsUtil.commonText(
                    textColor: ByColorUtil.colorG4,
                    text: '验证码输入错误，请验证后重新输入',
                  ),
                ],
              ),
            )
          ]),
        )),
        backView(),
      ],
    );
  }
}