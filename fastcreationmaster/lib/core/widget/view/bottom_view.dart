import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/controller/base_record_controller.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../global/ui/colors.dart';
import '../../util/by_screen_utils.dart';
import 'by_button.dart';

///底部视图，单生成下一步，切换vip
// ignore: must_be_immutable
class BottomView extends StatelessWidget {
  BottomView(
      {super.key,
      this.words = '',
      this.mode = 0,
      this.nextBtnText = '下一步',
      this.toggleMode,
      this.showWords = true,
      this.nextStep,
      this.padding,
      this.enable = true,
      this.checkLogin = true,
      this.type,
      });

  ///字数
  final String? words;

  ///切换普通和专业版模式
  final Function? toggleMode;

  ///下一步
  final Function? nextStep;

  ///初始化模式，0为普通只有下一步模式，1为普通版模式， 2为专业版模式
  final int? mode;

  ///下一步
  final String? nextBtnText;

  ///是否显示字数展示
  final bool? showWords;

  ///是否可点击
  final bool? enable;

  /// 是否检查登录
  final bool? checkLogin;

  final double? padding;

  final userController = Get.find<UserController>();

  Rx<String> userWords = '0'.obs;

  final  CreationType? type;

  @override
  Widget build(BuildContext context) {
    Widget widget = _buildNormalBottomView();
    if (mode == 1) {
      widget = _buildProfessionalBottomNormalView();
    } else if (mode == 2) {
      widget = _buildProfessionalBottomView();
    }
    return Opacity(
      opacity: enable! ? 1.0 : 0.3,
      child: Column(
        children: [
          if (showWords!) _buildWordsView(),
          widget,
        ],
      ),
    );
  }

