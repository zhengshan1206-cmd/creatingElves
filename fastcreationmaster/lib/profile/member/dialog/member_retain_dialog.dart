import 'dart:math';
import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/core/service/words.dart';
import 'package:fast_creation_master/core/util/by_screen_utils.dart';
import 'package:fast_creation_master/profile/member/widget/scale_transition_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../global/other/event_tracking/event_tracking.dart';
import '../../../global/ui/colors.dart';
import '../controller/member_center_controller.dart';
import '../widget/bottom_protocal_view.dart';
import '../widget/member_contdown.dart';

///支付页挽留弹窗类型
enum MemberRetainType {
  ///支付页返回拦截挽留弹窗9.0.1版本
  cancelPay_9_0_1,

  ///支付页返回拦截挽留弹窗9.0.6版本
  cancelPay_9_0_6,

  ///支付失败挽留弹窗9.0.1版本
  payFailed_9_0_1,

  ///支付页二次返回拦截挽留弹窗9.0.2版本
  cancelPaySecond_9_0_2,

  ///11.0.5创作大事挽留弹窗
  createBig_11_0_5,
}

class MemberRetainDialog extends StatefulWidget {
  ///弹窗类型
  final MemberRetainType type;

  /// 弹窗模式 1.弹窗 2.抽屉  11.0.5版本新增
  final int mode;

  final Function()? confirm;
  final Function()? close;

  const MemberRetainDialog({
    super.key,
    this.mode = 2,
    this.confirm,
    this.close,
    required this.type,
  });

  @override
  State<MemberRetainDialog> createState() => _MemberRetainDialogState();
}

