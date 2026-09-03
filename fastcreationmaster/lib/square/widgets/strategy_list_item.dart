import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:fast_creation_master/square/beans/strategy_list_bean.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class StrategyListItem extends StatelessWidget {
  final StrategyListBean strategy;
  final VoidCallback? onTap;

  const StrategyListItem({
    super.key,
    required this.strategy,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: ByColorUtil.colorBg1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ByColorUtil.colorF1.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.network(
                      strategy.iconUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          color: ByColorUtil.colorBg2,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: double.infinity,
                          height: 200,
                          color: ByColorUtil.colorBg2,
                          child: const Center(
                              child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                ByColorUtil.colorC1),
                            strokeWidth: 2,
                          )),
                        );
                      },
                    ),
                  ),
                  if (strategy.isFree == 2)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Image.asset(
                        'assets/square/square_2.png',
                        width: 52,
                        height: 18,
                        fit: BoxFit.contain,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              child: Row(
                children: [
                  if (strategy.isFree == 2)
                    Image.asset(
                      'assets/square/square_1.png',
                      width: 32,
                      height: 18,
                      fit: BoxFit.contain,
                    ),
                  if (strategy.isFree == 2) const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      strategy.describe,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: ByColorUtil.colorF1,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StrategyListItemEx extends StatelessWidget {
  final StrategyListBean strategy;
  final VoidCallback? onTap;
  final String? type;
  const StrategyListItemEx({
    super.key,
    required this.strategy,
    this.onTap,
    this.type,
  });

  @override
  Widget build(BuildContext context) {
    if (type == "xi_lie_ke") {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 100.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: ByColorUtil.colorBg2,
          ),
          margin: EdgeInsets.only(bottom: 12.w),
          child: Row(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(24),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: strategy.iconUrl,
                      width: 100.w,
                      height: 100.w,
                      fit: BoxFit.fill,
                    ),
                  ),
                  if (strategy.isFree == 2)
                    Positioned(
                        right: 0,
                        child: Image.asset(
                          "assets/square/vip_exclusive.png",
                          width: 52.w,
                          height: 18.w,
                        ))
                ],
              ),
              const SizedBox(
                width: 12,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 230.w,
                    child: ByWidgetsUtil.commonText(
                        text: strategy.name,
                        fontSize: 15.sp,
                        textColor: ByColorUtil.colorF1,
                        maxLines: 1),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        'assets/square/icon_square_date_clock.png',
                        width: 12,
                        height: 12,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      ByWidgetsUtil.commonText(
                          text: strategy.createdAt,
                          fontSize: 12.sp,
                          textColor: ByColorUtil.colorF2,
                          maxLines: 1),
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20.w),
                        child: CachedNetworkImage(
                          imageUrl: strategy.authorAvatar,
                          width: 20.w,
                          height: 20.w,
                        ),
                      ),
                      SizedBox(
                        width: 6.w,
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 130.w),
                        child: ByWidgetsUtil.commonText(
                            text: strategy.authorName,
                            textColor: ByColorUtil.colorF2,
                            maxLines: 1),
                      ),
                      SizedBox(
                        width: 10.w,
                      ),
                      InkResponse(
                        onTap: () {
                          // Get.dialog(AddWechatDialog(
                          //   wechatUrl: strategy.wechat,
                          // ));
                          final userController = Get.find<UserController>();
                          userController.checkPreLogin(
                              source: 'square',
                              actionCallback: () {
                                if (userController.userInfoBean.value?.isVip ==
                                    0) {
                                  userController.jumpToPayPage(
                                      source: 'square');
                                } else {
                                  ByNavRouterUtils.jumpWebViewPage(
                                      Get.context!, "微信客服", strategy.wechat);
                                }
                              });
                        },
                        child: Container(
                          width: 68.w,
                          height: 22.h,
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0XFF98FC4A)),
                            borderRadius: BorderRadius.circular(15.w),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "添加老师",
                            style: TextStyle(
                              color: Color(0XFF98FC4A),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: ByColorUtil.colorBg1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ByColorUtil.colorF1.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.network(
                      strategy.iconUrl,
                      width: double.infinity,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 140,
                          color: ByColorUtil.colorBg2,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: double.infinity,
                          height: 140,
                          color: ByColorUtil.colorBg2,
                          child: const Center(
                              child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                ByColorUtil.colorC1),
                            strokeWidth: 2,
                          )),
                        );
                      },
                    ),
                  ),
                  if (strategy.isFree == 2)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Image.asset(
                        'assets/square/square_2.png',
                        width: 52,
                        height: 18,
                        fit: BoxFit.contain,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              child: Row(
                children: [
                  if (strategy.isFree == 2)
                    Image.asset(
                      'assets/square/square_1.png',
                      width: 32,
                      height: 18,
                      fit: BoxFit.contain,
                    ),
                  if (strategy.isFree == 2) const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      strategy.describe,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: ByColorUtil.colorF1,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(
                    width: 6.w,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.w),
                    child: CachedNetworkImage(
                      imageUrl: strategy.authorAvatar,
                      width: 20.w,
                      height: 20.w,
                    ),
                  ),
                  SizedBox(
                    width: 6.w,
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 100.w),
                    child: ByWidgetsUtil.commonText(
                        text: strategy.authorName,
                        textColor: ByColorUtil.colorF2,
                        maxLines: 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