  Widget _buildWordsView() {
    bool isVip = userController.userInfoBean.value?.isVip == 1;
    bool isRegister = Get.isRegistered<ProfileController>();
    if (isRegister) {
      userWords.value = Get.find<ProfileController>().getUserWords();
    }

    bool showCouldTry = false;
    if(!isVip){
      if(userController.couldTry){
        if(type==CreationType.novel||type==CreationType.shortNovel){
          showCouldTry = true;
        }
      }
    }

    // if(userController.couldTry){
    //   words = "1.08w";
    // }

    // Get.log("words==== $words");

    return SizedBox(
      height: 36.w,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding ?? 12.w),
        child: Row(
          children: [
            words!.isNotEmpty
                ? _wordsView('预计消耗', showCouldTry?"1.08w":'$words', isVip: isVip)
                : isVip
                    ? Container()
                    : _buildBusinessView(),
            const Spacer(),
            if (words!.isNotEmpty && !isVip) _buildBusinessView(),
            if (words!.isNotEmpty && !isVip)
              SizedBox(
                width: 4.w,
              ),
            Obx(() => _wordsView('剩余', userWords.value)),
            // Obx(() => goBuyVip()),
          ],
        ),
      ),
    );
  }

  ///商业化提示
  Widget _buildBusinessView() {
    return Row(
      children: [
        SizedBox(
          width: 4.w,
        ),
        GestureDetector(
          onTap: () {
            userController.checkPreLogin(
              source: 'bottom',
              actionCallback: () {
                userController.jumpToPayPage(source: 'bottom');
              },
            );
          },
          child: ByWidgetsUtil.commonText(
              text: '写小说变现', fontSize: 12.sp, textColor: Color(0XFF98FC4A)),
        ),
        // SizedBox(
        //   width: 4.w,
        // ),
        Container(
          width: 1.w,
          height: 13.w,
          color: Colors.white.withOpacity(0.64),
          margin: EdgeInsets.only(left: 2.w,right: 2.w),
        ),
        goBuyVip(),
      ],
    );

    // return Row(
    //   children: [
    //     SizedBox(
    //       width: 18,
    //       height: 18,
    //       child: Image.asset(
    //         'assets/business/icon_business_bond.png',
    //         width: 18,
    //         height: 18,
    //       ),
    //     ),
    //     SizedBox(width: 4.w,),
    //     GestureDetector(
    //       onTap: () {
    //         userController.checkPreLogin(
    //           source: 'bottom',
    //           actionCallback: () {
    //             userController.jumpToPayPage(source: 'bottom');
    //           },
    //         );
    //       },
    //       child: ByWidgetsUtil.commonText(
    //         text: '≈0.01元得海量字数',
    //         fontSize: 12.sp,
    //         textColor: ByColorUtil.colorG4),
    //     ),
    //   ],
    // );
  }

  ///字数显示子组件
  Widget _wordsView(
    String preString,
    String words, {
    String? sufString,
    bool? isVip,
  }) {
    return GestureDetector(
      onTap: () {
        userController.jumpToPayPage(isWordsEmpty: false, source: 'bottom');
      },
      child: Row(
        children: [
          ByWidgetsUtil.commonRichText(
              fontSize: 12.sp,
              textColor: ByColorUtil.colorF2,
              fontWeight: FontWeight.normal,
              texts: [
                TextSpan(
                  text: preString,
                ),
                TextSpan(
                  text: words,
                  style: const TextStyle(
                    color: ByColorUtil.colorC1,
                  ),
                ),
                TextSpan(
                  text: sufString ?? '字',
                ),
              ]),
          if (isVip == false)
            Padding(
              padding: EdgeInsets.only(
                bottom: 0.w,
              ),
              child: Text(
                "（字数不足）",
                style: TextStyle(
                  color: Color(0XFFFE5024),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.normal,
                ),
              ),
            )
        ],
      ),
    );
  }

  ///无专业版模式下底部按钮
  Widget _buildNormalBottomView() {
    ///立即生成
    return KeyboardDismissOnTap(
      dismissOnCapturedTaps: true,
      child: Container(
        height: 56.w + ByScreenUtils.bottomSafeHeight,
        padding: EdgeInsets.only(
            left: padding ?? 12.w,
            right: padding ?? 12.w,
            top: 4.w,
            bottom: ByScreenUtils.bottomSafeHeight + 4.w),
        child: SizedBox(
          height: 48.w,
          child: ByButton.gradientBtn(
              textColor: Colors.black,
              title: nextBtnText!,
              onClick: () {
                if (enable!) {
                  if(checkLogin!) {
                    userController.checkPreLogin(
                      source: 'bottom',
                      actionCallback: () {
                        if (showWords!) {
                          userWords.value =
                              Get.find<ProfileController>().getUserWords();
                        }
                        nextStep?.call();
                      });
                  }
                  else {
                    nextStep?.call();
                  }
                }
              }),
        ),
      ),
    );
  }

  ///有专业版普通模式下底部按钮
  Widget _buildProfessionalBottomNormalView() {
    return KeyboardDismissOnTap(
      dismissOnCapturedTaps: true,
      child: Container(
        height: 60.w + ByScreenUtils.bottomSafeHeight,
        padding: EdgeInsets.only(
            left: padding ?? 12.w,
            right: padding ?? 12.w,
            bottom: ByScreenUtils.bottomSafeHeight + 4.w),
        child: SizedBox(
          height: 60.w,
          child: Row(
            children: [
              ByButton.grandiantVIPBtn(
                title: '切换专业版',
                image: 'assets/global/common/icon_switch_vip.png',
                onClick: () {
                  ///切换模式
                  userController.checkPreLogin(
                      source: 'bottom',
                      actionCallback: () {
                        toggleMode?.call();
                      });
                },
              ),
              SizedBox(
                width: 6.w,
              ),
              Expanded(
                child: SizedBox(
                  height: 48.w,
                  child: ByButton.gradientBtn(
                      textColor: Colors.black,
                      title: '下一步',
                      onClick: () {
                        userController.checkPreLogin(
                            source: 'bottom',
                            actionCallback: () {
                              userWords.value =
                                  Get.find<ProfileController>().getUserWords();
                              nextStep?.call();
                            });
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///有专业版专业模式下底部按钮
  Widget _buildProfessionalBottomView() {
    return KeyboardDismissOnTap(
      dismissOnCapturedTaps: true,
      child: Container(
        height: 60.w + ByScreenUtils.bottomSafeHeight,
        padding: EdgeInsets.only(
            left: padding ?? 12.w,
            right: padding ?? 12.w,
            bottom: ByScreenUtils.bottomSafeHeight + 4.w),
        child: SizedBox(
          height: 60.w,
          child: Row(
            children: [
              SizedBox(
                height: 48.w,
                child: ByButton.gradientImageBtn(
                    image: 'assets/global/common/icon_switch_normal.png',
                    textColor: ByColorUtil.colorC1,
                    bgColor: ByColorUtil.color2E3038,
                    title: '切换普通版',
                    onClick: () {
                      ///切换模式
                      userController.checkPreLogin(
                          source: 'bottom',
                          actionCallback: () {
                            toggleMode?.call();
                          });
                    }),
              ),
              SizedBox(
                width: 6.w,
              ),
              Expanded(
                child: ByButton.grandiantVIPBtn(
                  title: '下一步',
                  onClick: () {
                    userController.checkPreLogin(
                        source: 'bottom',
                        actionCallback: () {
                          userWords.value =
                              Get.find<ProfileController>().getUserWords();
                          nextStep?.call();
                        });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///非vip 去充值
  Widget goBuyVip() {
    return GestureDetector(
      onTap: () {
        userController.jumpToPayPage(isWordsEmpty: false, source: 'bottom');
      },

      child: ByWidgetsUtil.commonText(
          text: '去充值', fontSize: 12.sp, textColor: Color(0XFF98FC4A)),
      // child: Row(
      //   children: [
      //     ByWidgetsUtil.commonRichText(
      //         fontSize: 12.sp,
      //         textColor: ByColorUtil.colorF2,
      //         fontWeight: FontWeight.normal,
      //         texts: [
      //            TextSpan(
      //             text: "去充值",
      //             style: TextStyle(
      //               color: Color(0XFF98FC4A),
      //               fontSize: 12.sp
      //             ),
      //           ),
      //         ]),
      //   ],
      // ),
    );
  }
}
