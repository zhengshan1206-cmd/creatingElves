/*
 * @Author: cold-x
 * @Date: 2025-06-16 10:48:40
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-02-24 18:13:46
 * @FilePath: /fastcreationmaster/lib/home/long_novel/view/novel_home_view.dart
 * @Description: 小说首页
 */

import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/core/service/words.dart';
import 'package:fast_creation_master/core/util/clipboard.dart';
import 'package:fast_creation_master/core/widget/view/scroll_text_view.dart';
import 'package:fast_creation_master/home/first_create/fake_chapter_list_view.dart';
import 'package:fast_creation_master/home/long_novel/controller/novel_home_controller.dart';
import 'package:fast_creation_master/home/long_novel/view/chapter_list_view.dart';
import 'package:fast_creation_master/core/widget/view/provider_page_tracker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../core/widget/view/by_button.dart';
import '../../../global/other/event_tracking/event_tracking.dart';
import '../../../global/routes/app_pages.dart';
import '../../../global/ui/colors.dart';
import '../bean/novel_bean.dart';
import '../controller/brief_detail_provider.dart';
import '../page/novel_brief_page.dart';
import 'novel_manager_view.dart';

class NovelHomeView extends StatefulWidget {
  const NovelHomeView({super.key});

  @override
  State<NovelHomeView> createState() => _NovelHomeViewState();
}

class _NovelHomeViewState extends State<NovelHomeView> {
  final NovelHomeController controller = Get.find<NovelHomeController>();
  bool _isExpanded = false;
  final userController = Get.find<UserController>();


  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      controller: controller.refreshController,

