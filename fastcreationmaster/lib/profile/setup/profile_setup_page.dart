import 'package:fast_creation_master/core/widget/page/base_page.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:fast_creation_master/profile/setup/controller/profile_setup_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../core/util/by_screen_utils.dart';
import '../../global/routes/app_pages.dart';

// ignore: must_be_immutable
class ProfileSetupPage extends BasePage {
  ProfileSetupPage({super.key});

  final ProfileSetupController _controller = Get.find<ProfileSetupController>();

  @override
  String get title => "设置";

  @override
  Widget buildBody(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Obx(
            () => Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: const BoxDecoration(
                    color: ByColorUtil.colorBg2,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Column(
                    children: [
                      _infoItem('用户协议', 'assets/profile/icon_setup_pact.png'),
                      _infoItem(
                          '隐私政策', 'assets/profile/icon_setup_privacy.png'),
                      _infoItem(
                          '会员服务协议', 'assets/profile/icon_setup_member.png'),
                      _infoItem(
                          '算法备案公示', 'assets/profile/icon_setup_privacy.png'),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: const BoxDecoration(
                    color: ByColorUtil.colorBg2,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Column(
                    children: [
                      _infoItem('投诉举报', 'assets/profile/profile_trend_12.png'),
                      _infoItem('关于我们', 'assets/profile/icon_setup_us.png'),
                      if (_controller.userInfo?.isFormal == 1)
                        _infoItem(
                            '注销账号', 'assets/profile/icon_setup_logout.png'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Obx(() {
          return _controller.userInfo?.isFormal == 1
              ? Positioned(
                  left: 0,
                  right: 0,
                  bottom: ByScreenUtils.bottomSafeHeight + 4.w,
                  child: GestureDetector(
                    onTap: () {
                      _controller.showLogoutConfirm();
                    },
                    child: Container(
                      width: double.infinity,
                      color: ByColorUtil.colorBg1,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w),
                      child: Container(
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: ByColorUtil.colorB1,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Center(
                          child: Text(
                            '退出登录',
                            style: TextStyle(
                              fontSize: 17,
                              color: ByColorUtil.colorG4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink();
        }),
      ],
    );
  }

  ///信息列表-item
  Widget _infoItem(String title, String image) {
    return GestureDetector(
      onTap: () {
        if (title == '注销账号') {
          _controller.showDeleteAccountConfirm();
        } else if(title == '关于我们') {
          Get.toNamed(Routes.aboutUs);
        } else {
          _controller.getProtocolByTitle(title);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 17, bottom: 17),
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
                Image.asset(image, width: 18, height: 18, fit: BoxFit.fill),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
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
    );
  }
}
