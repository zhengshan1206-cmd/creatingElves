/*
 * @Author: cold-x
 * @Date: 2025-08-27 11:48:43
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-09-01 14:37:57
 * @FilePath: /fastcreationmaster/lib/profile/member/dialog/pay_operation_dialog.dart
 * @Description: 
 */

import 'package:byhy_app_common_utils/app_ui/byhy_screen_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fast_creation_master/core/widget/view/by_button.dart';
import 'package:fast_creation_master/global/routes/routes_utils.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../global/ui/widget/byhy_video_player_view.dart';

class PayOperationDialog extends StatelessWidget {
  final BannerBean bean;
  final int type;
  const PayOperationDialog({super.key, required this.bean, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ByColorUtil.colorF8.withOpacity(0.3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            color: ByColorUtil.colorBg1,
            constraints: BoxConstraints(
              maxHeight: ByScreenUtils.screenHeight - (56 + ByScreenUtils.bottomSafeHeight + 20 + ByScreenUtils.topSafeHeight)
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  type == 101
                      ? VideoPlayerWidget(
                          showVideoProgress: false,
                          url: bean.imgUrl,
                          autoPlay: true,
                        )
                      : CachedNetworkImage(
                          fit: BoxFit.fitWidth,
                          width: double.infinity,
                          imageUrl: bean.imgUrl,
                        ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                            ByColorUtil.colorBg1,
                            ByColorUtil.colorBg1.withOpacity(0.7),
                            ByColorUtil.colorBg1.withOpacity(0)
                          ])),
                    ),
                  ),
                  //关闭按钮
                  Positioned(
                    right: 12,
                    top: 12,
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: ByColorUtil.colorF8.withOpacity(0.3)),
                        child: Image.asset(
                          "assets/global/common/btn_close.png",
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 56 + ByScreenUtils.bottomSafeHeight,
            padding: EdgeInsets.fromLTRB(12, 4, 12, 4 + ByScreenUtils.bottomSafeHeight),
            color: ByColorUtil.colorBg1,
            child: ByButton.gradientBtn(
                padding: EdgeInsets.zero,
                  title: bean.title, textColor: ByColorUtil.colorF8, onClick: () {
                    NavigateUtils.navigateTo(bean);
                  }),
          )
        ],
      ),
    );
  }

}