      ///分两个接口是为了防止小说被爬
      // onRefresh: () {
      //   controller.loadData();
      // },
      onLoad: () {
        controller.source == NovelHomeSourceType.normal
            ? controller.fetchNovelInfoList(isReverse: controller.reverse.value)
            : controller.fetchSquareNovelInfoList(
                isReverse: controller.reverse.value);
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderView(),
            if (controller.source == NovelHomeSourceType.normal)
              _buildOutlineView(),
            if (controller.source == NovelHomeSourceType.normal)
              SizedBox(
                height: 12.w,
              ),
            _buildChapterView(),
          ],
        ),
      ),
    );
  }

  ///小说章节
  Widget _buildChapterView() {
    NovelBean? novelBean = controller.novelBean.value;
    if (novelBean == null) {
     return const SizedBox();
    }

    Get.log("===小说===${controller.novelBean.toJson()}");
    return Obx(
      () => (controller.novelBean.value!.isTryOut==1&&controller.novelBean.value!.isConsume==false)
          ? const FakeChapterListView()
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Obx(() => ChapterListView(
                    length: controller.itemList.length,
                    itemList: controller.itemList,
                    reverse: controller.reverse.value,

                    ///正反序列
                    reverseAction: (reverse) {
                      controller.pageHelper.resetPage();
                      if (controller.source == NovelHomeSourceType.normal) {
                        controller.fetchNovelInfoList(isReverse: reverse);
                      } else {
                        controller.fetchSquareNovelInfoList(isReverse: reverse);
                      }
                    },

                    ///点击进入章节详情
                    action: (p0, p1) {
                      Get.log("==arguments== ${Get.arguments}");
                      Get.find<UserController>().checkPreLogin(
                        source: 'novel_home',
                        actionCallback: () {
                          controller.gotoNovelInfoPage(
                            p0.id!,
                            isSquare:
                                controller.source != NovelHomeSourceType.normal,
                            isGuide:
                                controller.source == NovelHomeSourceType.guide,
                            stage: Get.arguments["stage"],
                          );
                        },
                      );
                    },
                  ))),
    );
  }

  ///生成头部视图
  Widget _buildHeaderView() {
    return SizedBox(
      width: double.infinity,
      height: _isExpanded ? 400.w : 295.w,
      child: Obx(() => Stack(
            children: [
              Positioned(
                left: 12.w,
                right: 12.w,
                bottom: 12.w,
                top: 32.w,
                child: Opacity(
                  opacity: 0.35,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.w),
                    child: Image.asset(
                      'assets/home/novel/icon_novel_home_bg.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                  left: 12.w,
                  right: 12.w,
                  bottom: 12.w,
                  top: 32.w,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.w),
                        border: Border.all(
                          width: 1,
                          color: Colors.white.withOpacity(0.1),

                          ///ui上的透明度0.2，感觉边框太亮了
                        )),
                  )),

              ///引导页背景图
              if (controller.source == NovelHomeSourceType.guide)
                Positioned(
                  left: 12.w,
                  right: 12.w,
                  top: 32.w,
                  child: Opacity(
                    opacity: 0.35,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.w),
                      child: Image.asset(
                        'assets/home/novel/icon_novel_home_bg_${controller.guideNovelBean.value?.platform == 1 ? '1' : '2'}.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),

              ///封面图
              Positioned(
                  left: 30.w,
                  top: 10.w,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.w),
                    child: Container(
                      width: 100.w,
                      height: 133.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      child: Stack(
                        children: [
                          GestureDetector(
                            ///重新生成封面
                            onTap: () {
                              // 灵感生成完成后才能修改封面
                              if (controller.source !=
                                  NovelHomeSourceType.normal) {
                                return;
                              }
                              if (controller.novelBean.value!.stage! >= 4) {
                                controller.redrawNovelCover();
                              } else {
                                BotToast.showText(text: '灵感生成完成后才能修改封面');
                              }
                            },
                            child: NovelCoverView(
                              cover: controller.novelBean.value?.cover,
                              title: '',
                              // controller.source == NovelHomeSourceType.guide
                              //     ? ''
                              //     : controller.novelBean.value?.title,
                              radio: 0.6,
                            ),
                          ),
                          if (controller.source == NovelHomeSourceType.normal)
                            Positioned(
                                bottom: 2.w,
                                left: 2.w,
                                child: GestureDetector(
                                  onTap: () {
                                    controller.manager.updateNovelStatus();

                                    ///管理
                                    Get.bottomSheet(
                                      NovelManagerView(),
                                    );
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    width: 90.w,
                                    height: 30.w,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          width: 48.w,
                                          height: 20.w,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(10.w),
                                          ),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 4.w,
                                              ),
                                              Image.asset(
                                                'assets/home/novel/btn_novel_manage.png',
                                                width: 12.w,
                                                height: 12.w,
                                              ),
                                              SizedBox(
                                                width: 2.w,
                                              ),
                                              ByWidgetsUtil.commonText(
                                                  text: '管理',
                                                  textColor:
                                                      ByColorUtil.colorF1,
                                                  fontSize: 10.sp),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                        ],
                      ),
                    ),
                  )),

              ///顶部提示词小圆角
              if (controller.source == NovelHomeSourceType.guide &&
                  controller.guideNovelBean.value!.topPrompt!.isNotEmpty)
                Positioned(
                    left: 30.w,
                    top: 27.w,
                    child: SizedBox(
                      width: 10.w,
                      height: 10.w,
                      child: Image.asset(
                        'assets/home/novel/icon_topleft_red_5.png',
                        width: 10.w,
                        height: 10.w,
                      ),
                    )),

              ///顶部平台提示词
              if (controller.source == NovelHomeSourceType.guide &&
                  controller.guideNovelBean.value!.topPrompt!.isNotEmpty)
                Positioned(
                  left: 30.w,
                  top: 10.w,
                  child: Container(
                      constraints: BoxConstraints(maxWidth: 100.w),
                      height: 18.w,
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFFFE5024), Color(0xFFFF9A81)]),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8.w),
                            topRight: Radius.circular(8.w),
                            bottomRight: Radius.circular(8.w),
                          )),
                      child: ByWidgetsUtil.commonText(
                          text:
                              controller.guideNovelBean.value?.topPrompt ?? '',
                          textColor: ByColorUtil.colorF1,
                          fontSize: 11.sp)),
                ),

              ///小说字数
              if (controller.source != NovelHomeSourceType.guide)
                Positioned(
                    right: 12.w,
                    top: 32.w,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 1.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20.w),
                          bottomLeft: Radius.circular(20.w),
                        ),
                        color: ByColorUtil.colorC1,
                      ),
                      child: ByWidgetsUtil.commonText(
                          fontSize: 12,
                          textColor: Colors.black,
                          text:
                              '${WordsService.wordsDisplay('${controller.novelBean.value?.realityWords}', unit: '万')}字'),
                    )),

              Positioned(
                left: 145.5.w,
                top: 55.w,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: 210.w,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ///标题
                      AutoScrollText(
                        controller.manager.title.value,
                        style: const TextStyle(
                          fontSize: 25,
                          color: ByColorUtil.colorF1,
                        ),
                      ),
                      // ByWidgetsUtil.commonText(
                      //   fontSize: 25,
                      //   textColor: Colors.white,
                      //   text: controller.manager.title.value),
                      SizedBox(
                        height: 5.w,
                      ),

                      ///标签
                      SizedBox(
                          width: 210.w,
                          height: 30.w,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount:
                                  controller.novelBean.value!.tags!.length,
                              itemBuilder: (context, index) {
                                final String text =
                                    controller.novelBean.value!.tags![index];
                                return Padding(
                                  padding: EdgeInsets.only(
                                      left: index == 0 ? 0 : 3, right: 3),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w, vertical: 6.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.16),
                                      borderRadius: BorderRadius.circular(8.w),
                                    ),
                                    child: ByWidgetsUtil.commonText(
                                        fontSize: 12,
                                        textColor: Colors.white,
                                        text: text),
                                  ),
                                );
                              })),
                      SizedBox(
                        height: 5.w,
                      ),

                      ///断更小说
                      if (controller.source == NovelHomeSourceType.normal &&
                          controller.novelBean.value?.stage != 10)
                        GestureDetector(
                          onTap: () {
                            if (!controller.isPaused()) {
                              EventTracking.reportDataPoint(
                                pageTag: 'myworks_detail_update_btn',
                                operateType: 'click',
                                funcDetailImg: '',
                                funcDetailTag: controller.novelID.toString(),
                              );
                              controller.pauseNovel();
                            }
                          },
                          child: !controller.isPaused()
                              ? Text(
                                  '不满意，断更小说',
                                  style: TextStyle(
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    decorationColor:
                                        ByColorUtil.colorF1.withOpacity(0.5),
                                    decorationThickness: 2,
                                    color: ByColorUtil.colorF1.withOpacity(0.5),
                                  ),
                                )
                              : ByWidgetsUtil.commonText(
                                  fontSize: 12,
                                  textColor: ByColorUtil.colorG4,
                                  text: '已断更'),
                        )
                    ],
                  ),
                ),
              ),

              ///简介
              Positioned(
                  top: 153.w,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.w),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 18.w),
                              child: ByWidgetsUtil.commonText(
                                  fontSize: 15,
                                  textColor: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  text: '简介'),
                            ),

                            ///引导页进入的简介复制
                            if (controller.source == NovelHomeSourceType.normal)
                              Padding(
                                padding: EdgeInsets.only(right: 18.w),
                                child: Container(
                                  height: 24.w,
                                  padding:
                                      EdgeInsets.only(left: 9.w, right: 9.w),
                                  child: ByButton.gradientImageBtn(
                                      padding: EdgeInsets.zero,
                                      title: '复制简介',
                                      bgColor: Colors.transparent,
                                      textColor: ByColorUtil.colorF2,
                                      fontSize: 13,
                                      image:
                                          'assets/home/novel/btn_novel_home_copy.png',
                                      onClick: () {
                                        ///复制简介
                                        ClipboardManager.clip(controller
                                            .novelBean.value?.introduce);
                                      }),
                                ),
                              ),
                            const Spacer(),

                            ///
                            ///小说灵感进入
                            if (controller.source == NovelHomeSourceType.normal)
                              Padding(
                                padding: EdgeInsets.only(right: 18.w),
                                child: Container(
                                  height: 24.w,
                                  width: 82.w,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.w),
                                      border: Border.all(
                                          width: 1,
                                          color: ByColorUtil.colorC1)),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 12.w,
                                      ),
                                      ByButton.gradientBtn(
                                          padding: EdgeInsets.zero,
                                          title: '小说灵感',
                                          bgColor: Colors.transparent,
                                          textColor: ByColorUtil.colorC1,
                                          fontSize: 12.sp,
                                          onClick: () {
                                            ///进入灵感页
                                            final provider =
                                                BriefDetailProvider();
                                            ByNavRouterUtils.push(
                                              Get.context!,
                                              trackProviderPage(
                                                pageId: '/novel_brief_page',
                                                widget: ChangeNotifierProvider(
                                                  create: (context) => provider,
                                                  child: NovelBriefPage(
                                                    novelID: controller.novelID,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                      SizedBox(
                                        width: 4.w,
                                      ),
                                      Image.asset(
                                        'assets/home/novel/icon_novel_detail.png',
                                        width: 10.w,
                                        height: 10.w,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(
                          height: 12.w,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 18.w, right: 18.w),
                          child: ExpandableText(
                            text: controller.novelBean.value?.introduce ?? '',
                            maxLines: 3,
                            onExpand: (p0) {
                              setState(() {
                                _isExpanded = p0;
                              });
                            },
                          ),
                          // child: ByWidgetsUtil.commonText(
                          //         fontSize: 14,
                          //         textColor: ByColorUtil.colorF1,
                          //         maxLines: 3,
                          //         text: controller.novelBean.value?.introduce ?? ''),
                        ),
                      ],
                    ),
                  ))
            ],
          )),
    );
  }

  ///生成中部大纲页
  Widget _buildOutlineView() {
    return GestureDetector(
      onTap: () {

        if(controller.novelBean.value!=null){
          if (controller.novelBean.value!.isTryOut==1&&controller.novelBean.value!.isConsume==false){
            userController.checkPreLogin(
              source: 'novel_manage',
              actionCallback: () {
                userController.jumpToPayPage(source: 'novel_manage');
              },
            );
            return;
          }
        }

        Get.toNamed(Routes.novelCreateOutline,
            arguments: {'novelID': controller.novelID})?.then((_) {
          controller.loadData();
        });

      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Container(
          height: 44.w,
          decoration: BoxDecoration(
            color: ByColorUtil.colorBg2,
            borderRadius: BorderRadius.circular(10.w),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 12.w,
              ),
              Image.asset(
                'assets/home/novel/icon_novel_home_outline.png',
                width: 16.w,
                height: 16.w,
              ),
              SizedBox(
                width: 4.0.w,
              ),
              ByWidgetsUtil.commonText(
                text: '章节大纲',
                textColor: Colors.white,
                fontSize: 15,
              ),
              const Spacer(),
              Obx(() => _setOutlineStatus(controller.novelBean.value!.stage!)),
              SizedBox(
                width: 10.0.w,
              ),
              Image.asset(
                'assets/home/novel/btn_novel_home_outline.png',
                width: 8.w,
                height: 8.w,
              ),
              SizedBox(
                width: 12.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _setOutlineStatus(int stage) {
    if (stage == 5) {
      return const GenerateProgressView(
        progress: -1,
      );
    } else if (stage == 6) {
      return const GenerateFailedView();
    } else {
      return Container();
    }
  }
}

///生成失败
class GenerateFailedView extends StatelessWidget {
  const GenerateFailedView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/global/common/icon_novel_warning.png',
          width: 16.w,
          height: 16.w,
        ),
        SizedBox(
          width: 4.w,
        ),
        ByWidgetsUtil.commonText(textColor: ByColorUtil.colorG4, text: '生成失败'),
        SizedBox(
          width: 4.w,
        ),
        Image.asset(
          'assets/global/common/icon_novel_detail_error.png',
          width: 14.w,
          height: 14.w,
        ),
      ],
    );
  }
}

