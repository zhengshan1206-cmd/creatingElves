import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:fast_creation_master/home/share_sales/controller/reward_sharing_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fast_creation_master/core/widget/page/base_page.dart';
import 'package:fast_creation_master/home/share_sales/page/page.dart';

///小说分享后的的奖励-分享奖励
// ignore: must_be_immutable
class RewardSharingPage extends BasePage {
  final String pageTitle;

  RewardSharingPage({
    super.key,
    this.pageTitle = "我的奖励",
  }) {
    _controller = Get.find<RewardSharingController>();
  }

  late final RewardSharingController _controller;
  final userController = Get.find<UserController>();

  @override
  String get title => pageTitle;

  @override
  bool get hasAppBar => true;

  @override
  Widget buildBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        children: [
          _withdrawModule(),
          SizedBox(height: 12.w),
          Expanded(
            child: _listModule(),
          ),
        ],
      ),
    );
  }

  ///提现模块
  Widget _withdrawModule() {
    return Column(
      children: [
        Container(
          width: 1.sw,
          padding:
              EdgeInsets.only(left: 16.w, right: 16.w, top: 14.w, bottom: 8.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1F24),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.w),
              topRight: Radius.circular(10.w),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ByWidgetsUtil.commonText(
                text: "可提现(元)",
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                textColor: Colors.white,
              ),
              SizedBox(height: 10.w),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ByWidgetsUtil.commonText(
                    text: "0.00",
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    textColor: const Color(0xFF98FC4A),
                    fontFamily: 'AlimamaShuHeiTi',
                  ),
                  Container(
                    width: 74.w,
                    height: 34.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(34.w),
                      gradient: ByColorUtil.colorG1(),
                    ),
                    child: Center(
                      child: ByWidgetsUtil.commonText(
                        text: "去提现",
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        textColor: ByColorUtil.colorF7,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          height: 34.w,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10.w),
              bottomRight: Radius.circular(10.w),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFC8DBFF).withOpacity(0.2), // 5%
                Color(0xFFBFE0FF).withOpacity(0.2), // 70%
                Color(0xFF82D7FF).withOpacity(0.2), // 100%
              ],
              stops: [0.05, 0.70, 1.0],
            ),
          ),
          child: Row(
            children: [
              ByWidgetsUtil.commonText(
                text: "我的字数包",
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                textColor: Color(0xFFA0A0A7),
              ),
              SizedBox(width: 4.w),
              ByWidgetsUtil.commonText(
                text: "2000",
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                textColor: Colors.white,
              ),
            ],
          ),
        )
      ],
    );
  }

  ///标题模块
  Widget _titleModule() {
    return GetBuilder<RewardSharingController>(
      builder: (c) {
        return Container(
          width: 1.sw,
          height: 44.w,
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              ProfitTabItemView(
                text: "字数奖励明细",
                isSelected: c.currentTabIndex == 0,
                showRightIcon: false,
                onClick: () => _controller.switchTab(0),
              ),
              SizedBox(width: 16.w),
              ProfitTabItemView(
                text: "现金奖励明细",
                showRightIcon: false,
                isSelected: c.currentTabIndex == 1,
                onClick: () => _controller.switchTab(1),
              ),
            ],
          ),
        );
      },
    );
  }

  ///列表模块
  Widget _listModule() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.w),
      decoration: BoxDecoration(
        color: const Color(0XFF1E1F24),
        borderRadius: BorderRadius.circular(10.w),
      ),
      child: Column(
        children: [
          // 头部标签
          _titleModule(),
          // 列表切换区域
          Expanded(
            child: GetBuilder<RewardSharingController>(
              builder: (c) {
                return IndexedStack(
                  index: c.currentTabIndex,
                  children: const [
                    _WordRewardList(),
                    _CashRewardList(),
                  ],
                );
              },
            ),
          ),
          SizedBox(
            child: ByWidgetsUtil.commonText(
              text: "- 仅显示最近7天的奖励明细 -",
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              textColor: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}

/// 字数奖励列表（占位，后续接入真实数据）
class _WordRewardList extends StatelessWidget {
  const _WordRewardList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      children: [
        SizedBox(height: 10.w),
        Center(
          child: Image.asset(
            "assets/home/share_sales/small_no_data.png",
            width: 90.w,
            height: 90.w,
          ),
        ),
        Center(
          child: ByWidgetsUtil.commonText(
            text: "暂无数据",
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            textColor: Colors.white.withOpacity(0.3),
          ),
        ),
      ],
    );
  }
}

/// 现金奖励列表（占位，后续接入真实数据）
class _CashRewardList extends StatelessWidget {
  const _CashRewardList();

  ///列表item
  Widget _itemView() {
    return Container(
      margin: EdgeInsets.only(bottom: 12.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ByWidgetsUtil.commonText(
                  text: "呃呃打算的",
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  textColor: Colors.white),
              SizedBox(height: 6.w),
              ByWidgetsUtil.commonText(
                  text: "2025-10-30 10:00:00",
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  textColor: Colors.white.withOpacity(0.5)),
            ],
          ),
          ByWidgetsUtil.commonText(
              text: "+10000 字数",
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              textColor: Color(0XFF00CB64)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ...List.generate(10, (index) => _itemView()),
        SizedBox(height: 10.w),
        Center(
          child: Image.asset(
            "assets/home/share_sales/small_no_data.png",
            width: 90.w,
            height: 90.w,
          ),
        ),
        Center(
          child: ByWidgetsUtil.commonText(
            text: "暂无数据",
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            textColor: Colors.white.withOpacity(0.3),
          ),
        ),
      ],
    );
  }
}
