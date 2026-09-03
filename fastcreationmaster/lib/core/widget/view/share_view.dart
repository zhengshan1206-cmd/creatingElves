/*
 * @Author: cold-x
 * @Date: 2025-06-16 15:25:41
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-08-27 18:10:15
 * @FilePath: /fastcreationmaster/lib/core/widget/view/share_view.dart
 * @Description: 
 */

import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
// ignore: unused_import
import 'package:fast_creation_master/core/util/by_screen_utils.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wechat_kit/wechat_kit.dart';

///分享网页至微信好有、微信朋友圈
class ShareView extends StatelessWidget {
  const ShareView(
      {super.key,
      this.title = 'Ai小说创作精灵',
      this.desc = '',
      required this.webURL});

  ///网页链接
  final String webURL;

  ///标题
  final String? title;

  ///描述
  final String? desc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 58.w),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/home/shareEarn/share_3.png'),
          fit: BoxFit.fitWidth,
          alignment: Alignment.topCenter,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 1.sw,
            padding: EdgeInsets.only(top: 14.w, left: 12.w, right: 12.w),
            decoration: BoxDecoration(
              color: ByColorUtil.colorF1,
              image: const DecorationImage(
                image: AssetImage('assets/home/shareEarn/share_4.png'),
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,
              ),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12.w),
                topLeft: Radius.circular(12.w),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ByWidgetsUtil.commonText(
                          text: '分享得好礼, 最高分享赚',
                          textColor: const Color(0xFF000000),
                          fontSize: 20.sp,
                          fontFamily: 'AlimamaShuHeiTi',
                        ),
                        ByWidgetsUtil.commonText(
                          text: '34.6',
                          textColor: const Color(0xFFFE5024),
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'AlimamaShuHeiTi',
                        ),
                        ByWidgetsUtil.commonText(
                          text: '元',
                          textColor: const Color(0xFF000000),
                          fontSize: 20.sp,
                          fontFamily: 'AlimamaShuHeiTi',
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: SizedBox(
                        child: Image.asset(
                          'assets/home/shareEarn/share_8.png',
                          width: 24.w,
                          height: 24.w,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 12.w,
                ),
                Container(
                  padding: EdgeInsets.only(top: 28.w, left: 24.w, right: 24.w),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/home/shareEarn/share_5.png'),
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildShareItem(
                        'assets/global/common/btn_wechat_friend.png',
                        '分享给朋友',
                      ),
                      _buildShareItem(
                        'assets/global/common/btn_wechat_moments.png',
                        '分享给朋友圈',
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 56.w,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareItem(String image, String shareType) {
    return GestureDetector(
      onTap: () {
        share(shareType);
      },
      child: Column(
        children: [
          Image.asset(
            image,
            width: 44.w,
            height: 44.w,
          ),
          SizedBox(
            height: 8.w,
          ),
          ByWidgetsUtil.commonText(
              textColor: ByColorUtil.colorF2, text: shareType),
        ],
      ),
    );
  }

  void share(String shareType) async {
    bool isInstalled = await WechatKitPlatform.instance.isInstalled();
    final Uint8List? thumbData = await rootBundle
        .load('assets/thumb_icon.png')
        .then((data) => data.buffer.asUint8List());
    if (isInstalled) {
      await WechatKitPlatform.instance.shareWebpage(
        title: title,
        scene:
            shareType == '分享给朋友' ? WechatScene.kSession : WechatScene.kTimeline,
        thumbData: thumbData,
        description: desc,
        webpageUrl: webURL,
      );
      Get.back();
    } else {
      BotToast.showText(text: '您尚未安装微信，无法分享');
    }
  }
}
