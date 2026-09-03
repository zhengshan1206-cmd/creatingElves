import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShareEarnView extends StatefulWidget {
  const ShareEarnView({super.key});

  @override
  State<ShareEarnView> createState() => _ShareEarnViewState();
}

class _ShareEarnViewState extends State<ShareEarnView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 12.w),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image.asset(
              //   'assets/home/shareEarn/share_1.png',
              //   width: 14.w,
              //   height: 14.h,
              // ),
              Image.asset(
                'assets/home/shareEarn/share_2.png',
                width: 30.w,
                height: 30.h,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 分享赚取收益提示语
class ShareEarnTipView extends StatelessWidget {
  const ShareEarnTipView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: Image.asset(
            'assets/home/shareEarn/share_7.png',
            width: 12.w,
            height: 6.h,
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -1),
          child: Container(
            height: 26.h,
            padding: EdgeInsets.only(left: 8.w, right: 8.w),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(26)),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFFFF9A81),
                  Color(0xFFFE5024),
                  Color(0xFFFE5024),
                ],
                stops: [0.0, 0.16, 1.0],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ByWidgetsUtil.commonText(
                  text: '分享作品，最高赚',
                  textColor: Colors.white,
                  fontSize: 12.sp,
                ),
                ByWidgetsUtil.commonText(
                  text: '34.6',
                  textColor: const Color(0xFFF8FF21),
                  fontWeight: FontWeight.bold,
                ),
                ByWidgetsUtil.commonText(
                  text: '元',
                  textColor: const Color(0xFFF8FF21),
                  fontSize: 12.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
