/*
 * @Author: cold-x
 * @Date: 2025-06-13 17:46:56
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-07-14 15:03:00
 * @FilePath: /fastcreationmaster/lib/core/widget/view/progress_view.dart
 * @Description: 
 */



import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../global/ui/colors.dart';

// ignore: must_be_immutable
class ProgressView extends StatefulWidget {
  ProgressView({super.key, this.progress});

  double? progress = 0.0;

  @override
  State<ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends State<ProgressView> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.w),
        gradient: LinearGradient(
        colors: [const Color(0xFF98FC4A).withOpacity(0.4), const Color(0xFFD7F97D).withOpacity(0.4)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.w),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: widget.progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: ByColorUtil.colorG1(),
                      ),
                    ),
                  ),
                ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: ByWidgetsUtil.commonText(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        textColor: Colors.black,
                        text: '生成中${(widget.progress! * 100).round()}%'),
            ),
          ),
        ],
      ),
    );
  }
}