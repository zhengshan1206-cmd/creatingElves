/*
 * @Author: cold-x
 * @Date: 2025-06-16 11:15:32
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-07-09 18:42:12
 * @FilePath: /fastcreationmaster/lib/home/long_novel/view/novel_manager_view.dart
 * @Description: 小说首页管理页
 */



import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/util/by_screen_utils.dart';
import 'package:fast_creation_master/core/widget/view/progress_bar.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:fast_creation_master/home/long_novel/controller/novel_manager_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class NovelManagerView extends StatelessWidget {
  NovelManagerView({
    super.key});
  final NovelManagerController controller = Get.find<NovelManagerController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 213.w + ByScreenUtils.bottomSafeHeight,
      color: ByColorUtil.colorBg1,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            height: 50.w,
            child: Row(children: [
              ByWidgetsUtil.commonText(
                fontSize: 17,
                textColor: Colors.white,
                fontWeight: FontWeight.w500,
                text: '管理'),
              const Spacer(),
              GestureDetector(
                onTap: () => Get.back(),
                child: Image.asset(
                  'assets/global/common/btn_close.png',
                  width: 30,
                  height: 30,
                ),
              )
            ],),
          ),

          Padding(
            padding: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 16.w),
            child: GridView.builder(
              padding: EdgeInsets.zero,
              clipBehavior: Clip.none,
              shrinkWrap: true,
              itemCount: controller.titles.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 7,
                crossAxisSpacing: 0,
                childAspectRatio: 375 / 213, // 宽高比
              ),
              itemBuilder: (context, index) {
                return _buildItem(index,);
              },
            ),
          ),
        ],
      ),
    );
  }

  ///管理items页
  Widget _buildItem(int index) {
    NovelManagerItem item = controller.items[index];
    return Obx(() => Opacity(
      opacity: item.isActive.value || item.downloading.value ? 1.0 : 0.3,
      child: GestureDetector(
        onTap: () => controller.clickManagerItemIndex(index),
        child: Column(
          children: [
            ///正在下载时
            item.downloading.value ? _loadingProgress(item) :
            Image.asset(
              'assets/home/novel/btn_novel_manager_$index.png',
              width: 33.w,
              height: 33.w,
            ),
            SizedBox(
              height: 7.w,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ByWidgetsUtil.commonText(textColor: ByColorUtil.colorF2, text: item.title),

                ///有违禁词时带红点
                if(item.isActive.value && index == 3)
                SizedBox(width: 4.w,),
                if(item.isActive.value && index == 3)
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: ByColorUtil.colorG4,
                    borderRadius: BorderRadius.circular(3),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    ));
  }

  ///管理进度下载页
  Widget _loadingProgress(NovelManagerItem item) {
    return Column(
      children: [
        ByWidgetsUtil.commonText(
          textColor: ByColorUtil.colorC1, 
          text: '${item.progress}%'),
        SizedBox(height: 10.w,),
        SizedBox(
          width: 50.w,
          height: 4.w,
          child: ProgressBar(
            progress: item.progress.value/100,
          )),
      ],
    );
  }
}