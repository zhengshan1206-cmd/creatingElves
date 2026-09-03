/*
 * @Author: cold-x
 * @Date: 2025-06-04 11:43:15
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-08-07 11:46:58
 * @FilePath: /fastcreationmaster/lib/global/launch/page/guide_page.dart
 * @Description: 用户引导页
 */

import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/util/by_screen_utils.dart';
import 'package:fast_creation_master/core/widget/view/by_button.dart';
import 'package:fast_creation_master/global/launch/controller/guide_controller.dart';
import 'package:fast_creation_master/global/launch/page/guide_novel_choose_page.dart';
import 'package:fast_creation_master/global/routes/app_pages.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class GuidePage extends StatefulWidget {
  const GuidePage({super.key});

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {

  final GuideController controller = Get.find<GuideController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildSinglePage(),
        ///立即创作按钮
          Positioned(
            bottom: 40.h,
            child: SizedBox(
              height: 48.w,
              width: ByScreenUtils.screenWidth,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Stack(children: [
                  ByButton.gradientBtn(
                      textColor: const Color(0xFF162408),
                      title: "开始创作",
                      onClick: () {
                        controller.initGetPhone();
                        Get.off(() => const GuideNovelChoosePage());
                      }),
                  Obx((){
                    return controller.giveWords.value > 0 ?
                    Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          height: 18,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF617BFF),
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                                topRight: Radius.circular(8)),
                          ),
                          child: Text(
                            '已赠送${controller.giveWords.value}字',
                            style: const TextStyle(
                                fontSize: 12,
                                color: ByColorUtil.colorF1,
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none),
                          ),
                        )) : Container();
                  })
                  
                ]),
              ),
            ),
          ),

        ///随便看看
          Positioned(
            right: 12.w,
            top: 48.w,
            child: Container(
              width: 80,
              height: 32,
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16)),
              child: ByWidgetsUtil.commonBtn(
                  padding: EdgeInsets.zero,
                  bgColor: Colors.transparent,
                  textColor: ByColorUtil.colorC1,
                  title: '随便看看',
                  fontWeight: FontWeight.w400,
                  fontSize: 12.sp,
                  onClick: () {
                    Get.offNamed(Routes.main);
                  }),
            ),
          )
      ],
    );
  }

  ///单个引导页面布局
  Widget _buildSinglePage() {
    return Container(
      color: ByColorUtil.colorBg1,
      child: Stack(
        children: [
          Image.asset(
            'assets/global/launch/icon_guide_bg.png',
            fit: BoxFit.cover,
          ),
          Container(
            width: double.infinity,
            height: 667.w - 81.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ByColorUtil.colorBg1,
                    ByColorUtil.colorBg1.withOpacity(81 / 776),
                    ByColorUtil.colorBg1
                  ]),
            ),
          ),
          Positioned(
            left: 32.w,
            bottom: 0.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ByWidgetsUtil.commonText(
                  text: 'AI让你秒变文学巨匠',
                  textColor: ByColorUtil.colorC1,
                  fontFamily: 'AlimamaShuHeiTi',
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(
                  height: 5,
                ),
                ByWidgetsUtil.commonText(
                  text: '灵感多到用不完，读者追更追到疯狂！',
                  textColor: ByColorUtil.colorC1,
                  fontFamily: 'AlimamaShuHeiTi',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
