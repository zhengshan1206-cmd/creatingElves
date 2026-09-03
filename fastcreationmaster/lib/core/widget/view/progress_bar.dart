/*
 * @Author: cold-x
 * @Date: 2025-06-14 14:49:27
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-08-04 10:36:30
 * @FilePath: /fastcreationmaster/lib/core/widget/view/progress_bar.dart
 * @Description: 
 */
import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../global/ui/colors.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    this.progressColor,
    this.trackColor,
    this.progress,
    this.progressGradiantColor,
    this.loadingText,
    this.border,
  });

  final Color? progressColor;
  final Color? trackColor;
  final double? progress;
  final Gradient? progressGradiantColor;
  final String? loadingText;
  final double? border;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(border ?? 100),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: trackColor ?? const Color(0xFFF4F7F8),
            ),
          ),
          FractionallySizedBox(
            widthFactor: progress ?? 0.5,
            heightFactor: 1,
            child: Container(
              decoration: progressGradiantColor != null ? BoxDecoration(
                  gradient: progressGradiantColor!,
                  borderRadius: BorderRadius.circular(border ?? 100)) : 
                  BoxDecoration(
                  color: progressColor ?? ByColorUtil.colorC1,
                  borderRadius: BorderRadius.circular(border ?? 100)),
            ),
          ),
          Positioned.fill(
            child: 
            Center(
              child: ByWidgetsUtil.commonText(
                text: loadingText ?? '', 
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                textColor: Colors.black),
            ))
        ],
      ),
    );
  }
}
