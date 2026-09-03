import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wechat_kit/wechat_kit.dart';

import '../global/other/event_tracking/event_tracking.dart';

class AddWechatDialog extends StatelessWidget {
  final String wechatUrl;
  AddWechatDialog({
    super.key,
    required this.wechatUrl,
  });

  ///获取用户信息
  final UserController userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    String addWechatBgUrl = Get.find<UserController>().addWechatBgUrl;

    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              ClipRRect(
                child: CachedNetworkImage(
                  imageUrl: addWechatBgUrl,
                  width: 339.w,
                  height: 603.w,
                ),
              ),
              Positioned(
                  bottom: 20.w,
                  left: 85.w,
                  child: GestureDetector(
                    onTap: () {
                      ///todo 添加运营微信

                      // ByNavRouterUtils.jumpWebViewPage(
                      //     Get.context!, "微信客服", wechatUrl);
                      EventTracking.reportDataPoint(
                        pageTag: 'guide_page_add_teacher_add_btn',
                        operateType: 'click',
                        funcDetailImg: '',
                        funcDetailTag: '',
                      );
                      Get.back();
                      userController.checkPreLogin(
                          source: 'square_guide',
                          actionCallback: () {
                            if (userController.userInfoBean.value?.isVip == 0) {
                              userController.jumpToPayPage(
                                  source: 'square_guide');
                            } else {
                              ByNavRouterUtils.jumpWebViewPage(
                                  Get.context!, "微信客服", wechatUrl);
                            }
                          });

                      // WechatKitPlatform.instance.openUrl(url: "https://work.weixin.qq.com/kfid/kfc82d5c9ac8e3d01dc?enc_scene=ENCjkfvLdKxbuPt2eq3oEgBx&scene_param=__USER_ID__", );
                    },
                    child: Container(
                      width: 170.0.w,
                      height: 44.0.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF98FC4A), // #98FC4A
                            Color(0xFFD7F97D), // #D7F97D
                          ],
                          stops: [0.38, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(22.0.w),
                      ),
                      child: Text(
                        "添加老师",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                            color: Color(0XFF0F0F12)),
                      ),
                    ),
                  )),
              Positioned(
                right: 12.w,
                top: 10.w,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    EventTracking.reportDataPoint(
                        pageTag: 'guide_page_add_teacher_close_btn',
                        operateType: 'click',
                        funcDetailImg: '',
                        funcDetailTag: '',
                      );
                    Get.back();
                  },
                  child: Container(
                      width: 30.w,
                      height: 30.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: const Color(0XFF1e1f24).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(7.w)),
                      child: Image.asset(
                        "assets/global/common/btn_close.png",
                        width: 25.w,
                        height: 25.w,
                      )),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
