

import 'dart:io';
import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:byhy_app_common_utils/app_ui/byhy_screen_utils.dart';
import 'package:fast_creation_master/core/widget/page/base_page.dart';
import 'package:fast_creation_master/core/widget/view/by_button.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:fast_creation_master/profile/member/dialog/member_pay_select_dialog.dart';
import 'package:fast_creation_master/profile/member/widget/scale_transition_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fast_creation_master/profile/member/controller/member_center_controller.dart';

import '../../../core/widget/view/loading_dialog.dart';
import '../../../core/widget/view/svga_player.dart';
import '../../../global/other/event_tracking/event_tracking.dart';

// ignore: must_be_immutable
class MemberWordsPackagePage extends BasePage {
  MemberWordsPackagePage({
    super.key,
    this.isBackHome = false,
    this.showSKUDialog = false,
    this.source = 'unknown',
    this.isWordsEmpty = true});

  final bool? isWordsEmpty;
  final bool? isBackHome;
  final bool? showSKUDialog;
  final String? source;

  @override
  String get title => '会员中心';

  @override
  bool get hasAppBar => false;

  @override 
  MemberCenterController get controller => Get.put(MemberCenterController(isBackHome: isBackHome!, showSKUDialog: showSKUDialog, source: source!));

  ///关闭按钮
  Widget _buildCloseButton() {
    return Positioned(
      top: 12,
      right: 0,
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
    return Column(
      children: [
        SizedBox(
          height: 196.w,
        ),
        Container(
            color: ByColorUtil.colorBg1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  final itemCount = controller.payData.wordsPackageList.length;
                  if (itemCount == 0) {
                    return SizedBox(
                      height: 160.h,
                      child: const Center(
                          child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(ByColorUtil.colorC1),
                        strokeWidth: 2,
                      )),
                    );
                  }

                  final rowCount = (itemCount / 3).ceil();
                  return Container(
                    height: 160.h * rowCount,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: _buildWordList(),
                  );
                }),
                SizedBox(height: 10.h),
                if (Platform.isAndroid) _buildPayWay(),
                _buildOther(),
                _buildBottomFloating(),
                SizedBox(height: ByScreenUtils.bottomSafeHeight,),
              ],
            ),
          ),
      ],
    );
  }

  ///字数包支付列表item
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
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: AssetImage(
                  controller.getVipBackgroundImage(isSelected, index, type)),
              fit: BoxFit.fill,
            ),
          ),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.only(
                  top: 24.h,
                  left: 12.w,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vipTypeBean.title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: ByColorUtil.colorF1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: '¥',
                            style: TextStyle(
                              fontSize: 15,
                              color: ByColorUtil.colorF1,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: vipTypeBean.money,
                            style: const TextStyle(
                              fontSize: 26,
                              color: ByColorUtil.colorF1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4.h),
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
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 25,
                  alignment: Alignment.center,
                  child: Text(
                    vipTypeBean.desc,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? ByColorUtil.colorF7
                          : ByColorUtil.colorF2,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
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

  ///字数包支付列表
  Widget _buildWordList() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      clipBehavior: Clip.none,
      shrinkWrap: true,
      itemCount: controller.payData.wordsPackageList.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 112 / 148,
      ),
      itemBuilder: (context, index) {
        return _buildWordPackageItem(index, 'Word');
      },
    );
  }

  ///支付方式
  Widget _buildPayWay() {
    return Obx(() {
      final payList = controller.wordPackagePayMethodBeans;
      final payIndex = controller.currentWordPackagePayMethodIndex.value;

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
      child: Image.asset(
          'assets/profile/member/member_bg_8.png',
          width: double.infinity,
          height: 65,
          fit: BoxFit.contain,
        ),
    );
  }
  ///底部悬浮
  Widget _buildBottomFloating() {
    return Container(
          width: double.infinity,
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            children: [
              Obx(
                () {
                  // 检查列表是否为空
                  if (controller.payData.wordsPackageList.isEmpty) {
                    return const SizedBox.shrink();
                  }
      
                  // 检查索引是否有效
                  if (controller.selectedWordPackageIndex.value >=
                              controller.payData.wordsPackageList.length) {
                    return const SizedBox.shrink();
                  }
      
                  return ScaleTransitionWidget(
                    child: ByButton.gradientBtn(
                      textColor: Colors.black,
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
                      title: controller.getPackageButtonText(),
                      onClick: () {
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
                    },),
                  );
                },
              ),
              const SizedBox(height: 6),
              _buildAgreement(),
            ],
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: buildBody(context),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        controller.closePage();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: ByColorUtil.colorBg1,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Image.asset(
                          'assets/business/member_words_package_bg.png',
                          height: 196.w,
                          width: 375.w,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        height: 196.w,
                        width: 375.w,
                        child: !isWordsEmpty! ? const SvgaPlayer(
                          url: 'assets/business/svg_member_words_top.svga',
                          isRepeat: true,
                          fit: BoxFit.cover,
                        ) : Image.asset(
                          'assets/business/icon_member_center_words_top.png',
                          height: 196.w,
                          width: 375.w,
                          fit: BoxFit.fitHeight,)
                      ),
                      _buildMemberCenterBody(),
                      _buildCloseButton(),
                    ],
                  ),
                ),
              ),
              Obx(() {
                if (controller.isLoading.value) {
                  return Positioned(
                    top: 200.w,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.transparent,
                      child: Center(
                        child: LoadingView(loadingText: controller.loadingText.value,),
                    )),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ],
      ),
    );
  }
}
