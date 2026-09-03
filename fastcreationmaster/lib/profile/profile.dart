/*
 * @Author: cold-x
 * @Date: 2025-05-28 14:54:41
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-03-06 17:47:12
 * @FilePath: /fastcreationmaster/lib/profile/profile.dart
 * @Description: 
 */

import 'dart:io';

import 'package:byhy_app_common_utils/app_common/consts/build_config.dart';
import 'package:byhy_app_common_utils/app_http/channel.dart';
import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fast_creation_master/core/controller/base_record_controller.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/core/service/data_service.dart';
import 'package:fast_creation_master/global/const/asset_const.dart';
import 'package:fast_creation_master/global/login/controller/onekey_manager.dart';
import 'package:fast_creation_master/global/routes/app_pages.dart';
import 'package:fast_creation_master/global/routes/routes_utils.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:fast_creation_master/profile/member/beans/user_info_bean.dart';
import 'package:fast_creation_master/profile/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../core/util/clipboard.dart';
import '../global/other/event_tracking/event_tracking.dart';
import '../global/permission/byhy_permission_utils.dart';

class ProfilePage extends GetView<ProfileController> {
  ProfilePage({super.key});
  final ProfileController _controller = Get.find<ProfileController>();

  final userController = Get.find<UserController>();

  // 添加路由名称支持
  String? get routeName => '/profile';

