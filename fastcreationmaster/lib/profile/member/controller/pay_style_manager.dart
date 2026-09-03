import 'dart:math';
import 'dart:ui';

import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../global/ui/colors.dart';
import '../beans/vip_type_bean.dart';
import 'member_center_controller.dart';

///付费页样式管理器
class PayStyleManager {
  int type = 0; //付费 0: 横屏, 1: 竖屏
  int style = 1; ///  1: 默认黑色样式, 2:黑色背景样式, 3:白色背景样式   4：9.0.7-白色样式  5；9.0.7-黑色样式  6；9.0.

  PayStyleManager({
    required this.type,
    required this.style,
  });

  /// 获取顶部banner样式
  String getBannerPath() {
    if (style == 4 || style == 5) {
      if (type == 0) {
        return 'assets/business/icon_pay_center_top_bg_${style}_large.png';
      } else if (type == 1) {
        return 'assets/business/icon_pay_center_top_bg_$style.png';
      }
    }
    return 'assets/business/icon_pay_center_top_bg_$style.png';
  }

  /// 获取标题样式
  String getTitlePath() {
    return 'assets/business/icon_pay_center_top_bg_$style.png';
  }

  ///获取均价
  String getAveragePrice(VipTypeBean bean, {int style = -1}) {
    if(style == -1) {
      style = bean.vipListStyle;
    }
    switch (style) {
      case 1:
        return bean.money;
      case 2:
        return bean.dayMoney;
      case 3:
        return bean.monthMoney;
      case 4:
        return bean.integralMoney!;
      case 5:
        return bean.wordsPackMoney!;
      default:
        return bean.money;
    }
  }

  ///获取均价描述
  String getAveragePriceDes(VipTypeBean bean, {int style = -1}) {
    if(style == -1) {
      style = bean.vipListStyle;
    }
    switch (style) {
      case 1:
      ///积分
      case 4:
        return '';
      case 2:
        return '/天';
      case 3:
        return '/月';

      ///字数包
      case 5:
        return '/万字';
      default:
        return '';
    }
  }

  ///获取对应位置的显示名称
  String getPayTypeName(VipTypeBean bean, int position) {
    int boldPostion = 3;
    if (bean.boldArea != null && bean.boldArea!.isNotEmpty) {
      boldPostion = int.parse(bean.boldArea!.first);
    }

    ///标题位置
    if (position == 1) {
      ///标题加粗
      if (boldPostion == 2) {
        return '￥${getAveragePrice(bean)}${getAveragePriceDes(bean)}';
      } else {
        return bean.title;
      }
    }

    ///套餐价格位置
    else if (position == 2) {
      Get.log("====position==$position   style===$style  des===${bean.des}  boldPostion===$boldPostion");

      // if(style==4||style==5){
      //   // Get.log("====position==$position   style===$style  des===${bean.des}");
      //   return bean.des;
      // }

      ///套餐价被加粗
      if (boldPostion == 1) {
        return '￥${getAveragePrice(bean)}${getAveragePriceDes(bean)}';
      } else {
        return '￥${bean.money}';
      }
    }

    ///均价位置
    ///钱符号
    else if (position == 3) {
      return boldPostion == 3 ? '￥' : '';
    }

    ///套餐价
    else if (position == 4) {
      ///套餐价被加粗
      if (boldPostion == 2) {
        return bean.title;
      } else if (boldPostion == 1) {
        return '￥${bean.money}';
      } else {
        return getAveragePrice(bean);
      }
    }

    ///套餐价位置后缀如/天、/月等
    else if (position == 5) {
      return boldPostion == 3 ? getAveragePriceDes(bean) : '';
    }
    return '';
  }

  ///支付的顶部title 提示语
  payTopTitleWidget() {
    if (style == 4 || style == 5) {
      return const SizedBox();
    }
    if (type != 0) {
      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: SizedBox(
          height: 34.w,
          width: double.infinity,
          child: Center(
              child: Image.asset(
            'assets/business/icon_pay_center_top_title_$style.png',
            width: 309.w,
            fit: BoxFit.contain,
          )),
        ),
      );
    }

    return const SizedBox();
  }

  ///支付套餐的提示用语背景
  Widget payContentTitleBgWidget() {
    if (style == 4 || style == 5) {
      return Container(
        width: 1.sw,
        decoration: BoxDecoration(
            // color: style == 4 ?const Color(0xFFF6F6F6):Color
            ),
        child: Image.asset(
          "assets/business/icon_pay_center_top_title_$style.png",
          width: 293.w,
          height: 36.w,
        ),
      );
    }
    return Container(
      height: 23.w,
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: style == 3
                  ? [
                      const Color(0xFFF6F6F6).withOpacity(0),
                      const Color(0xFFF6F6F6)
                    ]
                  : [ByColorUtil.colorBg1.withOpacity(0), ByColorUtil.colorBg1],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter)),
    );
  }

  ///支付套餐的提示用语背景
  Widget payContentTitleWidget({
    required MemberCenterController controller,
  }) {
    String iconPath = "assets/business/icon_pay_center_decoration.png";
    String title1 = "告别写作瓶颈";
    String title2 = "稳拿保底稿费";
    if (style == 3 || style == 4) {
      iconPath = "assets/business/icon_pay_center_decoration_black.png";
    }

    if (style == 4 || style == 5) {
      title1 = "VIP解锁，";
      title2 = "小说创作变现教程";
    }

    return Column(
      children: [
        SizedBox(height: 7.w),
        Obx(() {
          final itemCount = controller.newVipList.length;
          if (itemCount == 0) {
            return Container();
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                iconPath,
                width: 36.w,
                height: 12.w,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 4.w),
              ByWidgetsUtil.commonText(
                  text: title1,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  textColor: (style == 3 || style == 4)
                      ? ByColorUtil.colorF7
                      : ByColorUtil.colorF1),
              if (style != 4 && style != 5) SizedBox(width: 4.w),
              if (style != 4 && style != 5)
                Container(
                  height: 16.w,
                  width: 1.w,
                  color: style == 3 ? ByColorUtil.colorF7 : ByColorUtil.colorF1,
                ),
              if (style != 4 && style != 5) SizedBox(width: 4.w),
              ByWidgetsUtil.commonText(
                  text: title2,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  textColor: (style == 3 || style == 4)
                      ? ByColorUtil.colorF7
                      : ByColorUtil.colorF1),
              SizedBox(width: 4.w),
              Transform.rotate(
                angle: pi,
                child: Image.asset(
                  iconPath,
                  width: 36.w,
                  height: 12.w,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          );
        }),
        SizedBox(height: 12.w),
      ],
    );
  }
}
