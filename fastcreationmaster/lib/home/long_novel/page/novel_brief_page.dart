/*
 * @Author: cold-x
 * @Date: 2025-06-16 20:30:05
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-03-02 15:20:21
 * @FilePath: /fastcreationmaster/lib/home/long_novel/page/novel_brief_page.dart
 * @Description: 灵感生成页面
 */

import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/util/by_screen_utils.dart';
import 'package:fast_creation_master/core/widget/view/bottom_view.dart';
import 'package:fast_creation_master/core/widget/view/by_button.dart';
import 'package:fast_creation_master/core/widget/view/loading_dialog.dart';
import 'package:fast_creation_master/core/widget/view/muti_status_view.dart';
import 'package:fast_creation_master/core/widget/view/svga_player.dart';
import 'package:fast_creation_master/global/other/novel_words/controller/words_controller.dart';
import 'package:fast_creation_master/home/first_create/fake_progress_view.dart';
import 'package:fast_creation_master/home/long_novel/controller/brief_detail_provider.dart';
import 'package:fast_creation_master/home/long_novel/controller/novel_home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../core/controller/base_record_controller.dart';
import '../../../core/controller/user_controller.dart';
import '../../../core/service/data_service.dart';
import '../../../core/widget/view/progress_view.dart';
import '../../../global/other/event_tracking/event_tracking.dart';
import '../../../global/routes/app_pages.dart';
import '../../../global/ui/colors.dart';
import '../view/create_step_view.dart';
import '../view/novel_stream_view.dart';

///灵感生成页面
// ignore: must_be_immutable
class NovelBriefPage extends StatefulWidget {
  const NovelBriefPage({super.key, required this.novelID});

  final int novelID;

  ///小说id

  @override
  State<NovelBriefPage> createState() => _NovelBriefPageState();
}

class _NovelBriefPageState extends State<NovelBriefPage> {
  late WordsController words = Get.find<WordsController>();
  bool showFirstAnimate = false;

  ///赚钱动效是否显示首次动画效果
  ///短故事小说深度思考是否是展开模式
  bool isExpanded = true;

  @override
  void initState() {
    final provider = context.read<BriefDetailProvider>();
    provider.maxWords = words.words!.brief!;
    provider.novelID = widget.novelID;

    if (provider.source == NovelHomeSourceType.guide) {
      provider.fetchRandomBrief();
      DataService.onEvent('guide_novel_brief', {'novelID': provider.novelID});
      EventTracking.reportDataPoint(
          pageTag: 'accept_creative_loading_page',
          operateType: 'view',
          funcDetailImg: '',
          funcDetailTag: provider.novelID.toString(),
          extra: {'source': 2}
        );

      /// 更新归因信息
      if (provider.source == NovelHomeSourceType.guide) {
        Future.delayed(const Duration(seconds: 2), () {
          Get.find<UserController>().reloadUserInfo(reloadUse: false);
        });
    }
    } else {
      provider.fetchNovelDetail(provider.novelID!);
      DataService.onEvent('novel_brief', {
        'novelID': provider.novelID,
        'type':
            provider.source != NovelHomeSourceType.normal ? 'square' : 'normal'
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    Get.find<UserController>().getCouldUse();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<BriefDetailProvider>();
    return Scaffold(
      backgroundColor: provider.source == NovelHomeSourceType.guide
          ? Colors.transparent
          : ByColorUtil.colorBg1,
      extendBodyBehindAppBar: provider.source == NovelHomeSourceType.guide,
      appBar: buildAppBar(context),
      body: provider.source == NovelHomeSourceType.guide
          ? Stack(
              children: [
                Positioned(
                    child:
                        Image.asset('assets/home/novel/icon_novel_top_bg.png')),
                SafeArea(child: buildBody(context)),
              ],
            )
          : buildBody(context),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    final provider = context.read<BriefDetailProvider>();
    return AppBar(
        backgroundColor: Colors.transparent,
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            ///引导页进入首页
            if (provider.source == NovelHomeSourceType.guide) {
              provider.isBackToMain = true;
              Get.offAllNamed(Routes.main);
              EventTracking.reportDataPoint(
                  pageTag: 'accept_creative_loading_close_btn',
                  operateType: 'click',
                  funcDetailImg: '',
                  funcDetailTag: provider.novelID.toString(),
                  extra: {'source': 2});
            } else {
              Get.back();
            }
          },
          child: provider.source == NovelHomeSourceType.guide
              ? Container(
                  width: 56,
                  height: 32,
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(7.0),
                    child: Image.asset(
                      "assets/global/common/btn_close.png",
                      width: 32,
                      height: 32,
                    ),
                  ),
                )
              : Container(
                  width: 56,
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(7.0),
                    child: Image.asset(
                      "assets/global/common/btn_back.png",
                      width: 16,
                      height: 16,
                    ),
                  ),
                ),
        ),
        title:
            Consumer<BriefDetailProvider>(builder: (context, provider, child) {
          return ByWidgetsUtil.commonText(
              text: provider.pageTitle,
              textColor: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w500);
        }));
  }

