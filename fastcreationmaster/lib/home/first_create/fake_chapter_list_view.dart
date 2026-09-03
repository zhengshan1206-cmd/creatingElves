import 'dart:ui';

import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/controller/user_controller.dart';
import '../../core/widget/view/by_button.dart';
import '../../global/ui/colors.dart';

///假的章节目录
class FakeChapterListView extends StatelessWidget {
  const FakeChapterListView({super.key});

  Widget _fakeItemView() {
    final userController = Get.find<UserController>();
    return SizedBox(
      height: 65.w,
      child: Row(
        children: [
          Stack(
            children: [
              ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: 4,
                  sigmaY: 4,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ByWidgetsUtil.commonText(
                          text: '虐恋爽文 第四章 ',
                          textColor: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 4.w,
                    ),
                    Row(
                      children: [
                        ByWidgetsUtil.commonText(
                          text: '2000字',
                          textColor: ByColorUtil.colorF2,
                          fontSize: 12,
                        ),
                        SizedBox(
                          width: 8.w,
                        ),
                        Container(
                          width: 1,
                          height: 12.w,
                          color: const Color(0x664D4E56),
                        ),
                        SizedBox(
                          width: 8.w,
                        ),
                        ByWidgetsUtil.commonText(
                          text: '2025-9-24',
                          textColor: ByColorUtil.colorF2,
                          fontSize: 12,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: 72.w,
            height: 24.w,
            child: ByButton.gradientBtn(
                bgColor: ByColorUtil.color2E3038,
                textColor: ByColorUtil.colorC1,
                borderRadius: 12.w,
                padding: const EdgeInsets.all(0),
                title: '立即查看',
                fontSize: 12,
                onClick: () {
                  userController.checkPreLogin(
                    source: 'novel_manage',
                    actionCallback: () {
                      userController.jumpToPayPage(source: 'novel_manage');
                    },
                  );

                  // userController.checkPreLogin(actionCallback: () {
                  //   action?.call(bean, index);
                  // });
                }),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      decoration: BoxDecoration(
          color: const Color(0XFF1E1F24),
          borderRadius: BorderRadius.circular(10.w)),
      margin: EdgeInsets.only(left: 12.w, right: 12.w),
      padding: EdgeInsets.all(12.w),
      child: Column(
        children: [
          Row(
            children: [
              ByWidgetsUtil.commonText(
                text: '目录',
                textColor: Colors.white,
                fontSize: 15,
              ),
              // const Spacer(),
              // ByButton.gradientImageBtn(
              //     title: '正序',
              //     bgColor: Colors.transparent,
              //     textColor: ByColorUtil.colorC1,
              //     fontSize: 13,
              //     image: 'assets/global/common/icon_switch_column.png',
              //     onClick: () {}),
            ],
          ),
          _fakeItemView(),
          _fakeItemView(),
          _fakeItemView(),
          _fakeItemView(),
        ],
      ),
    );
  }
}

class RefreshFakeChapter{
  const RefreshFakeChapter();
}