import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/core/service/data_service.dart';
import 'package:fast_creation_master/core/util/by_screen_utils.dart';
import 'package:fast_creation_master/core/widget/view/muti_status_view.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:fast_creation_master/global/ui/widget/byhy_video_player_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fast_creation_master/core/widget/page/base_page.dart';
import 'package:fast_creation_master/square/zone/controller/square_details_controller.dart';
import 'dart:ui';
import 'dart:math';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

///广场列表详情页面
// ignore: must_be_immutable
class SquareDetailsPage extends BasePage {
  final int id;
  final String pageTitle;

  SquareDetailsPage({
    super.key,
    this.id = 0,
    this.pageTitle = "详情",
  }) {
    _controller = Get.put(SquareDetailsController(id: id));
  }

  late final SquareDetailsController _controller;
  final userController = Get.find<UserController>();

  @override
  String get title => _controller.detailsData.value?.name ?? pageTitle;

  @override
  bool get hasAppBar => false;

  ///返回按钮
  Widget _backButton() {
    return Positioned(
      top: ByScreenUtils.topSafeHeight,
      left: 0,
      child: GestureDetector(
        onTap: () {
          Get.back();
        },
        child: Container(
            width: 56,
            height: 30,
            alignment: Alignment.center,
            child: Image.asset(
              "assets/profile/profile_left-icon.png",
              width: 16,
              height: 16,
            )),
      ),
    );
  }

