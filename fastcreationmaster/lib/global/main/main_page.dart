/*
 * @Author: cold-x
 * @Date: 2025-05-28 14:45:37
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-09-03 14:21:57
 * @FilePath: /fastcreationmaster/lib/global/main/main_page.dart
 * @Description: 
 */

import 'package:fast_creation_master/core/widget/view/muti_status_view.dart';
import 'package:fast_creation_master/global/main/main_controller.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../ui/assets.dart';

class MainPage extends StatelessWidget {
  MainPage({super.key});
  final MainController controller = Get.put(MainController());

  BottomNavigationBarItem tabbarItem(
      {String? label, String? assets, String? selectedAssets}) {
    return BottomNavigationBarItem(
      label: label,
      icon: assets == null
          ? const SizedBox()
          : Image.asset(assets, width: 28, height: 28),
      activeIcon: selectedAssets == null
          ? null
          : Image.asset(selectedAssets, width: 28, height: 28),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 检查是否有路由参数指定要跳转到哪个页面
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      final int? targetIndex = arguments['index'] as int?;
      if (targetIndex != null && targetIndex >= 0 && targetIndex < 3) {
        // 延迟执行，确保页面已经构建完成
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.navigateToPage(targetIndex);
        });
      }
    }

    return _bodyView(context);
  }

  _bodyView(BuildContext context) {
    return GetBuilder<MainController>(
      builder: (controller) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: ByColorUtil.colorBg1,
          bottomNavigationBar: Obx(() => BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: controller.currentIndex.value,
                backgroundColor: ByColorUtil.colorBg1,
                iconSize: 28,
                selectedItemColor: ByColorUtil.colorC1,
                unselectedItemColor: const Color(0xFFA4A8AB),
                selectedLabelStyle: TextStyle(fontSize: 11.sp),
                unselectedLabelStyle: TextStyle(fontSize: 11.sp),
                items: [
                  tabbarItem(
                    label: '首页',
                    assets: Assets.tabHome,
                    selectedAssets: Assets.tabHomeSelected,
                  ),
                  tabbarItem(
                    label: '攻略',
                    assets: Assets.tabSquare,
                    selectedAssets: Assets.tabSquareSelected,
                  ),
                  tabbarItem(
                    label: '我的',
                    assets: Assets.tabProfile,
                    selectedAssets: Assets.tabProfileSelected,
                  ),
                ],
                onTap: (index) {
                  controller.tabChanged(index);
                },
              )),
          body: Obx(() => MultiStatusView(
            hasAppBar: false,
            currentStatus: controller.launchStatus.value,
            action: () {
              controller.fetchLaunchData();
            },
            child: Stack(
              children: [
                ...controller.tabBarPages.map((e) {
                  return Obx(() => Offstage(
                        offstage: controller.currentIndex.value !=
                            controller.tabBarPages.indexOf(e),
                        child: e,
                      ));
                }),
              ],
            ),
          ),
        ));
      },
    );
  }
}