  ///消息-设置按钮
  Widget _messageSetting() {
    return GestureDetector(
      onTap: () => {
        Get.toNamed(Routes.setting)
        // Get.offNamed(Routes.memberPaySuccess, arguments: {'isBackHome': true})
      },
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        width: 44,
        height: 44,
        child: Center(
          child: Image.asset('assets/profile/profile_setting_icon.png',
              width: 24, height: 24),
        ),
      ),
    );
  }

  ///用户头像
  Widget _userAvatar() {
    return Obx(
      () => Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () {
                    if (_controller.userInfo!.isFormal == 0) {
                      OneKeyManager.onekeyLogin(source: 'profile');
                    }
                  },
                  child: Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: _controller.userInfo?.avatar != null &&
                                _controller.userInfo!.avatar.isNotEmpty
                            ? NetworkImage(_controller.userInfo!.avatar)
                            : const AssetImage(
                                    'assets/profile/profile_bg_icon.png')
                                as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Transform.scale(
                      scale: 1.2,
                      child: Image.asset(
                        'assets/profile/icon_profile_decoration.png'
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 16.w),
            Column(
              children: [
                const SizedBox(
                  height: 25,
                ),
                GestureDetector(
                  onTap: () {
                    userController.checkPreLogin(source: 'profile');
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _controller.userInfo?.nickName ?? '游客',
                        style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w500,
                            color: ByColorUtil.colorF1),
                      ),
                      SizedBox(height: 4.h),
                      GestureDetector(
                        onTap: () {
                          ClipboardManager.clip(
                              '${_controller.userInfo?.userId}');
                        },
                        child: Row(
                          children: [
                            Text(
                              'id：${_controller.userInfo?.userId ?? ''}',
                              style: TextStyle(
                                  fontSize: 13.sp, color: ByColorUtil.colorF2),
                            ),
                            SizedBox(
                              width: 4.h,
                            ),
                            Image.asset(
                              'assets/profile/btn_profile_copy.png',
                              width: 12,
                              height: 12,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            _messageSetting(),
          ],
        ),
      ),
    );
  }

  ///主体内容
  Widget _mainContent() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          children: [
            if (_controller.userInfo?.isVip == 0) _openVip(),
            if (_controller.userInfo?.isVip == 1) _openVipAlready(),
            const SizedBox(height: 4),
            _myCreation(),
            _buildBannerView(),
            _infoList(),
          ],
        ),
      ),
    );
  }

  ///开通会员
  Widget _openVip() {
    return Transform.translate(
      offset: const Offset(0, 20),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: GestureDetector(
              onTap: () {
                EventTracking.reportDataPoint(
                        pageTag: 'my_page_get_btn',
                        operateType: 'click',
                        funcDetailImg: '',
                        funcDetailTag: '',);
                userController.checkPreLogin(
                    source: 'profile',
                    actionCallback: () {
                      userController.jumpToPayPage(source: 'profile');
                    });
              },
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 88,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage(
                              'assets/profile/icon_profile_formal_bg${AssetConst.springFestival()}.png')),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    // height: 88,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/profile/profile_vip_icon${AssetConst.springFestival()}.png',
                                  height: 20,
                                  width: 20,
                                  fit: BoxFit.fitHeight,
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                ByWidgetsUtil.commonText(
                                    textColor: AssetConst.springFestival().isEmpty ? ByColorUtil.colorF8 : ByColorUtil.colorG5,
                                    fontSize: 17.sp,
                                    fontFamily: 'AlimamaShuHeiTi',
                                    text: '写小说 真的不难')
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '创作10000字，低至5毛！',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: ByColorUtil.colorF4,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 88,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AssetConst.springFestival().isEmpty ? ByColorUtil.colorF8 : Colors.transparent,
                            image: AssetConst.springFestival().isEmpty ? null : const DecorationImage(
                              image: AssetImage('assets/profile/btn_profile_get_vip.png')
                            ),
                            borderRadius: BorderRadius.circular(44),
                          ),
                          child: Center(
                            child: Text(
                              '戳我领取',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: ByColorUtil.colorF1,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
            right: 0,
            top: 0,
            child: Transform.translate(
              offset: const Offset(0, -10),
              child: SizedBox(
                height: 26.w,
                child: Container(
                    padding: EdgeInsets.only(right: 12.w, left: 2.w),
                    decoration: BoxDecoration(
                        color: ByColorUtil.colorG4,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(13.w),
                          topRight: Radius.circular(13.w),
                          bottomLeft: Radius.circular(13.w),
                        )),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.translate(
                            offset: Offset(-2.w, -4.w),
                            child: Image.asset(
                              'assets/profile/icon_profile_formal_gift.png',
                              width: 26.w,
                              height: 26.w,
                            ),
                          ),
                          ByWidgetsUtil.commonRichText(texts: [
                            const TextSpan(
                              text: '请于今天24点前',
                            ),
                            const TextSpan(
                                text: '领取字数优惠',
                                style: TextStyle(
                                  color: Color(0xFFEDFF87),
                                ))
                          ], textColor: ByColorUtil.colorF1, fontSize: 12.sp),
                        ])),
              ),
            ),
          ),
          Positioned(
              top: 26.w - 10.1,
              right: 0,
              child: Image.asset(
                'assets/profile/icon_bottomright_red_12.png',
                width: 12.w,
                height: 12.w,
              ))
        ],
      ),
    );
  }

  ///banner位
  Widget _buildBannerView() {
    return Obx(
      () => _controller.bannerList.isEmpty || !_controller.showBanner.value
          ? const SizedBox.shrink()
          : Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 12.w),
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 124.h,
                      viewportFraction: 1.0,
                      autoPlay: _controller.bannerList.length > 1,
                      autoPlayInterval: const Duration(seconds: 3),
                      enableInfiniteScroll: _controller.bannerList.length > 1,
                    ),
                    items: _controller.bannerList.map(
                      (banner) {
                        return Builder(
                          builder: (BuildContext context) {
                            return GestureDetector(
                              onTap: () {
                                userController.checkPreLogin(
                                    source: 'profile',
                                    actionCallback: () {
                                      EventTracking.reportDataPoint(
                                        pageTag: 'banner',
                                        operateType: 'click',
                                        funcDetailTag: banner.id.toString(),
                                        funcDetailImg: banner.imgUrl,
                                        extra: {'position': 'my_page'}
                                      );
                                      NavigateUtils.navigateTo(banner);
                                    });
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  banner.imgUrl,
                                  width: double.infinity,
                                  height: 124.h,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ).toList(),
                  ),
                ),
                Positioned(
                  top: 15.w,
                  right: 10.w,
                  child: GestureDetector(
                    onTap: () {
                      _controller.closeBanner();
                    },
                    child: Image.asset("assets/home/main/dialog_close.png",
                        width: 20.w, height: 20.w, fit: BoxFit.contain),
                  ),
                )
              ],
            ),
    );
  }

  ///已开通会员
  Widget _openVipAlready() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
      child: GestureDetector(
        onTap: () => {
          // userController.checkPreLogin(actionCallback: () {
          //   userController.jumpToPayPage(isWordsEmpty: false);
          // }),
        },
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 70,
              padding: const EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_controller.userInfo?.vipLevel != null &&
                          _controller.userInfo!.vipLevel <= 30
                      ? 'assets/profile/profile_monthly_bg.png'
                      : _controller.userInfo?.vipLevel != null &&
                              _controller.userInfo!.vipLevel > 30 &&
                              _controller.userInfo!.vipLevel <= 365
                          ? 'assets/profile/profile_year_bg.png'
                          : 'assets/profile/profile_lifelong_bg.png'),
                  fit: BoxFit.fill,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Image.asset(
                          _controller.userInfo?.vipLevel != null &&
                                  _controller.userInfo!.vipLevel <= 30
                              ? 'assets/profile/profile_monthly_title.png'
                              : _controller.userInfo?.vipLevel != null &&
                                      _controller.userInfo!.vipLevel > 30 &&
                                      _controller.userInfo!.vipLevel <= 365
                                  ? 'assets/profile/profile_year_title.png'
                                  : 'assets/profile/profile_lifelong_title.png',
                          width: 30,
                          height: 22,
                          fit: BoxFit.contain),
                      Text(
                        '${_controller.userInfo?.vipLevelName}',
                        style: TextStyle(
                          fontSize: 17.sp,
                          color: ByColorUtil.colorF1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _controller.userInfo!.vipLevel >= 99999
                        ? '告别写作瓶颈'
                        : '会员到期日：${_controller.userInfo?.vipEndTime != null ? DateFormat('yyyy-MM-dd').format(_controller.userInfo!.vipEndTime!) : ''}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: ByColorUtil.colorF1.withOpacity(0.7),
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

  ///创作记录
  Widget _creationRecord(String title, int number, CreationType type,
      {String? routeName = Routes.record}) {
    return Expanded(
      child: InkResponse(
        onTap: () {
          userController.checkPreLogin(
              source: 'profile',
              actionCallback: () {
                Get.toNamed(routeName!, arguments: {'type': type})?.then((_) {
                  ///刷新创作记录
                  controller.getNovelCreateCount();
                });
              });
        },
        child: SizedBox(
          child: Column(
            children: [
              Text(
                '$number',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AssetConst.springFestival().isEmpty ? ByColorUtil.colorF5 : ByColorUtil.colorG6,
                ),
              ),
              SizedBox(
                height: 4.w,
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: ByColorUtil.colorF2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///我的创作
  Widget _myCreation() {
    return Obx(
      () => Container(
        height: 128.w,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/profile/icon_profile_record_bg${AssetConst.springFestival()}.png')),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3), // 阴影颜色（带透明度）
              spreadRadius: 5, // 阴影扩散半径
              blurRadius: 10, // 阴影模糊半径
              offset: const Offset(0, -6), // 阴影偏移量（x: 水平偏移, y: 垂直偏移）
            ),
          ],
          // borderRadius: BorderRadius.circular(12),
          // color: ByColorUtil.colorBg2,
        ),
        child: Column(
          children: [
            SizedBox(height: 12.w),
            Row(
              children: [
                Text(
                  '我的创作',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w500,
                    color: ByColorUtil.colorF1,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => {
                    userController.checkPreLogin(
                        source: 'profile_creation',
                        actionCallback: () {
                          userController.jumpToPayPage(
                              isWordsEmpty: false, source: 'profile_creation');
                        }),
                  },
                  child: Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '剩余字数  ',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: ByColorUtil.colorF2,
                              ),
                            ),
                            TextSpan(
                              text:
                                  '${_controller.getUserWords()}${_controller.userInfo?.isVip == 0 ? ' (字数不足)' : ''}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: _controller.userInfo?.isVip == 0
                                    ? AssetConst.springFestival().isEmpty ? ByColorUtil.colorG4 : ByColorUtil.colorG6
                                    : ByColorUtil.colorF1,
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Container(
                        width: 1,
                        height: 11,
                        color: ByColorUtil.colorF2,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      ByWidgetsUtil.commonText(
                          text: '去充值',
                          textColor: AssetConst.springFestival().isEmpty ? ByColorUtil.colorC1 : ByColorUtil.colorG6,
                          fontSize: 12.sp),
                      const SizedBox(
                        width: 4,
                      ),
                      Image.asset(
                        'assets/home/novel/btn_novel_home_outline.png',
                        width: 8,
                        height: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.w),
            SizedBox(
              child: Row(
                children: [
                  _creationRecord(
                      '长文小说',
                      _controller.recordBean.value?.longNovel ?? 0,
                      CreationType.novel,
                      routeName: Routes.novelRecord),
                  _creationRecord(
                      '短篇小说',
                      _controller.recordBean.value?.shortNovel ?? 0,
                      CreationType.shortNovel,
                      routeName: Routes.novelRecord),
                  _creationRecord(
                      '短故事',
                      _controller.recordBean.value?.shortStory ?? 0,
                      CreationType.shortStory),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///信息列表-item
  Widget _infoItem(String title, String image) {
    return GestureDetector(
      onTap: () async {
        if (title == '我的奖励') {
          Get.toNamed(Routes.rewardSharingPage);
          return;
        }
        await ByPermissionUtilsEx.photos();
        await ByPermissionUtilsEx.camera(
          needMicroPhone: false,
        );
        _controller.getProtocolByTitle(title);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 17, bottom: 17),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: ByColorUtil.colorL1,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(image, width: 18, height: 18, fit: BoxFit.fill),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: ByColorUtil.colorF1,
                  ),
                ),
              ],
            ),
            Image.asset('assets/profile/profile_right-icon.png',
                width: 12, height: 12, fit: BoxFit.fill),
          ],
        ),
      ),
    );
  }

  ///信息列表
  Widget _infoList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          // _infoItem('特别声明', 'assets/profile/profile_trend_10.png'),
          // _infoItem('我的奖励', 'assets/profile/profile_trend_12.png'),
          _infoItem('在线客服', 'assets/profile/profile_trend_11.png'),
          _infoItem('投诉举报', 'assets/profile/profile_trend_12.png'),
          // GestureDetector(
          //   onTap: () async {
          //     Get.to(DebugPage());
          //   },
          //   child: Container(
          //     width: double.infinity,
          //     padding: const EdgeInsets.only(top: 17, bottom: 17),
          //     decoration: const BoxDecoration(
          //       border: Border(
          //         bottom: BorderSide(
          //           color: ByColorUtil.colorL1,
          //           width: 1,
          //         ),
          //       ),
          //     ),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         Row(
          //           children: [
          //             Image.asset('assets/profile/profile_trend_12.png',
          //                 width: 18, height: 18, fit: BoxFit.fill),
          //             const SizedBox(width: 6),
          //             Text(
          //               "debug包代理配置",
          //               style: TextStyle(
          //                 fontSize: 14.sp,
          //                 fontWeight: FontWeight.w500,
          //                 color: ByColorUtil.colorF1,
          //               ),
          //             ),
          //           ],
          //         ),
          //         Image.asset('assets/profile/profile_right-icon.png',
          //             width: 12, height: 12, fit: BoxFit.fill),
          //       ],
          //     ),
          //   ),
          // ),
          _inviteCode(),
        ],
      ),
    );
  }

  ///邀请码
  Widget _inviteCode() {
    ChannelType channelType = BuildConfig.instance.channelType;
    bool isPassChannelType = false;
    if (channelType == ChannelType.launchTest ||
        channelType == ChannelType.huawei ||
        channelType == ChannelType.huaweiHonor ||
        channelType == ChannelType.vivo ||
        channelType == ChannelType.xiaomi ||
        channelType == ChannelType.oppo ||
        channelType == ChannelType.baidu ||
        channelType == ChannelType.tencent ||
        channelType == ChannelType.shareTest) {
      isPassChannelType = true;
    }

    if (_controller.userInfo != null) {
      if (Platform.isAndroid &&
          isPassChannelType &&
          _controller.userInfo!.isVip != 1) {
        String inviteName = Get.find<UserController>().inviteName;
        UserInfoBean? userInfoBean =
            Get.find<UserController>().userInfoBean.value;
        String boundInviteCode = "";
        if (userInfoBean != null) {
          boundInviteCode = userInfoBean.boundInviteCode ?? "";
        }
        return GestureDetector(
          onTap: () {
            // _controller.getProtocolByTitle(title);
            userController.checkPreLogin(
                source: "profile",
                actionCallback: () {
                  Get.toNamed(Routes.inviteFriendCodePage, arguments: {
                    "boundInviteCode": boundInviteCode,
                  });
                });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 17, bottom: 17),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: ByColorUtil.colorL1,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset("assets/home/share_sales/qr_code.png",
                        width: 18, height: 18, fit: BoxFit.fill),
                    const SizedBox(width: 6),
                    Text(
                      inviteName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: ByColorUtil.colorF1,
                      ),
                    ),
                  ],
                ),
                Image.asset('assets/profile/profile_right-icon.png',
                    width: 12, height: 12, fit: BoxFit.fill),
              ],
            ),
          ),
        );
      }
    }

    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColorUtil.colorBg1,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 455,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/profile/profile_top_bg${AssetConst.springFestival()}.png'),
                      fit: BoxFit.cover,
                      opacity: 0.6,
                    ),
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 44),
                    _userAvatar(),
                    if (_controller.userInfo?.isVip == 1)
                      const SizedBox(height: 16),
                    _mainContent(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
