/*
 * @Author: cold-x
 * @Date: 2025-06-17 15:49:41
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-08-26 16:28:34
 * @FilePath: /fastcreationmaster/lib/core/widget/view/by_text_field.dart
 * @Description: 
 */



import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ByTextField extends StatelessWidget {

  const ByTextField({
    super.key,
    this.hintText = '',
    this.change,
    this.complete,
    this.align = TextAlign.start,
    this.maxLines = 1,
    this.maxLength,
    this.inputType = TextInputType.text,
    this.textColor = ByColorUtil.colorF1,
    this.inputFormatters,
    this.focusNode,
    this.scrollPhysics,
    this.readOnly = false,
    this.controller});

  final String? hintText;
  final Function(String)? change;
  final Function()? complete;
  final TextEditingController? controller;
  final int? maxLines;
  final TextAlign? align;
  final Color? textColor;
  final TextInputType? inputType;
  final int? maxLength;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final bool? readOnly;
  final ScrollPhysics? scrollPhysics;

  @override
  Widget build(BuildContext context) {
    return TextField(
        selectionControls: MaterialTextSelectionControls(),
        textAlign: align!,
        maxLines: maxLines,
        focusNode: focusNode,
        readOnly: readOnly!,
        autofocus: false,
        scrollPhysics: scrollPhysics,
        keyboardType: inputType,
        maxLength: maxLength ?? 999999999,
        inputFormatters: inputFormatters ?? [],
        textInputAction: TextInputAction.done,
        style: TextStyle(
          color: textColor,
          fontSize: 14.sp,
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(top: 3.w, left: 3.w),
          isCollapsed: true,
          border: InputBorder.none,
          hintText: hintText,
          counterText: '',
          hintStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.normal,
            color: ByColorUtil.colorF2,
          ),
          labelStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.normal,
            color: ByColorUtil.colorF1,
          ),
        ),
        onChanged: (String value) {
          change?.call(value);
        },
        onEditingComplete: () => complete?.call(),
        controller: controller ?? TextEditingController(),
      );
    
  }
}