  ///试看悬浮按钮 - 仅在视频模式下显示
  Widget _watchButton() {
    if (_controller.detailsData.value?.type != 2 ||
        _controller.userInfo?.isVip == 1) return const SizedBox.shrink();

    return Positioned(
      top: 98,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(30, 31, 36, 0.24),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 21,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: ByColorUtil.linearGradientMultiple(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF82D7FF),
                      const Color(0xFFBFE0FF),
                      const Color(0xFFDCC8FF),
                    ],
                    stops: const [0.1, 0.35, 0.92],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  "试看中",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ByColorUtil.colorF7,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: "可试看 ",
                      style: TextStyle(
                        fontSize: 13,
                        color: ByColorUtil.colorF1,
                      ),
                    ),
                    TextSpan(
                      text: '${_controller.detailsData.value?.lookTime ?? 10}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: ByColorUtil.colorF5,
                      ),
                    ),
                    const TextSpan(
                      text: "s  ",
                      style: TextStyle(
                        fontSize: 13,
                        color: ByColorUtil.colorF1,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Text(
                    "开通",
                    style: TextStyle(
                      fontSize: 13,
                      color: ByColorUtil.colorF1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Image.asset(
                    "assets/square/square_5.png",
                    height: 10,
                    fit: BoxFit.fitHeight,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "解锁超多变现玩法",
                    style: TextStyle(
                      fontSize: 13,
                      color: ByColorUtil.colorF1,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  ///图文列表 - 仅在图文模式下显示
  Widget _textListView() {
    if (_controller.detailsData.value?.type != 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ClipRRect(
          //   borderRadius: BorderRadius.circular(16),
          //   child: Image.network(
          //     _controller.detailsData.value?.iconUrl ?? "",
          //     width: double.infinity,
          //     // height: 200,
          //     fit: BoxFit.fitWidth,
          //     errorBuilder: (context, error, stackTrace) {
          //       return Container(
          //         width: double.infinity,
          //         height: 200,
          //         color: ByColorUtil.colorBg2,
          //         child: const Center(
          //           child: Icon(
          //             Icons.image_not_supported,
          //             color: Colors.grey,
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          // ),
          // const SizedBox(height: 10),
          // Html(
          //   data: _controller.detailsData.value?.content ?? "",
          //   style: {
          //     "body": Style(
          //       fontSize: FontSize(14),
          //       fontWeight: FontWeight.w400,
          //       color: ByColorUtil.colorF1,
          //     ),
          //   },
          HtmlWidget(
            _controller.detailsData.value?.content ?? "",
            customStylesBuilder: (element) {
              if (element.localName == 'img') {
                return {
                  'width': '100%', // 宽度占满父容器
                  'height': 'auto', // 高度自适应
                  'max-width': '100%', // 最大宽度不超过父容器
                };
              }
              return null; // 使用默认样式
            },
          ),
        ],
      ),
    );
  }

  ///视频内容 - 仅在视频模式下显示
  Widget _videoContent() {
    if (_controller.detailsData.value?.type != 2) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: 540.h,
            minHeight: 200.h,
          ),
          child: Stack(
            children: [
              VideoPlayerWidget(
                url: _controller.detailsData.value?.videoUrl ?? "",
                autoPlay: true,
                maxDuration: _controller.userInfo?.isVip == 0 &&
                        _controller.detailsData.value?.isFree == 2
                    ? Duration(
                        seconds: _controller.detailsData.value?.lookTime ?? 10)
                    : null,
                showFullScreenButton: true,
              ),
              if (_controller.userInfo?.isVip == 0 &&
                  _controller.detailsData.value?.isFree == 2)
                Positioned(
                  top: 58,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(30, 31, 36, 0.24),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 21,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: ByColorUtil.linearGradientMultiple(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF82D7FF),
                                  const Color(0xFFBFE0FF),
                                  const Color(0xFFDCC8FF),
                                ],
                                stops: const [0.1, 0.35, 0.92],
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Text(
                              "试看中",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: ByColorUtil.colorF7,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: "可试看 ",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: ByColorUtil.colorF1,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      '${_controller.detailsData.value?.lookTime ?? 10}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: ByColorUtil.colorF5,
                                  ),
                                ),
                                const TextSpan(
                                  text: "s  ",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: ByColorUtil.colorF1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              const Text(
                                "开通",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: ByColorUtil.colorF1,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Image.asset(
                                "assets/square/square_5.png",
                                height: 10,
                                fit: BoxFit.fitHeight,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                "解锁超多变现玩法",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: ByColorUtil.colorF1,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _controller.detailsData.value?.name ?? "",
                        style: const TextStyle(
                          fontSize: 17,
                          color: ByColorUtil.colorF1,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    // RichText(
                    //   text: TextSpan(
                    //     children: [
                    //       TextSpan(
                    //         text: _controller.detailsData.value?.showNumber ==
                    //                 null
                    //             ? '0'
                    //             : (_controller.detailsData.value!.showNumber >
                    //                     99999
                    //                 ? '99999+'
                    //                 : '${_controller.detailsData.value!.showNumber}'),
                    //         style: const TextStyle(
                    //           fontSize: 12,
                    //           color: ByColorUtil.colorF1,
                    //         ),
                    //       ),
                    //       const TextSpan(
                    //         text: '学习',
                    //         style: TextStyle(
                    //           fontSize: 12,
                    //           color: ByColorUtil.colorF2,
                    //         ),
                    //       )
                    //     ],
                    //   ),
                    // )
                  ],
                ),
              ),
              // Container(
              //   alignment: Alignment.topLeft,
              //   child: Text(
              //     _controller.detailsData.value?.content ?? "",
              //     style: const TextStyle(
              //       fontSize: 14,
              //       color: ByColorUtil.colorF2,
              //     ),
              //   ),
              // ),
              Container(
                alignment: Alignment.topLeft,
                child: HtmlWidget(
                  _controller.detailsData.value?.content ?? "",
                ),
              ),
              const SizedBox(height: 56),
            ],
          ),
        ),
      ],
    );
  }

  ///底部VIP提示 - 仅在图文模式下显示
  Widget _vipHint() {
    if (_controller.detailsData.value?.type != 1 ||
        _controller.userInfo?.isVip == 1 ||
        _controller.detailsData.value?.isFree == 1) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Container(
          height: 88,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                const Color(0xFF0C130B),
                const Color(0xFF0C130B),
                const Color(0x000C130B).withOpacity(0),
              ],
              stops: const [0, 0.45, 1],
            ),
          ),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                height: 88,
                color: Colors.transparent,
                padding: const EdgeInsets.only(top: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/square/square_4.png",
                      width: 32,
                      height: 18,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 4),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        begin: Alignment(0.5, -0.5),
                        end: Alignment(-0.5, 0.5),
                        transform: GradientRotation(126 * pi / 180),
                        colors: [
                          Color(0xFFFFAA45),
                          Color(0xFFFFFDFA),
                          Color(0xFFA2FFFF),
                        ],
                        stops: [0.1922, 0.5168, 0.8414],
                      ).createShader(bounds),
                      child: const Text(
                        "仅限VIP用户学习哦～",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            ///跳转付费页
            userController.checkPreLogin(
                source: 'square_detail',
                actionCallback: () {
                  DataService.onEvent('square_detail_pay_source',
                      {'id': _controller.detailsData.value?.id});
                  userController.jumpToPayPage(source: 'square_detail');
                });
          },
          child: Container(
            width: double.infinity,
            color: ByColorUtil.colorBg1,
            padding:
                const EdgeInsets.only(left: 12, right: 12, bottom: 6, top: 6),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: ByColorUtil.linearGradientMultiple(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF82D7FF),
                    const Color(0xFFBFE0FF),
                    const Color(0xFFDCC8FF),
                  ],
                  stops: const [0.1, 0.35, 0.92],
                ),
              ),
              margin: EdgeInsets.only(bottom: 12.w),
              child: const Center(
                child: Text(
                  '解锁全部课程',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: ByColorUtil.colorF7,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  ///底部按钮 - 仅在视频模式下显示
  Widget _bottomButton() {
    if (_controller.detailsData.value?.type != 2 ||
        _controller.userInfo?.isVip == 1 ||
        _controller.detailsData.value?.isFree == 1) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 12.w,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () => {
          userController.checkPreLogin(
              source: 'square_detail',
              actionCallback: () {
                DataService.onEvent('square_detail_pay_source',
                    {'id': _controller.detailsData.value?.id});
                userController.jumpToPayPage(source: 'square_detail');
              })
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          color: ByColorUtil.colorBg1,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: ByColorUtil.colorG1(),
            ),
            child: const Center(
              child: Text(
                '学习教程创作',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: ByColorUtil.colorF7,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    Get.log("arguments===> ${Get.arguments}");

    return Obx(() {
      if (_controller.showLoading.value) {
        return const Center(
            child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ByColorUtil.colorC1),
          strokeWidth: 2,
        ));
      }

      if (_controller.detailsData.value?.type == 2) {
        // 视频模式布局
        // return MultiStatusView(
        //   currentStatus: _controller.statusType.value,
        //   action: () {
        //     _controller.getStrategyGuideDetail();
        //   },
        //   child: Stack(
        //     children: [
        //       ListView(
        //         padding: EdgeInsets.zero,
        //         children: [
        //           _videoContent(),
        //         ],
        //       ),
        //       // _watchButton(),
        //       _bottomButton(),
        //       _backButton(),
        //     ],
        //   ),
        // );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light, // 状态栏白色字体
          child: Scaffold(
            backgroundColor: ByColorUtil.colorBg1,
            // 不要 appBar
            body: SafeArea(
              top: true,
              bottom: false,
              child: MultiStatusView(
                currentStatus: _controller.statusType.value,
                action: () {
                  _controller.getStrategyGuideDetail();
                },
                child: Stack(
                  children: [
                    ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _videoContent(),
                      ],
                    ),
                    // _watchButton(),
                    _bottomButton(),
                    // _backButton(),
                    // 如需自定义返回按钮，可用 Positioned 放在左上角
                    Positioned(
                      top: 10,
                      left: 15,
                      child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.asset(
                              "assets/square/close_icon.png",
                              width: 20,
                              height: 20,
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      } else {
        // 图文模式布局
        final arguments = Get.arguments;

        return Scaffold(
          backgroundColor: ByColorUtil.colorBg1,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Get.back();
              },
              child: Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                child: arguments["type"] != "xi_lie_ke"
                    ? Image.asset(
                        "assets/square/square_dialog_4.png",
                        width: 30,
                        height: 30,
                      )
                    : Image.asset(
                        "assets/profile/profile_left-icon.png",
                        width: 16,
                        height: 16,
                      ),
              ),
            ),
            title: const SizedBox.shrink(),
            centerTitle: true,
            // actions: [
            //   if (arguments["type"] == "xi_lie_ke")
            //     Row(
            //       children: [
            //         ClipRRect(
            //           borderRadius: BorderRadius.circular(20.w),
            //           child: CachedNetworkImage(
            //             imageUrl: _controller.detailsData.value!.authorAvatar,
            //             width: 20.w,
            //             height: 20.w,
            //           ),
            //         ),
            //         SizedBox(
            //           width: 6.w,
            //         ),
            //         ConstrainedBox(
            //           constraints: BoxConstraints(maxWidth: 100.w),
            //           child: ByWidgetsUtil.commonText(
            //               text: _controller.detailsData.value!.authorName,
            //               textColor: ByColorUtil.colorF2,
            //               maxLines: 1),
            //         ),
            //         SizedBox(
            //           width: 80.w,
            //         ),
            //         // GestureDetector(
            //         //   onTap: () {
            //         //     // final arguments = Get.arguments;
            //         //     // if (arguments["wechat"] != null) {
            //         //     //   Get.dialog(AddWechatDialog(
            //         //     //     wechatUrl: arguments["wechat"],
            //         //     //   ));
            //         //     // }
            //         //     userController.checkPreLogin(
            //         //         source: 'square',
            //         //         actionCallback: () {
            //         //           userController.jumpToPayPage(source: 'square');
            //         //         });
            //         //     if (userController.userInfoBean.value?.isVip == 0) {
            //         //       userController.jumpToPayPage(source: 'square');
            //         //     } else {
            //         //       ByNavRouterUtils.jumpWebViewPage(Get.context!, "微信客服",
            //         //           _controller.detailsData.value!.wechat);
            //         //     }
            //         //   },
            //         //   child: Container(
            //         //     width: 48.w,
            //         //     height: 21.h,
            //         //     decoration: BoxDecoration(
            //         //       border: Border.all(color: Color(0XFF98FC4A)),
            //         //       borderRadius: BorderRadius.circular(15.w),
            //         //     ),
            //         //     alignment: Alignment.center,
            //         //     child: Text(
            //         //       "加V",
            //         //       style: TextStyle(
            //         //         color: Color(0XFF98FC4A),
            //         //         fontSize: 12.sp,
            //         //         fontWeight: FontWeight.w800,
            //         //       ),
            //         //     ),
            //         //   ),
            //         // ),
            //         SizedBox(
            //           width: 12.w,
            //         ),
            //       ],
            //     )
            // ],
          ),
          body: MultiStatusView(
            currentStatus: _controller.statusType.value,
            action: () {
              _controller.getStrategyGuideDetail();
            },
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListView(
                    // physics: _controller.detailsData.value?.type == 1 &&
                    //         _controller.userInfo?.isVip == 0
                    //     ? const NeverScrollableScrollPhysics()
                    //     : const AlwaysScrollableScrollPhysics(),
                    physics: _controller.detailsData.value?.type == 1 &&
                            _controller.userInfo?.isVip == 0 &&
                            _controller.detailsData.value?.isFree == 2
                        ? const NeverScrollableScrollPhysics()
                        : const AlwaysScrollableScrollPhysics(),
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: Image.network(
                                _controller.detailsData.value?.authorAvatar ??
                                    "",
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 32,
                                    height: 32,
                                    color: ByColorUtil.colorBg2,
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 260.w),
                              child: ByWidgetsUtil.commonText(
                                  text: _controller
                                          .detailsData.value?.authorName ??
                                      "",
                                  textColor: ByColorUtil.colorF2,
                                  maxLines: 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _textListView(),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _vipHint(),
                ),
              ],
            ),
          ),
        );
      }
    });
  }
}