///生成中的进度
class GenerateProgressView extends StatelessWidget {
  const GenerateProgressView(
      {super.key, this.progressText = '生成中 ', this.progress = 0});
  final int? progress;
  final String progressText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CupertinoActivityIndicator(
          color: ByColorUtil.colorC1,
          radius: 7.w,
        ),
        SizedBox(
          width: 10.0.w,
        ),
        ByWidgetsUtil.commonText(
            text: progress! < 0 ? progressText : '$progressText $progress%',
            textColor: ByColorUtil.colorC1),
      ],
    );
  }
}

///小说封面图
class NovelCoverView extends StatelessWidget {
  const NovelCoverView({
    super.key,
    this.cover,
    this.title = '',
    this.radio = 1.0,
  });

  ///封面
  final String? cover;

  ///标题
  final String? title;

  ///缩放比
  final double? radio;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
            child: CachedNetworkImage(
          imageUrl: cover ?? '',
          // placeholder: (context, url) => const CircularProgressIndicator(),
          // errorWidget: (context, url, error) {
          //   return Image.asset(
          //       'assets/home/novel/icon_novel_cover_default.png');
          // },
          fit: BoxFit.cover,
        )),
        // Positioned(
        //     top: radio! * 30.w,
        //     left: 0,
        //     right: 0,
        //     child: Padding(
        //       padding: EdgeInsets.symmetric(horizontal: 12.w),
        //       child: ByWidgetsUtil.commonText(
        //           maxLines: 2,
        //           textColor: const Color(0xFF576367),
        //           fontSize: 18 * radio!,
        //           fontFamily: 'AlimamaShuHeiTi',
        //           fontWeight: FontWeight.w500,
        //           text: title!),
        //     ))
      ],
    );
  }
}

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final String expandText;
  final String collapseText;
  final Function(bool)? onExpand;

  const ExpandableText(
      {super.key,
      required this.text,
      this.maxLines = 3,
      this.expandText = '【查看更多】',
      this.collapseText = '收起',
      this.onExpand});

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: 14,
      color: ByColorUtil.colorF1,
    );

    // 创建一个TextPainter来计算文本行数
    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: textStyle),
      maxLines: widget.maxLines,
      textDirection: TextDirection.ltr,
    );
    painter.layout(maxWidth: MediaQuery.of(context).size.width - 24.w - 36.w);

    // 判断文本是否需要截断
    final needsTruncation = painter.didExceedMaxLines;

    if (!needsTruncation || _expanded) {
      return Column(
        children: [
          SizedBox(
            height: 140.w,
            child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  widget.text,
                  style: textStyle,
                  maxLines: 9999,
                )),
          ),
          SizedBox(
            height: 8.w,
          ),
          GestureDetector(
            onTap: () => setState(() {
              _expanded = !_expanded;
              widget.onExpand?.call(_expanded);
            }),
            child: SizedBox(
              height: 24.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ByWidgetsUtil.commonText(
                      textColor: ByColorUtil.colorF1, text: '收起'),
                  SizedBox(
                    width: 4.w,
                  ),
                  AnimatedRotation(
                    turns: 0.5,
                    duration: const Duration(milliseconds: 0),
                    child: Image.asset(
                      'assets/home/novel/btn_novel_create_tags_more.png',
                      width: 12.w,
                      height: 12.w,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // 计算截断位置
    final endIndex = painter
        .getPositionForOffset(
          Offset(
            painter.width -
                textStyle.fontSize! * ('...${widget.expandText}'.length),
            double.infinity,
          ),
        )
        .offset;

    // final painterExpanded = TextPainter(
    //   text: TextSpan(text: '...${widget.expandText}', style: textStyle),
    //   maxLines: 1,
    //   textDirection: TextDirection.ltr,
    // );
    // painterExpanded.layout(maxWidth:  double.infinity);
    // print('____________${textStyle.fontSize! * ('...${widget.expandText}'.length)}====>>>>${painter.width}.......${painterExpanded.width}');

    return GestureDetector(
      onTap: () => setState(() {
        _expanded = !_expanded;
        widget.onExpand?.call(_expanded);
      }),
      child: Text.rich(
        TextSpan(
          text: '${widget.text.substring(0, endIndex)}...',
          style: textStyle,
          children: [
            TextSpan(
              text: widget.expandText,
              style: const TextStyle(color: ByColorUtil.colorC1, fontSize: 14),
            ),
          ],
        ),
        maxLines: widget.maxLines,
        // overflow: TextOverflow.clip,
      ),
    );
  }
}
