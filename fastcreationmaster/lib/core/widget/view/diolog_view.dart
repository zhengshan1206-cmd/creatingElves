/*
 * @Author: cold-x
 * @Date: 2025-06-11 20:34:47
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-07-15 14:49:02
 * @FilePath: /fastcreationmaster/lib/core/widget/view/diolog_view.dart
 * @Description: 
 */

import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/widget/view/by_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../global/ui/colors.dart';

enum CommomDiologTye {
  normal,

  ///默认文本
  textfeild,

  ///输入框
}

class CommomDiolog extends StatelessWidget {
  CommomDiolog({
    super.key,
    this.onConfirm,
    this.title,
    this.content,
    this.cancelText,
    this.confirmText,
    this.cancelColor,
    this.confirmBgColor,
    this.confirmTextColor,
    this.maxLength = 20,
    this.type = CommomDiologTye.normal,
  });

  final Function(String)? onConfirm;
  final String? title;
  final String? content;
  final String? cancelText;
  final String? confirmText;
  final Color? cancelColor;
  final Color? confirmBgColor;
  final Color? confirmTextColor;
  final CommomDiologTye? type;
  final int? maxLength; ///输入框最大长度

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (type == CommomDiologTye.textfeild) {
      controller.text = content ?? '';
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SizedBox(
          width: 320.w,
          height: type == CommomDiologTye.normal ? 231.w : 270.w,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                width: 320.w,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: ByColorUtil.colorBg2,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                          height:
                              type == CommomDiologTye.normal ? 88.w : 108.w),

                      ///dialog类型判断
                      type == CommomDiologTye.normal
                          ? ByWidgetsUtil.commonText(
                              text: content ?? "文件删除后无法恢复哦",
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              textColor: Colors.white,
                            )
                          : _buildTextFeild(),
                      SizedBox(height: 49.w),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 50.w,
                                child: ByWidgetsUtil.commonBtn(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20.w),
                                    bgColor:
                                        cancelColor ?? ByColorUtil.color2E3038,
                                    title: cancelText ?? "取消",
                                    textColor: ByColorUtil.colorF2,
                                    fontSize: 17,
                                    borderRadius: 15,
                                    fontWeight: FontWeight.w500,
                                    onClick: () {
                                      Get.back();
                                    }),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: SizedBox(
                                height: 50.w,
                                child: ByButton.gradientBtn(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20.w),
                                    title: confirmText ?? "确认",
                                    bgColor: confirmBgColor,
                                    textColor: confirmTextColor ?? Colors.white,
                                    fontSize: 17,
                                    borderRadius: 15,
                                    fontWeight: FontWeight.w500,
                                    onClick: () {
                                      Get.back();
                                      onConfirm?.call(controller.text);
                                    }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16.w,
                top: 28.w,
                child: ByWidgetsUtil.commonText(
                  text: title ?? "确认",
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  textColor: Colors.white,
                ),
              ),
              Positioned(
                right: 16.w,
                top: 12.w,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: SizedBox(
                    width: 36.w,
                    height: 36.w,
                    child: Image.asset(
                      "assets/global/common/btn_close.png",
                      width: 24.w,
                      height: 24.w,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFeild() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Container(
        height: 50.w,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: ByColorUtil.colorBg3,
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: TextField(
          controller: controller,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          selectionControls: MaterialTextSelectionControls(),
          maxLines: 1,
          autofocus: false,
          focusNode: FocusNode(),
          scrollController: ScrollController(),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.zero,
            isCollapsed: true,
            border: InputBorder.none,
            labelStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
          onChanged: (value) {
            ///限制输入长度
            if (value.length > maxLength!) {
              controller.text = value.substring(0, maxLength!);
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length),
              );
            }
          },
        ),
      ),
    );
  }
}

class NovelDialog extends StatelessWidget {
  const NovelDialog({
    super.key,
    this.title,
    this.content,
    this.cancelText,
    this.cancelTextColor,
    this.confirmText,
    this.cancelColor,
    this.confirmBgColor,
    this.confirmTextColor,
    this.showCancelBtn = true,
    this.onConfirm, 
    this.contentAlign = TextAlign.center,
    this.onCancel});

  final Function()? onConfirm;
  final Function()? onCancel;
  final String? title;
  final String? content;
  final String? cancelText;
  final String? confirmText;
  final Color? cancelColor;
  final Color? confirmBgColor;
  final Color? confirmTextColor;
  final Color? cancelTextColor;
  final bool? showCancelBtn;///是否显示取消
  final TextAlign? contentAlign;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: ByColorUtil.colorBg2,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 30.w),
                ByWidgetsUtil.commonText(
                  text: title ?? "温馨提示",
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  textColor: Colors.white,
                ),
                SizedBox(height: 20.w),
                ByWidgetsUtil.commonText(
                  text: content ?? "网络错误，需要重新生成，\n生成失败不会消耗字数",
                  fontSize: 15,
                  maxLines: 10,
                  textAlign: contentAlign ?? TextAlign.center,
                  fontWeight: FontWeight.w500,
                  textColor: Colors.white,
                ),
                SizedBox(height: 26.w),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      if (!showCancelBtn!)
                      Expanded(
                        child: SizedBox(
                          height: 50.w,
                          child: ByWidgetsUtil.commonBtn(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              bgColor: cancelColor ?? ByColorUtil.color2E3038,
                              title: cancelText ?? "取消",
                              textColor: cancelTextColor ?? ByColorUtil.colorF2,
                              fontSize: 17,
                              borderRadius: 15,
                              fontWeight: FontWeight.w500,
                              onClick: () {
                                Get.back();
                                onCancel?.call();
                              }),
                        ),
                      ),
                      if(!showCancelBtn!)
                      SizedBox(width: 12.w),
                      Expanded(
                        child: SizedBox(
                          height: 50.w,
                          child: ByButton.gradientBtn(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              title: confirmText ?? "确认",
                              bgColor: confirmBgColor ?? ByColorUtil.colorC1,
                              textColor: confirmTextColor ?? Colors.black,
                              fontSize: 17,
                              borderRadius: 15,
                              fontWeight: FontWeight.w500,
                              onClick: () {
                                Get.back();
                                onConfirm?.call();
                              }),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.w,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
