

import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/widget/page/base_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../global/ui/colors.dart';
import '../controllers/about_us_controller.dart';

// ignore: must_be_immutable
class AboutUsPage extends BasePage  {
  AboutUsPage({super.key});

  @override
  String get title => '关于我们';

  @override
  AboutUsController get controller => Get.find<AboutUsController>();

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 70.w),
        ClipRRect(
          borderRadius: BorderRadius.circular(12.w),
          child: Image.asset(
            "assets/icon.png",
            width: 100.w,
            height: 100.w,
          ),
        ),
        SizedBox(height: 20.w),
        ByWidgetsUtil.commonText(
          text:  "AI小说创作精灵",
          fontSize: 18, 
          fontWeight: FontWeight.w500,
          textColor: ByColorUtil.colorF1,
        ),
        SizedBox(height: 9.w),
        Obx(() => ByWidgetsUtil.commonText(
          text: '版本号: v${controller.version.value}',
          fontSize: 14, 
          textColor: ByColorUtil.colorF1,
        )),
        SizedBox(height: 30.w),

        _versionItem(),
        // _infoItem('用户协议', 1),
        // _infoItem('隐私政策', 2),

        const Spacer(),

        ByWidgetsUtil.commonText(
          text: "客服邮箱：beiyin@beiyinapp.com",
          fontSize: 16.sp, 
          textColor: ByColorUtil.colorF1
        ),
        SizedBox(height: 50.h,),
        ByWidgetsUtil.commonText(
          text: "蜀ICP备2020026986号-17A",
          fontSize: 12.sp, 
          textColor: ByColorUtil.colorF1.withOpacity(0.5),
        ),
        // SizedBox(height: 12.w,),
        ByWidgetsUtil.commonText(
          text: "成都贝因欢阅科技有限公司 所有",
          fontSize: 12.sp, 
          textColor: ByColorUtil.colorF1.withOpacity(0.5),
        ),
        SizedBox(height: 20.w),
      ],
    );
  }

  ///信息列表-item
  Widget _versionItem() {
    return GestureDetector(
      onTap: () {
        ///版本更新
        if(controller.bean.value != null) {
          controller.jumpToPage(0);
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Container(
          width: double.infinity,
          height: 48.w,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: ByColorUtil.colorL1,
                width: 1,
              ),
            ),
          ),
          child: Obx(() => Row(
                children: [
                  Text(
                    '版本更新',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: ByColorUtil.colorF1,
                    ),
                  ),
                  const Spacer(),
                  if(controller.bean.value != null)
                  Container(
                    height: 22.w,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.w),
                      color: ByColorUtil.colorG4
                    ),
                    child: Center(
                      child: ByWidgetsUtil.commonText(
                        text: '有新版本', 
                        textColor: ByColorUtil.colorF1, 
                        fontSize: 12.sp),
                    ),
                  ),
                  if(controller.bean.value != null)
                  SizedBox(width: 6.w,),
                  ByWidgetsUtil.commonText(
                    text: controller.bean.value != null ? 'v${controller.bean.value?.version}' : '当前已是最新版本', 
                    textColor: ByColorUtil.colorF1, 
                    fontSize: 12.sp)
                ],
              )),
        ),
      ),
    );
  }

  ///信息列表-item
  Widget _infoItem(String title, int index) {
    return GestureDetector(
      onTap: () {
        ///版本更新
        controller.jumpToPage(index);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Container(
          width: double.infinity,
          height: 48.w,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: ByColorUtil.colorL1,
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: ByColorUtil.colorF1,
                    ),
                  ),
                ],
              ),
              Image.asset('assets/profile/profile_right-icon.png',
                  width: 12, height: 12, fit: BoxFit.fill),
            ],
          ),
        ),
      ),
    );
  }
}