class _MemberRetainDialogState extends State<MemberRetainDialog>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _aniController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // 初始化动画控制器（时长 300ms，控制动画速度）
    _aniController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // 2. 缩放动画：从 1.0（原尺寸）→ maxScale（放大后尺寸）
    _scaleAnimation = Tween<double>(begin: 5, end: -5).animate(
      CurvedAnimation(
        parent: _aniController,
        curve: Curves.linear,
      ), // 动画曲线（自然过渡）
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _aniController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _aniController.dispose();
    super.dispose();
  }

  Widget _chooseDialog() {
    switch (widget.type) {
      case MemberRetainType.cancelPay_9_0_1:
        return _buildNewRetainDialog();
      case MemberRetainType.payFailed_9_0_1:
        return _buildFailedRetainDialog();
      case MemberRetainType.cancelPay_9_0_6:
        return _buildRetainDialog();
      case MemberRetainType.createBig_11_0_5:
        return _buildCreateBigRetainDialog();
      default:
        return _buildPayFailedLuckyView();
    }
  }

  /// 11.0.5创作大事挽留弹窗
  Widget _buildCreateBigRetainDialog() {
    final MemberCenterController controller =
        Get.find<MemberCenterController>();
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildCloseBtn(back: () {
              widget.close?.call();
            }),
            SizedBox(
              height: 15.w,
            ),
            GestureDetector(
              onTap: widget.mode == 2 ? null : () {
                widget.confirm?.call();
              },
              child: SizedBox(
                width: double.infinity,
                child: Image.network(
                  controller.popConfigList[0].img,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ],
        ),
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 20.w,
              ),
              if(widget.mode == 2)
              GestureDetector(
                onTap: () {
                  widget.confirm?.call();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Stack(
                    children: [
                      Container(
                        height: 56.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.w),
                          color: Colors.transparent,
                          image: const DecorationImage(
                            image: AssetImage(
                                "assets/business/btn_pay_intercept_next_new.png"),
                            fit: BoxFit.fill,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          // bgType == 2 ? '立即开通' : "下一步",
                          controller.popConfigList[0].popBtnTitle,
                          style: TextStyle(
                            fontFamily: 'AlimamaShuHeiTi',
                            color: ByColorUtil.colorF9,
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 20.w,
                        top: 19.w,
                        child: AnimatedBuilder(
                                animation: _aniController,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(_scaleAnimation.value, 0),
                                    child: SizedBox(
                                      height: 18.w,
                                      width: 18.w,
                                      child: Image.asset(
                                          "assets/business/btn_pay_intercept_next_new_arrow.png"),
                                    ),
                                  );
                                })),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 12.w,
              ),
              BottomProtocalView(
                style: 1,
              ),
              SizedBox(
                height: 2.w + max(14.w, ByScreenUtils.bottomSafeHeight),
              ),
            ],
          ),
        ),
      ],
    );
  }

  ///9.0.6新版挽留弹窗
  Widget _buildRetainDialog() {
    final MemberCenterController controller =
        Get.find<MemberCenterController>();
    final bean =
        controller.payData.vipList[controller.selectedPackageIndex.value];
    return Container(
      height: 599.w,
      width: double.infinity,
      // padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/business/icon_pay_intercept_bg.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              const Spacer(),
              GestureDetector(
                onTap: () {
                  EventTracking.reportDataPoint(
                      pageTag: 'member_page_retention_close_btn',
                      operateType: 'click',
                      funcDetailTag: controller.landingPage,
                      funcDetailImg: '',
                      extra: {
                        'pay_page_id': controller.pagePageID,
                        'vip_id': controller.getPackageID(),
                      });
                  Get.back();
                },
                child: SizedBox(
                  width: 48,
                  height: 32,
                  child: Image.asset(
                    "assets/global/common/btn_close_black_transparent.png",
                    width: 16,
                    height: 16,
                  ),
                ),
              ),
            ],
          ),
          ByWidgetsUtil.commonText(
              text: '关闭=放弃',
              fontFamily: 'AlimamaShuHeiTi',
              fontSize: 25.sp,
              textColor: ByColorUtil.colorF9),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                style: TextStyle(
                  fontFamily: 'AlimamaShuHeiTi',
                  fontSize: 25.sp,
                ),
                children: const [
                  TextSpan(
                    text: '离写小说赚钱就差',
                    style: TextStyle(color: ByColorUtil.colorF9),
                  ),
                  TextSpan(
                    text: '最后一步',
                    style: TextStyle(
                      color: Color(0xFFFF6F16),
                    ),
                  ),
                ]),
          ),
          SizedBox(
            height: 15.w,
          ),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                style: TextStyle(
                    fontFamily: 'AlimamaShuHeiTi',
                    fontSize: 34.sp,
                    color: ByColorUtil.colorG4),
                children: [
                  const TextSpan(
                    text: '￥',
                  ),
                  TextSpan(
                      text: controller.styleManager
                          .getAveragePrice(bean, style: bean.vipDialogStyle!),
                      style: TextStyle(
                        fontSize: 66.sp,
                      )),
                  TextSpan(
                    text: controller.styleManager
                        .getAveragePriceDes(bean, style: bean.vipDialogStyle!),
                  ),
                ]),
          ),
          SizedBox(
            height: 12.w,
          ),
          Transform.rotate(
            angle: pi,
            child: Image.asset(
              'assets/global/common/icon_box_arrow_down.png',
              width: 11.w,
              height: 6.w,
            ),
          ),
          Container(
            height: 35.w,
            // width: 270.w,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 3.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              color: const Color(0xFF270C0C).withOpacity(0.8),
            ),
            child: ByWidgetsUtil.commonRichText(texts: [
              const TextSpan(text: '解锁'),
              TextSpan(
                  text:
                      '${WordsService.wordsDisplay('${bean.wordsPack}', unit: 'w', showIntegal: true)}灵感值',
                  style: const TextStyle(color: Color(0xFFFE5024))),
              const TextSpan(text: '不断更大礼包'),
            ], textColor: ByColorUtil.colorF1, fontSize: 20.sp),
          ),
          SizedBox(
            height: 14.w,
          ),
          MemberCountdown(
            fontSize: 23.sp,
            textColor: const Color(0xFFFEF955),
            bgColor: const Color(0xFF2A0D0E),
            separatorColor: const Color(0xFF2A0D0E),
            timeItemWidth: 42.w,
            borderRadius: 9.w,
            showMilliseconds: true,
            type: 0,
            // showHours: false,
            // seconds: 60 * 5,
          ),
          SizedBox(
            height: 20.w,
          ),
          GestureDetector(
            onTap: () {
              EventTracking.reportDataPoint(
                  pageTag: 'member_page_retention_open_btn',
                  operateType: 'click',
                  funcDetailTag: controller.landingPage,
                  funcDetailImg: '',
                  extra: {
                    'pay_page_id': controller.pagePageID,
                    'vip_id': controller.getPackageID(),
                  });
              Get.back(result: "true");
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Container(
                height: 56.w,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/business/btn_pay_intercept_next.png"),
                    fit: BoxFit.fill,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  "下一步",
                  style: TextStyle(
                    color: ByColorUtil.colorF9,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 2.w,
          ),
          BottomProtocalView(),
          SizedBox(
            height: 2.w + max(34.w, ByScreenUtils.bottomSafeHeight),
          ),
        ],
      ),
    );
  }

  ///9.0.1挽留弹窗
  Widget _buildNewRetainDialog() {
    return Center(
      child: Container(
        width: 300.w,
        height: 340.h,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/profile/member/member_dialog_3.png"),
            fit: BoxFit.contain,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Get.back(result: "true");
              },
              child: ScaleTransitionWidget(
                child: Container(
                  width: 158.w,
                  height: 40.h,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          "assets/profile/member/member_dialog_btn.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "立即领取",
                    style: TextStyle(
                      color: const Color(0xFFFFFFFF),
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Padding(
                padding: EdgeInsets.only(bottom: 14.h, top: 12.h),
                child: Text(
                  "我放弃",
                  style: TextStyle(
                    color: const Color(0xFFA23D3E),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///支付失败挽留弹窗
  Widget _buildFailedRetainDialog() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 280.w,
            height: 330.h,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/profile/member/member_dialog_4.png"),
                fit: BoxFit.fill,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.back(result: "true");
                  },
                  child: ScaleTransitionWidget(
                    child: Container(
                      width: 158.w,
                      height: 40.h,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              "assets/profile/member/member_dialog_btn.png"),
                          fit: BoxFit.fill,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "立即领取",
                        style: TextStyle(
                          color: const Color(0xFFFFFFFF),
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: Text(
                        "我放弃",
                        style: TextStyle(
                          color: const Color(0xFFA23D3E),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: widget.mode == 1
          ? MainAxisAlignment.center
          : widget.type != MemberRetainType.cancelPay_9_0_6 &&
                  widget.type != MemberRetainType.createBig_11_0_5
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
      crossAxisAlignment: widget.type != MemberRetainType.createBig_11_0_5
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        if (widget.type != MemberRetainType.cancelPay_9_0_6 &&
            widget.type != MemberRetainType.createBig_11_0_5)
          _buildCloseBtn(),
        // const Spacer(),
        // SizedBox(
        //   height: 74.h,
        // ),
        if (widget.type != MemberRetainType.cancelPaySecond_9_0_2 && widget.mode == 2)
          SizedBox(
            height: 74.h,
          ),
        _chooseDialog(),
      ],
    );
  }

  Widget _buildCloseBtn({VoidCallback? back}) {
    return GestureDetector(
      onTap: () {
        if (back != null) {
          back.call();
        } else {
          Get.back();
        }
      },
      child: Container(
        width: 48,
        height: 32,
        margin: EdgeInsets.only(top: ByScreenUtils.topSafeHeight),
        child: Image.asset(
          "assets/global/common/btn_close.png",
          width: 16,
          height: 16,
        ),
      ),
    );
  }

  ///取消支付放弃后的幸运挽留弹窗
  Widget _buildPayFailedLuckyView() {
    return SizedBox(
        width: 375.w,
        height: 494.w,
        child: Stack(
          children: [
            Image.network(
              Get.find<UserController>().paybackURL,
              fit: BoxFit.contain,
            ),
            Positioned(
              bottom: 90.w,
              left: 103.w,
              child: GestureDetector(
                onTap: () {
                  Get.back(result: "true");
                },
                child: ScaleTransitionWidget(
                  child: Container(
                    width: 170.w,
                    height: 44.w,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            "assets/profile/member/member_dialog_btn.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "立即领取",
                      style: TextStyle(
                        color: const Color(0xFF000000),
                        fontSize: 20.sp,
                        fontFamily: 'AlimamaShuHeiTi',
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 60.w,
              left: 137.5.w,
              child: GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  width: 100.w,
                  height: 30.w,
                  padding: EdgeInsets.only(top: 6.w, bottom: 6.w),
                  child: Text(
                    "我放弃",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFFA23D3E),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
