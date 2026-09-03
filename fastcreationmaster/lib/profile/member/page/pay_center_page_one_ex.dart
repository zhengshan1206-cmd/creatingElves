import 'dart:io';
import 'dart:math';

import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fast_creation_master/core/util/by_screen_utils.dart';
import 'package:fast_creation_master/core/widget/page/base_page.dart';
import 'package:fast_creation_master/core/widget/view/loading_dialog.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:fast_creation_master/profile/member/beans/vip_page_bean.dart';
import 'package:fast_creation_master/profile/member/dialog/member_pay_select_dialog.dart';
import 'package:fast_creation_master/profile/member/widget/scale_transition_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:get/get.dart';
import 'package:fast_creation_master/profile/member/controller/member_center_controller.dart';
import '../../../core/controller/user_controller.dart';
import '../../../global/other/event_tracking/event_tracking.dart';
import '../beans/pop_config_bean.dart';
import '../beans/user_info_bean.dart';
import '../dialog/member_retain_dialog.dart';

// ignore: must_be_immutable
class PayCenterPageOneEx extends BasePage {
  PayCenterPageOneEx({super.key});

  @override
  bool get hasAppBar => false;

  @override
  MemberCenterController get controller => Get.find<MemberCenterController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColorUtil.colorBg1,
      appBar: hasAppBar ? buildAppBar(context) : null,
      body: buildBody(context),
    );
  }

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
    Get.log("===横竖type=== ${controller.styleManager.type}");
    Get.log("===页面样式style=== ${controller.styleManager.style}");

    int style = controller.styleManager.style;
    double height1 = 394.w;
    if (controller.styleManager.type == 0) {
      if (style == 4 || style == 5) {
        height1 = 394.w;
      }
    }

    return Positioned(
      bottom: controller.styleManager.type == 0
          ? 200.w + 100 + ByScreenUtils.bottomSafeHeight
          : 80 + ByScreenUtils.bottomSafeHeight,
      left: 0,
      right: 0,
      top: 0,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ///头图
          _headerView(height1: height1),
          if (controller.styleManager.type != 0) _buildPayContentView(),
          Obx(() => ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: controller.payData.operationList.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return _buildCaseView(index);
                },
              )),
          // ),
          SizedBox(
            height: 30.w,
          )
        ],
      ),
    );
  }

  ///下方案例、说明
  Widget _buildCaseView(int index) {
    VipOperationBean bean = controller.payData.operationList[index];
    int style = controller.styleManager.style;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
      color: (style == 3 || style == 4)
          ? const Color(0xFFF6F6F6)
          : ByColorUtil.colorBg1,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/business/icon_pay_center_decoration${(style == 3 || style == 4) ? '_black' : ''}.png',
                width: 36.w,
                height: 12.w,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 4.w),
              Container(
                constraints: BoxConstraints(maxWidth: 250.w),
                child: ByWidgetsUtil.commonText(
                  text: bean.title,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  textColor: (style == 3 || style == 4)
                      ? ByColorUtil.colorF7
                      : ByColorUtil.colorF1,
                ),
              ),
              SizedBox(width: 4.w),
              Transform.rotate(
                angle: pi,
                child: Image.asset(
                  'assets/business/icon_pay_center_decoration${(style == 3 || style == 4) ? '_black' : ''}.png',
                  width: 36.w,
                  height: 12.w,
                  fit: BoxFit.contain,
                ),
              )
            ],
          ),
          ByWidgetsUtil.commonText(
            text: bean.subTitle,
            fontSize: 13.sp,
            textColor: (style == 3 || style == 4)
                ? ByColorUtil.colorF2
                : ByColorUtil.colorF1,
          ),
          SizedBox(height: 4.w),
          SizedBox(height: 8.w),
          for (String pic in bean.pics)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.w),
                child: Image.network(
                  pic,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
        ],
      ),
    );
  }

  ///付费主体
  Widget _buildPayContentView() {
    int style = controller.styleManager.style;
    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          Container(
            color: (style == 3 || style == 4)
                ? const Color(0xFFF6F6F6)
                : ByColorUtil.colorBg1,
            child: Column(
              children: [
                SizedBox(height: 6.w,),
                // controller.styleManager.payContentTitleBgWidget(),
                // controller.styleManager
                //     .payContentTitleWidget(controller: controller),
                Container(
                  color: (style == 3 || style == 4)
                      ? const Color(0xFFF6F6F6)
                      : ByColorUtil.colorBg1,
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  ByColorUtil.colorC1),
                              strokeWidth: 2,
                            )),
                          );
                        }

                        final rowCount = itemCount;
                        return Container(
                          height: controller.styleManager.type == 0
                              ? 128.w
                              : 81.w * rowCount,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: controller.styleManager.type == 0
                              ? _buildVerticalPayList()
                              : _buildPayList(),
                        );
                      }),
                      // Obx(() {
                      //   return controller.newVipList.isNotEmpty
                      //       ? Padding(
                      //           padding: const EdgeInsets.symmetric(horizontal: 12),
                      //           child: ByWidgetsUtil.commonText(
                      //               text: controller
                      //                   .newVipList[
                      //                       controller.selectedPackageIndex.value]
                      //                   .illustrate,
                      //               textColor: ByColorUtil.colorF2),
                      //         )
                      //       : Container();
                      // }),
                      SizedBox(height: 12.w),
                      if (Platform.isAndroid) _buildPayWay(),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  ///列表 label
  Widget _builditemLabel(vipTypeBean) {
    Get.log("配置的vipmark== ${vipTypeBean.mark}");

    int style = controller.styleManager.style;
    int type = controller.styleManager.type;
    String deMarkString = "最多人选";
    if (style == 4 || style == 5) {
      if (type == 1) {
        deMarkString = "最多用户选择";
      } else {
        deMarkString = "最多选择";
      }
    }

    return Positioned(
      top: 0,
      left: (style == 4 || style == 5) ? null : 0,
      right: (style == 4 || style == 5) ? 0 : null,
      child: (style == 4 || style == 5)
          ? Transform.translate(
              offset: Offset(10.w, -12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    type == 1
                        ? "assets/business/icon_new_hot.png"
                        : "assets/business/icon_new_hot_small.png",
                    width: type == 1 ? 104.w : 80.w,
                    height: 24.w,
                  ),
                  Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(left: 10.w, bottom: 1.w),
                        child: Text(
                          vipTypeBean.mark.isNotEmpty
                              ? vipTypeBean.mark
                              : deMarkString,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: ByColorUtil.colorF1,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ))
                ],
              ),
            )
          : Transform.translate(
              offset: const Offset(-2, -12),
              child: Container(
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    topLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      ByColorUtil.colorG4,
                      Color(0xFFFF9A81),
                    ],
                    stops: [0.3818, 0.9963],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  vipTypeBean.mark.isNotEmpty ? vipTypeBean.mark : deMarkString,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: ByColorUtil.colorF1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
    );
  }

  ///会员支付列表
  Widget _buildVerticalPayList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      itemCount: controller.newVipList.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return _buildVerticalPayItem(index, 'vip');
      },
    );
  }

  ///会员支付列表item
  Widget _buildVerticalPayItem(int index, String payType) {
    final vipTypeBean = controller.newVipList[index];
    int style = controller.styleManager.style;
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
          width: controller.newVipList.length <= 2 ? 167.w : 118.w,
          height: 128.w,
          margin: EdgeInsets.only(right: 8.w),
          decoration: isSelected
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.transparent,
                    width: 2,
                  ),
                  gradient: controller.styleManager.style == 1
                      ? const LinearGradient(colors: [
                          Color(0xFFC4B7FA),
                          Color(0xFFDCC7FF),
                          Color(0xFFF6C8FF)
                        ])
                      : const LinearGradient(
                          colors: [Color(0xFFFD7A54), Color(0xFFEFAC9A)]))
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: (style == 3 || style == 4)
                        ? const Color(0xFFDFDFDF)
                        : ByColorUtil.colorL1,
                    width: 2,
                  ),
                ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 24.w,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: isSelected
                      ? BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                          gradient: controller.styleManager.style == 1
                              ? const LinearGradient(colors: [
                                  Color(0xFF5840B6),
                                  Color(0xFF825DB6)
                                ])
                              : const LinearGradient(colors: [
                                  Color(0xFFFFF0EC),
                                  Color(0xFFFFF0EC),
                                ]))
                      : BoxDecoration(
                          color: (style == 3 || style == 4)
                              ? ByColorUtil.colorF1
                              : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10)),
                        ),
                  padding: EdgeInsets.only(top: 24.w, left: 4.w, right: 4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        controller.styleManager.getPayTypeName(vipTypeBean, 1),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontFamily: 'AlimamaShuHeiTi',
                          color:
                              controller.styleManager.style != 1 && isSelected
                                  ? const Color(0xFF8D5F52)
                                  : (style == 3 || style == 4)
                                      ? ByColorUtil.colorF2
                                      : ByColorUtil.colorF1.withOpacity(0.6),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: controller.styleManager
                                  .getPayTypeName(vipTypeBean, 3),
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: controller.styleManager.style != 1 &&
                                        isSelected
                                    ? ByColorUtil.colorG4
                                    : (style == 3 || style == 4)
                                        ? ByColorUtil.colorF2
                                        : ByColorUtil.colorF1,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: controller.styleManager
                                  .getPayTypeName(vipTypeBean, 4),
                              style: TextStyle(
                                fontSize: 26.sp,
                                color: controller.styleManager.style != 1 &&
                                        isSelected
                                    ? ByColorUtil.colorG4
                                    : (style == 3 || style == 4)
                                        ? ByColorUtil.colorF2
                                        : ByColorUtil.colorF1,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: controller.styleManager
                                  .getPayTypeName(vipTypeBean, 5),
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: controller.styleManager.style != 1 &&
                                        isSelected
                                    ? ByColorUtil.colorG4
                                    : (style == 3 || style == 4)
                                        ? ByColorUtil.colorF2
                                        : ByColorUtil.colorF1,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 24.w,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                    color: isSelected
                        ? Colors.transparent
                        : (style == 3 || style == 4)
                            ? const Color(0xFFF2F6F7)
                            : ByColorUtil.colorBg2,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    controller.styleManager.getPayTypeName(vipTypeBean, 2),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isSelected && controller.styleManager.style != 1
                          ? ByColorUtil.colorF1
                          : isSelected
                              ? Colors.black
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

  ///会员支付列表
  Widget _buildPayItem(int index, String payType) {
    final vipTypeBean = controller.newVipList[index];
    int style = controller.styleManager.style;
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
        return Padding(
          padding: EdgeInsets.only(bottom: 5.w),
          child: Container(
            height: 76.w,
            decoration: isSelected
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04), // 阴影颜色（带透明度）
                        spreadRadius: 5, // 阴影扩散半径
                        blurRadius: 6, // 阴影模糊半径
                        offset: const Offset(0, 2), // 阴影偏移量（x: 水平偏移, y: 垂直偏移）
                      ),
                    ],
                    border: Border.all(
                      color: Colors.transparent,
                      width: 2,
                    ),
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/business/icon_pay_center_vip_selected_${controller.styleManager.style == 1 ? '1' : '2'}.png'),
                      fit: BoxFit.fill,
                    ),
                  )
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: (style == 3 || style == 4)
                        ? ByColorUtil.colorF1
                        : Colors.transparent,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04), // 阴影颜色（带透明度）
                        spreadRadius: 5, // 阴影扩散半径
                        blurRadius: 6, // 阴影模糊半径
                        offset: const Offset(0, 2), // 阴影偏移量（x: 水平偏移, y: 垂直偏移）
                      ),
                    ],
                    border: Border.all(
                      color: (style == 3 || style == 4)
                          ? Colors.transparent
                          : ByColorUtil.colorL1,
                      width: 2,
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
                    padding: EdgeInsets.only(top: 9.w, left: 16, right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ///标题位
                              controller.styleManager
                                  .getPayTypeName(vipTypeBean, 1),
                              style: TextStyle(
                                  fontSize: 21.sp,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      (!isSelected && style != 3 && style != 4)
                                          ? ByColorUtil.colorF1
                                          : Colors.black),
                            ),
                            Text(
                              vipTypeBean.des,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: isSelected
                                    ? Colors.black
                                    : ByColorUtil.colorF2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),


                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: controller.styleManager
                                        .getPayTypeName(vipTypeBean, 3),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: isSelected
                                          ? ByColorUtil.colorG4
                                          : (style == 3 || style == 4)
                                              ? const Color(0xFF797A78)
                                              : ByColorUtil.colorF1
                                                  .withOpacity(0.8),
                                    ),
                                  ),
                                  TextSpan(
                                    text: controller.styleManager
                                        .getPayTypeName(vipTypeBean, 4),
                                    style: TextStyle(
                                        fontSize: 26.sp,
                                        color: isSelected
                                            ? ByColorUtil.colorG4
                                            : (style == 3 || style == 4)
                                                ? const Color(0xFF797A78)
                                                : ByColorUtil.colorF1
                                                    .withOpacity(0.8),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: controller.styleManager
                                        .getPayTypeName(vipTypeBean, 5),
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      color: isSelected
                                          ? ByColorUtil.colorG4
                                          : (style == 3 || style == 4)
                                              ? const Color(0xFF797A78)
                                              : ByColorUtil.colorF1
                                                  .withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),


                            Text(
                              controller.styleManager
                                  .getPayTypeName(vipTypeBean, 2),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: isSelected
                                    ? ByColorUtil.colorG4
                                    : (style == 3 || style == 4)
                                        ? const Color(0xFF797A78)
                                        : ByColorUtil.colorF1.withOpacity(0.8),
                              ),
                            ),
                          ],
                        )


                      ],
                    ),
                  ),
                ),
                if (vipTypeBean.isDefault == 1) _builditemLabel(vipTypeBean),
              ],
            ),
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

  ///支付方式
  Widget _buildPayWay() {
    int style = controller.styleManager.style;

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
              color: (style == 3 || style == 4)
                  ? ByColorUtil.colorF1
                  : ByColorUtil.colorBg2,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04), // 阴影颜色（带透明度）
                  spreadRadius: 5, // 阴影扩散半径
                  blurRadius: 6, // 阴影模糊半径
                  offset: const Offset(0, 2), // 阴影偏移量（x: 水平偏移, y: 垂直偏移）
                ),
              ],
              border: (style != 3 && style != 4)
                  ? Border.all(
                      color: ByColorUtil.colorL1,
                      width: 1,
                    )
                  : null,
            ),
            margin: const EdgeInsets.only(bottom: 12),
            height: 40.w,
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
                    const SizedBox(width: 8),
                    Text(
                      payMethodBeans['payName'] ?? '微信支付',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: (style == 3 || style == 4)
                            ? ByColorUtil.colorF2
                            : ByColorUtil.colorF1.withOpacity(0.65),
                      ),
                    ),
                  ],
                ),
                Image.asset(
                  (style == 3 || style == 4)
                      ? 'assets/business/icon_pay_center_switch_gray.png'
                      : 'assets/profile/member/member_5.png',
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

  ///底部悬浮
  Widget _buildBottomFloating() {
    int style = controller.styleManager.style;
    bool showNewUser = false;
    UserInfoBean? userInfoBean = controller.userInfo.value;
    if (style == 4 || style == 5) {
      if (userInfoBean != null) {
        if (userInfoBean.activeDay != null) {
          if (userInfoBean.activeDay! <= 1) {
            showNewUser = true;
          }
        }
      }
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 100 + ByScreenUtils.bottomSafeHeight,
      child: Container(
        width: double.infinity,
        color: (style == 3 || style == 4)
            ? const Color(0xFFF6F6F6)
            : ByColorUtil.colorBg1,
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
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 52,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                    'assets/business/icon_pay_center_pay.png'),
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      controller.getPackageButtonText(),
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontFamily: 'AlimamaShuHeiTi',
                                        color: ByColorUtil.colorF1,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (showNewUser)
                            Positioned(
                                right: 10.w,
                                top: -6.w,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/business/icon_new_user.png",
                                      width: 76.w,
                                      height: 26.w,
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "新用户专享",
                                        style: TextStyle(
                                            color: const Color(0XFF162408),
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ))
                        ],
                      )),
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
    int style = controller.styleManager.style;

    return Obx(() {
      final itemCount = controller.newVipList.length;
      if (itemCount == 0) {
        return Container();
      }
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
                      : (style == 3 || style == 4)
                          ? 'assets/global/common/btn_checkbox_normal_black.png'
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
                              text: ' 阅读并同意',
                              style: TextStyle(
                                fontSize: 12,
                                color: ByColorUtil.colorF2,
                              ),
                            ),
                            if (controller.newVipList.isNotEmpty &&
                                controller.selectedPackageIndex.value <
                                    controller.newVipList.length)
                              TextSpan(
                                text: "会员付费协议",
                                style: TextStyle(
                                  color: (style == 3 || style == 4)
                                      ? ByColorUtil.colorF7
                                      : ByColorUtil.colorF1,
                                  fontSize: 12.sp,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    if (controller.payData.vipPageBean?.user
                                            .protocolUrl.isEmpty ??
                                        true) return;
                                    ByNavRouterUtils.jumpWebViewPage(
                                        Get.context!,
                                        "会员服务协议与付费须知",
                                        controller.payData.vipPageBean?.user
                                                .protocolUrl ??
                                            "");
                                  },
                              ),
                            if (controller.newVipList.isNotEmpty &&
                                controller.selectedPackageIndex.value <
                                    controller.newVipList.length &&
                                controller
                                        .payData
                                        .vipList[controller
                                            .selectedPackageIndex.value]
                                        .isSubscribe ==
                                    1)
                              TextSpan(
                                text: "、自动续费服务协议",
                                style: TextStyle(
                                  color: (style == 3 || style == 4)
                                      ? ByColorUtil.colorF7
                                      : ByColorUtil.colorF1,
                                  fontSize: 12.sp,
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

  ///付费页面头图
  Widget _headerView({
    required double height1,
  }) {
    return SizedBox(
      width: 1.sw,
      height: height1,
      child: _buildBannerView(height1: height1),
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
      child: Stack(
        children: [
          Container(
            color: (controller.styleManager.style == 3 ||
                    controller.styleManager.style == 4)
                ? const Color(0xFFF6F6F6)
                : Colors.transparent,
            child: Stack(
              children: [
                _buildMemberCenterBody(),
                _buildBottomFloating(),
                if (controller.styleManager.type == 0)
                  Positioned(
                      left: 0,
                      right: 0,
                      bottom: 100 + ByScreenUtils.bottomSafeHeight,
                      child: _buildPayContentView()),
                _buildCloseButton(),
              ],
            ),
          ),

          Obx(() {
            if(controller.popConfigList.isEmpty || !controller.showRetainDialog.value) {
              return Container();
            } else {
              PopConfigBean bean = controller.popConfigList.first;
              return Container(
                color: ByColorUtil.colorF8.withValues(alpha: 0.7),
                child: MemberRetainDialog(
                  mode: bean.popType == 1 ? 1 : 2,
                  type: MemberRetainType.createBig_11_0_5,
                  confirm: () {
                    controller.retainPayStart();
                  },
                  close: () {
                    controller.closeRetainDialog();
                  },
                ),
              );
            }
          }),
          Obx(() {
            if (controller.isLoading.value) {
              return Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                    child: LoadingView(
                  loadingText: controller.loadingText.value,
                )),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  ///Vip轮播区域
  Widget _buildBannerView({
    required double height1,
  }) {

    RxList<String> vipPageTopDataList =  Get.find<MemberCenterController>().vipPageTopDataList;
    // List<String> menuItemBeans = [];
    // if(vipPageTopDataList.isNotEmpty){
    //   menuItemBeans.addAll(vipPageTopDataList);
    // }


    return  Obx(()=>  Swiper(
      autoplay: true,
      itemCount: vipPageTopDataList.length,
      // controller: controller,
      itemBuilder: (context, index) {

        Get.log("===当前的轮播图===${vipPageTopDataList[index]}");
        return CachedNetworkImage(
          imageUrl: vipPageTopDataList[index],
          width: 1.sw,
          height:height1,
          fit: BoxFit.fill,
        );
      },
      // pagination: SwiperPagination(
      //   margin: EdgeInsets.zero,
      //   builder: SwiperCustomPagination(
      //     builder:
      //         (BuildContext context, SwiperPluginConfig config) {
      //       return Container(
      //         margin: EdgeInsets.only(bottom: 80.w, left: 8.w),
      //         child: Row(
      //           mainAxisAlignment: MainAxisAlignment.start,
      //           children:
      //               List.generate(menuItemBeans.length, (index) {
      //             final isCurrent = index == config.activeIndex;
      //             return Container(
      //               width: isCurrent ? 12.h : 6.w,
      //               height: 3.w,
      //               decoration: BoxDecoration(
      //                 color: isCurrent
      //                     ? Colors.white
      //                     : Colors.grey.withOpacity(0.4),
      //                 borderRadius: BorderRadius.circular(1.5.w),
      //               ),
      //               margin: EdgeInsets.symmetric(horizontal: 3.w),
      //             );
      //           }),
      //         ),
      //       );
      //     },
      //   ),
      // ),
      onIndexChanged: (value) {},
    ));
  }
}
