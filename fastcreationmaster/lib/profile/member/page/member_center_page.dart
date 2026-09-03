import 'dart:io';

import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/util/by_screen_utils.dart';
import 'package:fast_creation_master/core/widget/page/base_page.dart';
import 'package:fast_creation_master/core/widget/view/loading_dialog.dart';
import 'package:fast_creation_master/core/widget/view/svga_player.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:fast_creation_master/profile/member/dialog/member_pay_select_dialog.dart';
import 'package:fast_creation_master/profile/member/widget/member_contdown.dart';
import 'package:fast_creation_master/profile/member/widget/scale_transition_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fast_creation_master/profile/member/controller/member_center_controller.dart';

import '../../../core/controller/user_controller.dart';
import '../../../global/other/event_tracking/event_tracking.dart';

// ignore: must_be_immutable
class MemberCenterPage extends BasePage {
  MemberCenterPage({super.key});

  // final MemberCenterController controller = Get.put(MemberCenterController());
  final PageController _pageController = PageController();

  @override
  String get title => '会员中心';

  @override
  bool get hasAppBar => false;

  @override 
  MemberCenterController get controller => Get.find<MemberCenterController>();

  ///关闭按钮
  Widget _buildCloseButton() {
    return Positioned(
      top: ByScreenUtils.topSafeHeight,
      child: GestureDetector(
        onTap: () {
          controller.closePage();
        },
        child: Container(
          width: 48,
          height: 32,
          alignment: Alignment.center,
          child: Image.asset(
            'assets/profile/member/member_close_icon.png',
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }

  ///会员中心主体
  Widget _buildMemberCenterBody() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(
          height: 210,
        ),
        SizedBox(
          width: double.infinity,
          child: Stack(
            children: [
              Image.asset(
                'assets/profile/member/member_bg_6.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
              ),
              _buildTabTitle(),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -30),
          child: Container(
            color: ByColorUtil.colorBg1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  final itemCount = controller.newVipList.length;
                  if (itemCount == 0) {
                    return SizedBox(
                      height: 360.h,
                      child: const Center(
                          child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(ByColorUtil.colorC1),
                        strokeWidth: 2,
                      )),
                    );
                  }

                  final rowCount = itemCount;
                  return Container(
                    height: 122.0 * rowCount,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: controller.tabCurrentIndex.value == 0
                        ? _buildPayList()
                        : _buildWordList(),
                  );
                }),
                Obx(() {
                  return controller.newVipList.isNotEmpty ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ByWidgetsUtil.commonText(text: controller.newVipList[controller.selectedPackageIndex.value].illustrate,textColor: ByColorUtil.colorF2),
                ) : Container();
                }),
                SizedBox(height: 20.h),
                if (Platform.isAndroid) _buildPayWay(),
                _buildOther(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  ///tab标题切换
  Widget _buildTabTitle() {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 第一个Tab
          if (controller.tabCurrentIndex.value == 0)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: _buildTitleitem('VIP', 0),
              ),
            ),
          // // 分隔线
          // Container(
          //   width: 1,
          //   height: 16,
          //   color: ByColorUtil.color2E3038,
          //   margin: const EdgeInsets.symmetric(horizontal: 4),
          // ),
          // 第二个Tab
          if (controller.tabCurrentIndex.value == 1)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: _buildTitleitem('字数包', 1),
              ),
            ),
        ],
      );
    });
  }

  ///标题
  Widget _buildTitleitem(String title, int index) {
    bool selected = controller.tabCurrentIndex.value == index;
    Widget text = selected
        ? ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [
                  Color(0xFF82D7FF),
                  Color(0xFFBFE0FF),
                  Color(0xFFDCC8FF),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds);
            },
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                color: Colors.white,
              ),
            ),
          )
        : Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.normal,
            ),
          );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.transparent,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          text,
          if (selected)
            Image.asset(
              'assets/profile/member/member_bg_7.png',
              width: 26,
              height: 8,
              fit: BoxFit.contain,
            ),
        ],
      ),
    );
  }

  ///列表 label
  Widget _builditemLabel(vipTypeBean) {
    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        height: 18,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
          ),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              ByColorUtil.colorC1,
              Color(0xFFD7F97D),
            ],
            stops: [0.3818, 0.9963],
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          vipTypeBean.mark.isNotEmpty ? vipTypeBean.mark : "最多人选",
          style: const TextStyle(
            fontSize: 10,
            color: ByColorUtil.colorF8,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  ///会员支付列表
  Widget _buildPayItem(int index, String type) {
    final vipTypeBean = controller.newVipList[index];
    return GestureDetector(
      onTap: () {
        EventTracking.reportDataPoint(
            pageTag: 'member_page_product_btn',
            operateType: 'click',
            funcDetailTag: controller.landingPage,
            funcDetailImg: '',
            extra: {
              'pay_page_id': controller.pagePageID,
              'vip_id': controller.getPackageID()
            });
        controller.switchVipListCurrent(index);
      },
      child: Obx(() {
        final isSelected = controller.selectedPackageIndex.value == index;
        return Container(
          width: double.infinity,
          height: 104,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: AssetImage(
                  controller.getVipBackgroundImage2(isSelected, index, type)),
              fit: BoxFit.fill,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.styleManager.getPayTypeName(vipTypeBean, 1),
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: ByColorUtil.colorF1),
                          ),
                          Text(
                            vipTypeBean.des,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? ByColorUtil.colorF1
                                  : ByColorUtil.colorF2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: controller.styleManager.getPayTypeName(vipTypeBean, 3),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: ByColorUtil.colorF1,
                                  ),
                                ),
                                TextSpan(
                                  text: controller.styleManager.getPayTypeName(vipTypeBean, 4),
                                  style: const TextStyle(
                                      fontSize: 26,
                                      color: ByColorUtil.colorF1,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: controller.styleManager.getPayTypeName(vipTypeBean, 5),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: ByColorUtil.colorF1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '¥${vipTypeBean.crossedMoney}',
                            style: TextStyle(
                              fontSize: 12,
                              color: ByColorUtil.colorF1.withOpacity(0.45),
                              decoration: TextDecoration.lineThrough,
                              decorationColor: const Color(0xFFBAC7E0),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: double.infinity,
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      index == 0
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '限时优惠',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isSelected
                                        ? ByColorUtil.colorF7
                                        : ByColorUtil.colorF2,
                                  ),
                                ),
                                const MemberCountdown(),
                              ],
                            )
                          : const SizedBox.shrink(),
                      Text(
                        '≈${controller.styleManager.getPayTypeName(vipTypeBean, 2)} 变身头部作者',
                        style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? ByColorUtil.colorF7
                                : ByColorUtil.colorF2),
                      ),
                    ],
                  ),
                ),
              ),
              if (vipTypeBean.isDefault == 1) _builditemLabel(vipTypeBean),
            ],
          ),
        );
      }),
    );
  }

  ///字数包支付列表
  Widget _buildWordPackageItem(int index, String type) {
    final vipTypeBean = controller.payData.wordsPackageList[index];
    return GestureDetector(
      onTap: () {
        EventTracking.reportDataPoint(
            pageTag: 'member_page_product_btn',
            operateType: 'click',
            funcDetailTag: controller.landingPage,
            funcDetailImg: '',
            extra: {
              'pay_page_id': controller.pagePageID,
              'vip_id': controller.getPackageID()
            });
        controller.switchWordPackageListCurrent(index);
      },
      child: Obx(() {
        final isSelected = controller.selectedWordPackageIndex.value == index;
        return Container(
          width: double.infinity,
          height: 104,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: AssetImage(
                  controller.getVipBackgroundImage2(isSelected, index, type)),
              fit: BoxFit.fill,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vipTypeBean.title,
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: ByColorUtil.colorF1),
                          ),
                          Text(
                            vipTypeBean.desc,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? ByColorUtil.colorF1
                                  : ByColorUtil.colorF2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: '¥',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: ByColorUtil.colorF1,
                                  ),
                                ),
                                TextSpan(
                                  text: vipTypeBean.money,
                                  style: const TextStyle(
                                      fontSize: 26,
                                      color: ByColorUtil.colorF1,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '¥${vipTypeBean.crossedMoney}',
                            style: TextStyle(
                              fontSize: 12,
                              color: ByColorUtil.colorF1.withOpacity(0.45),
                              decoration: TextDecoration.lineThrough,
                              decorationColor: const Color(0xFFBAC7E0),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: double.infinity,
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      index == 0
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '限时优惠',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isSelected
                                        ? ByColorUtil.colorF7
                                        : ByColorUtil.colorF2,
                                  ),
                                ),
                                const MemberCountdown(),
                              ],
                            )
                          : const SizedBox.shrink(),
                      Text(
                        '变身头部作者',
                        style: TextStyle(
                            fontSize: 12,
                            color: isSelected
                                ? ByColorUtil.colorF7
                                : ByColorUtil.colorF2),
                      ),
                    ],
                  ),
                ),
              ),
              if (vipTypeBean.isDefault == 1) _builditemLabel(vipTypeBean),
            ],
          ),
        );
      }),
    );
  }

  ///会员支付列表
  Widget _buildPayList() {
    return Obx(() {
      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: List.generate(
            controller.newVipList.length,
            (index) => _buildPayItem(index, 'vip'),
          ),
        ),
      );
    });
  }

  ///字数包支付列表
  Widget _buildWordList() {
    return Obx(() {
      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: List.generate(
            controller.payData.wordsPackageList.length,
            (index) => _buildWordPackageItem(index, 'text'),
          ),
        ),
      );
    });
  }

  ///支付方式
  Widget _buildPayWay() {
    return Obx(() {
      final isVipList = controller.tabCurrentIndex.value == 0;
      final payList = isVipList
          ? controller.payMethodBeans
          : controller.wordPackagePayMethodBeans;
      final payIndex = isVipList
          ? controller.currentPayMethodIndex.value
          : controller.currentWordPackagePayMethodIndex.value;

      if (payList.isEmpty) {
        return const SizedBox.shrink();
      }

      if (payIndex >= payList.length) {
        return const SizedBox.shrink();
      }

      final payMethodBeans = payList[payIndex];

      return Padding(
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: GestureDetector(
          onTap: () {
            Get.bottomSheet(MemberPaySelectDialog(
              payList: payList,
              selectedIndex: payIndex,
            ));
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: ByColorUtil.colorBg2,
              border: Border.all(
                color: ByColorUtil.colorL1,
                width: 1,
              ),
            ),
            margin: const EdgeInsets.only(bottom: 32),
            height: 40,
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      payMethodBeans['icon'],
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      payMethodBeans['payName'] ?? '微信支付',
                      style: TextStyle(
                        fontSize: 15,
                        color: ByColorUtil.colorF1.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
                Image.asset(
                  'assets/profile/member/member_5.png',
                  width: 20,
                  height: 20,
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  ///其他
  Widget _buildOther() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          _buildOtherAvatar(),
          _buildOtherBuyNotice(),
        ],
      ),
    );
  }

  ///其他-头像
  Widget _buildOtherAvatar() {
    return Column(
      children: [
        Image.asset(
          'assets/profile/member/member_bg_9.png',
          width: double.infinity,
          height: 120,
          fit: BoxFit.fill,
        ),
        const SizedBox(height: 32),
        Image.asset(
          'assets/profile/member/member_bg_10.png',
          width: double.infinity,
          height: 460,
          fit: BoxFit.fill,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  ///其他-购买须知
  Widget _buildOtherBuyNotice() {
    return Obx(() {
      return controller.payData.inform.value.isNotEmpty ? SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            '购买须知',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ByColorUtil.colorF1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.payData.inform.value,
            style: TextStyle(
              fontSize: 12,
              height: 1.6,
              color: ByColorUtil.colorF2.withOpacity(0.65),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    ) : const SizedBox(height: 80);
    }); 
  }

  ///底部悬浮
  Widget _buildBottomFloating() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        width: double.infinity,
        color: ByColorUtil.colorBg1,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          children: [
            Obx(
              () {
                // 检查列表是否为空
                if (controller.newVipList.isEmpty) {
                  return const SizedBox.shrink();
                }

                // 检查索引是否有效
                if (controller.selectedPackageIndex.value >=
                            controller.newVipList.length) {
                  return const SizedBox.shrink();
                }

                return ScaleTransitionWidget(
                  child: GestureDetector(
                    onTap: () {
                      EventTracking.reportDataPoint(
                          pageTag: 'member_page_open_btn',
                          operateType: 'click',
                          funcDetailTag: controller.landingPage,
                          funcDetailImg: '',
                          extra: {
                            'pay_page_id': controller.pagePageID,
                            'vip_id': controller.getPackageID()
                          });
                      controller.packageBuy();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      // decoration: const BoxDecoration(
                      //   image: DecorationImage(
                      //     image: AssetImage(
                      //       'assets/profile/member/member_bg_4.png',
                      //     ),
                      //     fit: BoxFit.contain,
                      //   ),
                      // ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFF82D7FF),
                            Color(0xFFBFE0FF),
                            Color(0xFFDCC8FF),
                          ],
                          stops: [0.0, 0.30, 0.95],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF987CC8).withOpacity(0.3),
                            blurRadius: 17,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                controller.getPackageButtonText(),
                                style: const TextStyle(
                                  fontSize: 17,
                                  color: ByColorUtil.colorF7,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 6),
            _buildAgreement(),
          ],
        ),
      ),
    );
  }

  /// 协议
  Widget _buildAgreement() {
    return Obx(() {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          controller
              .agreementCheckedChanged(!controller.agreementChecked.value);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if(Get.find<UserController>().isAudit())
                Image.asset(
                  controller.agreementChecked.value
                      ? "assets/profile/member/member_2.png"
                      : "assets/profile/member/member_1.png",
                  height: 14,
                  width: 14,
                  fit: BoxFit.contain,
                ),
                Flexible(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: ' 我已阅读并同意',
                              style: TextStyle(
                                fontSize: 12,
                                color: ByColorUtil.colorF2,
                              ),
                            ),
                            if (controller.tabCurrentIndex.value == 0 &&
                                controller.newVipList.isNotEmpty &&
                                controller.selectedPackageIndex.value <
                                    controller.newVipList.length)
                              TextSpan(
                                text: "《会员服务协议与付费须知》",
                                style: const TextStyle(
                                  color: ByColorUtil.colorF1,
                                  fontSize: 12,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    if (controller.payData.vipPageBean?.user.protocolUrl
                                            .isEmpty ??
                                        true) return;
                                    ByNavRouterUtils.jumpWebViewPage(
                                        Get.context!,
                                        "会员服务协议与付费须知",
                                        controller.payData.vipPageBean?.user
                                                .protocolUrl ??
                                            "");
                                  },
                              ),
                            if (controller.tabCurrentIndex.value == 1)
                              TextSpan(
                                text: "《会员服务协议与付费须知》",
                                style: const TextStyle(
                                  color: ByColorUtil.colorF1,
                                  fontSize: 12,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    if (controller.payData.wordsPackIllustrate ==
                                            null ||
                                        controller.payData
                                            .wordsPackIllustrate!.isEmpty) {
                                      return;
                                    }
                                    ByNavRouterUtils.jumpWebViewPage(
                                        Get.context!,
                                        "会员服务协议与付费须知",
                                        controller.payData.wordsPackIllustrate ?? "");
                                  },
                              ),
                            if (controller.tabCurrentIndex.value == 0 &&
                                controller.newVipList.isNotEmpty &&
                                controller.selectedPackageIndex.value <
                                    controller.newVipList.length &&
                                controller
                                        .newVipList[controller
                                            .selectedPackageIndex.value]
                                        .isSubscribe ==
                                    1)
                              TextSpan(
                                text: "《自动续费服务协议》",
                                style: const TextStyle(
                                  color: ByColorUtil.colorF1,
                                  fontSize: 12,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    if (controller.payData.vipPageBean?.user
                                            .subScribeProtocolUrl.isEmpty ??
                                        true) return;
                                    ByNavRouterUtils.jumpWebViewPage(
                                        Get.context!,
                                        "自动续费服务协议",
                                        controller.payData.vipPageBean?.user
                                                .subScribeProtocolUrl ??
                                            "");
                                  },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget buildBody(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        controller.closePage();
      },
      child: Stack(
        children: [
          Container(
            color: ByColorUtil.colorBg1,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    'assets/profile/member/member_bg_1.png',
                    height: 308,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                const Positioned(
                  top: 40,
                  height: 164,
                  width: 375,
                  child: SvgaPlayer(
                    url:  'assets/business/svg_member_center_top.svga',
                    isRepeat: true,
                    fit: BoxFit.cover,
                  ),
                ),
                _buildMemberCenterBody(),
                _buildBottomFloating(),
                _buildCloseButton(),
              ],
            ),
          ),
          Obx(() {
            if (controller.isLoading.value) {
              return Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: LoadingView(loadingText: controller.loadingText.value,)
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