  Widget buildBody(BuildContext context) {
    return Consumer<BriefDetailProvider>(
      builder: (context, provider, child) {

       bool couldTry =  Get.find<UserController>().couldTry;
        return PopScope(
          canPop: provider.source != NovelHomeSourceType.guide,
          child: Stack(
            children: [
              // if(provider.statusType != MultiStatusType.statusContent)
              // Positioned.fill(
              //   child: Image.asset('assets/global/common/icon_loading_streaming_bg.png',
              //       fit: BoxFit.fill),
              // ),
              Positioned(
                child: MultiStatusView(
                  currentStatus: provider.statusType,
                  loadingWidget: const Center(
                    child: LoadingView(
                      loadingText: '加载中...',
                      bgColor: Colors.transparent,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Column(
                      children: [
                        ///顶部进度视图
                        if (provider.source != NovelHomeSourceType.guide &&
                            provider.novelBean != null &&
                            (provider.type != CreationType.shortStory ||
                                provider.novelBean!.stage! < 5))
                          CreateStepView(
                            type: provider.type,
                            currentStep: 0,
                          ),
                        if (provider.source != NovelHomeSourceType.guide)
                          SizedBox(
                            height: 12.w,
                          ),
                        Expanded(
                            child: provider.type == CreationType.shortStory
                                ? _buildShortStoryMDView()
                                : _buildNovelMDView()),
                        SizedBox(
                          height: 4.w,
                        ),

                        ///底部进度条
                        provider.isGenerating
                            ? _buildProgressView()
                            : provider.source == NovelHomeSourceType.guide
                                ? _buildGuideBottomView()
                                : provider.novelBean != null &&
                                        provider.showBottom
                                    ? BottomView(
                                        type: provider.type,
                                        words: words.getWords(WordsType.brief,
                                            provider.novelBean!.chaptersNum!,
                                            novelType: provider.type),
                                        nextBtnText:
                                            provider.novelBean!.stage! <= 4
                                                ? provider.type ==
                                                        CreationType.shortStory
                                                    ? '生成短故事'
                                                    : '生成大纲'
                                                : provider.type ==
                                                        CreationType.shortStory
                                                    ? '查看短故事'
                                                    : '查看大纲',

                                        ///引导页或者生成大纲后不显示字数
                                        showWords: provider.source !=
                                                NovelHomeSourceType.guide &&
                                            provider.novelBean!.stage! < 5,
                                        nextStep: () {
                                          if (provider.novelBean!.stage! <= 4) {
                                            ///字数检测
                                            if (words.isWordsEnable(
                                                WordsType.brief,
                                                provider
                                                    .novelBean!.chaptersNum!,
                                                novelType: provider.type)) {
                                              if (provider.type ==
                                                  CreationType.shortStory) {
                                                provider.createShortStory();
                                              } else {
                                                provider.createNovelOutline();
                                              }
                                            } else {
                                              Get.find<UserController>()
                                                  .jumpToPayPage(
                                                      source:
                                                          'novel_brief_words');
                                            }
                                          } else {
                                            if (provider.type ==
                                                CreationType.shortStory) {
                                              provider.gotoNovelInfoPage(
                                                  '', '');
                                            } else {
                                              Get.toNamed(
                                                  Routes.novelCreateOutline,
                                                  arguments: {
                                                    'novelID': widget.novelID
                                                  });
                                            }
                                          }
                                        },
                                      )
                                    : Container(),
                      ],
                    ),
                  ),
                ),
              ),

              ///赚钱前部动画
              provider.isGenerating &&
                      provider.source == NovelHomeSourceType.guide
                  ? Positioned(
                      bottom: 56.w + ByScreenUtils.bottomSafeHeight,
                      left: 12.w,
                      child: Offstage(
                        offstage: showFirstAnimate,
                        child: ClipRRect(
                          child: SizedBox(
                            height: 40,
                            width: 150,
                            child: SvgaPlayer(
                              url:
                                  'assets/business/svg_business_brief_front.svga',
                              fit: BoxFit.cover,
                              completeAnimate: () {
                                setState(() {
                                  showFirstAnimate = true;
                                });
                              },
                            ),
                          ),
                        ),
                      ))
                  : Container(),

              ///赚钱后部动画
              provider.isGenerating &&
                      provider.source == NovelHomeSourceType.guide
                  ? Positioned(
                      bottom: 56.w + ByScreenUtils.bottomSafeHeight,
                      left: 12.w,
                      child: Offstage(
                        offstage: !showFirstAnimate,
                        child: const ClipRRect(
                          child: SizedBox(
                            height: 40,
                            width: 150,
                            child: SvgaPlayer(
                              url:
                                  'assets/business/svg_business_brief_back.svga',
                              fit: BoxFit.cover,
                              isRepeat: true,
                            ),
                          ),
                        ),
                      ))
                  : Container(),
              if (!provider.isGenerating &&
                  provider.source == NovelHomeSourceType.guide &&
                  provider.content.isNotEmpty)
                Positioned(
                    bottom: 56.w + ByScreenUtils.bottomSafeHeight,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 308.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [
                              0,
                              84 / 308,
                              1
                            ],
                            colors: [
                              ByColorUtil.colorBg1.withOpacity(0.0),
                              ByColorUtil.colorBg1.withOpacity(0.9),
                              ByColorUtil.colorBg1.withOpacity(1.0)
                            ]),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Image.asset(
                            'assets/business/icon_guide_brief_writing.gif',
                            width: 292.w,
                            height: 114.w,
                          ),
                          SizedBox(
                            height: 12.w,
                          ),
                          RichText(
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            text: TextSpan(
                                style: TextStyle(
                                  fontFamily: 'AlimamaShuHeiTi',
                                  fontSize: 20.sp,
                                ),
                                children: const [
                                  TextSpan(
                                    text: '哇~Ai已经帮你写好超棒创意!\n 下一步',
                                    style:
                                        TextStyle(color: ByColorUtil.colorF1),
                                  ),
                                  TextSpan(
                                    text: '写小说赚钱',
                                    style:
                                        TextStyle(color: ByColorUtil.colorG4),
                                  ),
                                ]),
                          ),
                          SizedBox(
                            height: 12.w,
                          ),
                          const SizedBox(
                            width: 40,
                            height: 40,
                            child: SvgaPlayer(
                              url: 'assets/business/svga_guide_arrow.svga',
                              isRepeat: true,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(
                            height: 4.w,
                          ),
                        ],
                      ),
                    )),

              if (couldTry &&
                  (provider.source != NovelHomeSourceType.guide) &&
                  (provider.type == CreationType.novel || provider.type== CreationType.shortNovel))
                const Positioned(
                  bottom: 0,
                  child: FakeProgressView(),
                )
            ],
          ),
        );
      },
    );
  }

  ///长文、短文markdown
  Widget _buildNovelMDView() {
    final provider = context.read<BriefDetailProvider>();
    return NovelStreamView(
      showTitle: true,
      controller: provider.scrollController,
      isStreaming: provider.isGenerating,
      content: provider.content,
      showBg: provider.source == NovelHomeSourceType.guide,
      title: provider.source == NovelHomeSourceType.guide
          ? provider.guideBriefTitle
          : provider.isGenerating
              ? '小说创作中'
              : provider.novelBean?.title ?? '',
      novelID: provider.novelID,
    );
  }

  ///短故事markdown
  Widget _buildShortStoryMDView() {
    final provider = context.read<BriefDetailProvider>();
    return SingleChildScrollView(
      controller: provider.scrollController,
      child: Column(
        children: [
          if (provider.thinkingContent.isNotEmpty)
            Container(
              padding: EdgeInsets.all(12.w),
              width: double.infinity,
              height: !isExpanded ? 268.w : null,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.w),
                  gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x44CBF203), Color(0x440181FC)])),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    child: Container(
                      width: provider.isGenerating ? 101.w : 99.w,
                      height: 32.w,
                      constraints: BoxConstraints(
                        maxHeight: 660.h,
                      ),
                      decoration: BoxDecoration(
                        color: ByColorUtil.colorF1.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      child: Stack(
                        children: [
                          provider.isGenerating
                              ? Image.asset(
                                  'assets/home/novel/gif_novel_thinking.gif',
                                )
                              : Positioned(
                                  left: 12.w,
                                  child: SizedBox(
                                    height: 32.w,
                                    child: Center(
                                      child: ByWidgetsUtil.commonText(
                                          text: 'AI思考完成',
                                          fontSize: 12.sp,
                                          textColor: ByColorUtil.colorF1),
                                    ),
                                  )),
                          Positioned(
                            top: 11.w,
                            right: 12.w,
                            bottom: 11.w,
                            child: AnimatedRotation(
                              turns: isExpanded ? 0.25 : 0.75,
                              duration: const Duration(milliseconds: 200),
                              child: Image.asset(
                                'assets/global/common/arrow_right.png',
                                width: 10.w,
                                height: 10.w,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 12.w,
                  ),
                  SizedBox(
                    height: isExpanded ? null : 200.w,
                    child: Text(provider.thinkingContent.trim(),
                        maxLines: 99999,
                        style: TextStyle(
                            fontSize: 14.sp, color: ByColorUtil.colorF2)),
                  ),
                ],
              ),
            ),
          if (provider.thinkingContent.isNotEmpty)
            SizedBox(
              height: 12.w,
            ),
          if (provider.content.isNotEmpty)
            NovelStreamView(
              showTitle: false,
              showBg: false,
              isStreaming: provider.isGenerating,
              content: provider.content,
              title: provider.source == NovelHomeSourceType.guide
                  ? provider.guideBriefTitle
                  : provider.isGenerating
                      ? '小说创作中'
                      : provider.novelBean?.title ?? '',
            ),
        ],
      ),
    );
  }

  ///引导页底部按钮
  Widget _buildGuideBottomView() {
    final provider = context.read<BriefDetailProvider>();
    return BottomView(
      nextBtnText: '我要写小说赚钱',
      checkLogin: false,
      ///引导页或者生成大纲后不显示字数
      showWords: false,
      nextStep: () {
        EventTracking.reportDataPoint(
                  pageTag: 'accept_writing_money_btn',
                  operateType: 'click',
                  funcDetailImg: '',
                  funcDetailTag: provider.novelID.toString(),
                  extra: {'source': 2});
        final UserController userController = Get.find<UserController>();

        /// 审核面先登录
        if(userController.isAudit()) {
          userController.checkPreLogin(
            source: 'guide_novel_brief',
            actionCallback: () {
              userController.jumpToPayPage(
                isBackHome: true,
                source: 'guide_novel_brief',
                back: () {
                  ///引导页进入首页
                  provider.isBackToMain = true;
                  Get.offAllNamed(Routes.main);
                },
              );
            });
        }
        else {
          userController.jumpToPayPage(
                isBackHome: true,
                source: 'guide_novel_brief',
                back: () {
                  ///引导页进入首页
                  provider.isBackToMain = true;
                  Get.offAllNamed(Routes.main);
                },
              );
        }
      },
    );
  }

  Widget _buildProgressView() {
    final provider = context.read<BriefDetailProvider>();
    return Container(
        height: 56.w + ByScreenUtils.bottomSafeHeight,
        padding: EdgeInsets.only(
            top: 4.w, bottom: ByScreenUtils.bottomSafeHeight + 5.w),
        child: Row(
          children: [
            if (provider.source != NovelHomeSourceType.guide)
              ByButton.gradientImageBtn(
                title: '稍后查看',
                image: 'assets/home/novel/btn_novel_create_scan.png',
                textColor: ByColorUtil.colorC1,
                bgColor: ByColorUtil.color2E3038,
                onClick: () {
                  ///引导页进入首页
                  if (provider.source == NovelHomeSourceType.guide) {
                    provider.isBackToMain = true;
                    Get.offAllNamed(Routes.main);
                  } else {
                    Get.back();
                  }
                },
              ),
            if (provider.source != NovelHomeSourceType.guide)
              SizedBox(
                width: 12.w,
              ),
            Expanded(
                child: ProgressView(
              progress: provider.progress,
            )),
          ],
        ));
  }
}
