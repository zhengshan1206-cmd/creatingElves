/*
 * @Author: cold-x
 * @Date: 2025-06-16 20:40:17
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-03-02 15:20:45
 * @FilePath: /fastcreationmaster/lib/home/long_novel/page/novel_detail_page.dart
 * @Description: 
 */

import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:fast_creation_master/core/cache/global_controller.dart';
import 'package:fast_creation_master/core/widget/view/muti_status_view.dart';
import 'package:fast_creation_master/home/long_novel/controller/chapter_list_provider.dart';
import 'package:fast_creation_master/home/long_novel/controller/novel_detail_provider.dart';
import 'package:fast_creation_master/home/long_novel/view/novel_stream_view.dart';
import 'package:fast_creation_master/home/long_novel/view/share_earn_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../core/util/by_screen_utils.dart';
import '../../../core/util/clipboard.dart';
import '../../../core/widget/view/banner_view.dart';
import '../../../core/widget/view/by_button.dart';
import '../../../global/ui/colors.dart';
import '../view/chapter_list_view.dart';

///长文详情页面
class NovelDetailPage extends StatefulWidget {
  const NovelDetailPage({super.key});

  @override
  State<NovelDetailPage> createState() => _NovelDetailPageState();
}

class _NovelDetailPageState extends State<NovelDetailPage> {
  // 滑动偏移量（用于视觉反馈）
  double _offsetX = 0;
  // 滑动开始X坐标
  double _startX = 0;

  @override
  void initState() {
    super.initState();
    final provider = context.read<NovelDetailProvider>();
    provider.startListening();

    provider.statusType = MultiStatusType.statusLoading;
    if (provider.isSquare) {
      provider.fetchSquareNovelInfoList();
      provider.fetchSquareNovelInfo();
    } else {
      provider.delayToLoad();
    }
    provider.loadBanners(postion: 102);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColorUtil.colorBg1,
      // appBar: buildAppBar(context),
      body: Stack(
        children: [
          Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: buildBody(context),
              ),
            ],
          ),
          // _buildShareEarnView(context),
        ],
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Get.back();
        },
        child: Container(
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
      title: Consumer<NovelDetailProvider>(
        builder: (context, provider, child) {
          return ByWidgetsUtil.commonText(
              text: provider.chapterBean != null
                  ? '第${provider.chapterBean?.index}章'
                  : '',
              textColor: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w500);
        },
      ),
      actions: const [ShareEarnView()],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 56 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A), // Dark gray background
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Get.back();
            },
            child: Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              child: Image.asset(
                "assets/global/common/btn_back.png",
                width: 16,
                height: 16,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Consumer<NovelDetailProvider>(
              builder: (context, provider, child) {
                return Center(
                  child: ByWidgetsUtil.commonText(
                      text: provider.chapterBean != null
                          ? '第${provider.chapterBean?.index}章'
                          : '',
                      textColor: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w500),
                );
              },
            ),
          ),
          // const ShareEarnView(),
        ],
      ),
    );
  }

  Widget _buildShareEarnView(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 44,
      right: 6,
      child: const ShareEarnTipView(),
    );
  }

  Widget buildBody(BuildContext context) {
    return Consumer<NovelDetailProvider>(builder: (context, provider, child) {
      bool isCompleted = false;
      if (provider.stage == 10) {
        isCompleted = true;
      }

      Get.log(
          "isCompleted===> ${provider.stage}  currentChapter===> ${provider.currentChapter} chapterNum===> ${provider.chapterNum} isGenerating==> ${provider.isGenerating} ");
      return MultiStatusView(
        currentStatus: provider.statusType,
        action: () {
          provider.reloadData();
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Column(
            children: [
              SizedBox(
                height: 12.w,
              ),
              Expanded(
                child: GestureDetector(
                    // 滑动开始
                    onHorizontalDragStart: (details) {
                      _startX = details.globalPosition.dx;
                      _offsetX = 0; // 重置偏移
                    },

                    // 滑动过程中更新偏移
                    onHorizontalDragUpdate: (details) {
                      // 计算当前偏移（限制范围，避免过度滑动）
                      _offsetX = details.globalPosition.dx - _startX;
                      if (_offsetX > 100) _offsetX = 100;
                      if (_offsetX < -100) _offsetX = -100;
                    },

                    // 滑动结束判断
                    onHorizontalDragEnd: (details) {
                      // 计算总滑动距离
                      final distance = _offsetX;
                      // 计算滑动速度（水平方向）
                      final velocity = details.velocity.pixelsPerSecond.dx;

                      // 阈值判断：距离≥80 或 速度≥300 视为有效滑动
                      if (distance >= 80 || velocity >= 300) {
                        // _handleSwipeRight();
                        provider.toggleChapter(false);
                      } else if (distance <= -80 || velocity <= -300) {
                        // _handleLeft();
                        provider.toggleChapter(true);
                      }

                      // 复位偏移
                      _offsetX = 0;
                    },
                    child: NovelStreamView(
                      isMarkdown: false,
                      controller: provider.scrollController,
                      isStreaming: provider.isGenerating,
                      isGeneratingNext: provider.isGeneratingNextChapter,
                      content: provider.content,
                      title: provider.chapterBean?.title,
                      isCompleted: isCompleted,
                      aiContinueWriteEvent: () {
                        provider.aiContinueWriteEvent(provider.novelID);
                      },
                      novelID: provider.novelID,
                      isLastChapter:
                          (provider.currentChapter + 1) == provider.chapterNum,
                    )),
              ),
              SizedBox(
                height: 12.w,
              ),
              if (provider.bannerList.isNotEmpty &&
                  !GlobalController.instance.banner.novelDetailBanner)
                BannerView(
                  bannerList: provider.bannerList,
                  source: 'novel',
                  close: () {
                    setState(() {
                      GlobalController.instance.banner.novelDetailBanner = true;
                    });
                  },
                ),
              if (provider.itemList.isNotEmpty) _buildBottomView(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBottomView() {
    ///目录，切换章节
    final provider = context.read<NovelDetailProvider>();
    return KeyboardDismissOnTap(
      dismissOnCapturedTaps: true,
      child: Container(
        height: 56.w + ByScreenUtils.bottomSafeHeight,
        padding: EdgeInsets.only(
            top: 4.w, bottom: ByScreenUtils.bottomSafeHeight + 4.w),
        child: SizedBox(
          height: 48.w,
          child: Row(
            children: [
              SizedBox(
                width: 64,
                child: Opacity(
                  opacity: 1.0,
                  child: ByButton.gradientBtn(
                      textColor: ByColorUtil.colorC1,
                      title: '目录',
                      bgColor: ByColorUtil.color2E3038,
                      onClick: () {
                        // if(provider.isGenerating) {
                        //   BotToast.showText(text: '正文生成完成之后才能查看哦~');
                        // }
                        final listProvider = ChapterListProvider();
                        listProvider.novelID = provider.novelID;
                        listProvider.outlineID = provider.outlineID;
                        listProvider.itemList = provider.itemList;
                        provider.isSquare
                            ? listProvider
                                .fetchSquareNovelInfoList(provider.isGuide)
                            : listProvider.fetchNovelInfoList();
                        Get.bottomSheet(
                          ChangeNotifierProvider(
                            create: (context) => listProvider,
                            child: Container(
                              color: ByColorUtil.colorBg2,
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(left: 12.w),
                                    height: 45.w,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          ByWidgetsUtil.commonText(
                                            text: '目录',
                                            textColor: Colors.white,
                                            fontSize: 15,
                                          ),
                                          const Spacer(),
                                          GestureDetector(
                                              onTap: () {
                                                Get.back();
                                              },
                                              child: Image.asset(
                                                'assets/global/common/btn_close.png',
                                                fit: BoxFit.fill,
                                                width: 32.w,
                                                height: 32.w,
                                              )),
                                          SizedBox(
                                            width: 12.w,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: EasyRefresh(
                                      controller:
                                          listProvider.refreshController,
                                      onLoad: () {
                                        provider.isSquare
                                            ? listProvider
                                                .fetchSquareNovelInfoList(
                                                    provider.isGuide)
                                            : listProvider.fetchNovelInfoList();
                                      },
                                      child: SingleChildScrollView(
                                          child: mounted
                                              ? Consumer<ChapterListProvider>(
                                                  builder: (context,
                                                      listProvider, child) {
                                                  return ChapterListView(
                                                    length: listProvider
                                                        .itemList.length,
                                                    itemList:
                                                        listProvider.itemList,
                                                    showReverse: false,
                                                    action: (bean, index) {
                                                      ///正在生成或者生成完成时，进入查看页
                                                      if (bean.stage == 6 ||
                                                          bean.stage == 5) {
                                                        Get.back();
                                                        if (provider
                                                                .currentChapter !=
                                                            index) {
                                                          provider.currentChapter =
                                                              index;
                                                          provider.contentID =
                                                              bean.id;
                                                          provider.reloadData();
                                                        }
                                                      }
                                                    },
                                                  );
                                                })
                                              : Container()),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ),
              if (provider.isSquare) const Spacer(),
              SizedBox(
                width: 12.w,
              ),
              Opacity(
                opacity: provider.currentChapter == 0 || provider.isGenerating
                    ? 0.5
                    : 1.0,
                child: SizedBox(
                  width: 48.w,
                  child: ByButton.gradientImageBtn(
                      title: '',
                      padding: EdgeInsets.zero,
                      image: 'assets/home/novel/btn_chapter_choose_last.png',
                      bgColor: ByColorUtil.color2E3038,
                      imageSize: 24.w,
                      onClick: () {
                        ///上一页
                        provider.toggleChapter(false);
                      }),
                ),
              ),
              if (!provider.isSquare)
                SizedBox(
                  width: 12.w,
                ),
              if (!provider.isSquare)
                Expanded(
                  child: Opacity(
                    opacity: provider.isGenerating ? 0.5 : 1.0,
                    child: ByButton.gradientBtn(
                        textColor: Colors.black,
                        title: '复制',
                        onClick: () {
                          if (!provider.isGenerating) {
                            ClipboardManager.clip(provider.content);
                          }
                        }),
                  ),
                ),
              SizedBox(
                width: 12.w,
              ),
              provider.currentChapter != provider.chapterNum - 1
                  ? Opacity(
                      opacity: provider.isGenerating ||
                              (provider.chapterBean != null &&
                                  provider.chapterBean!.nextStage! <= 3)
                          ? 0.5
                          : 1.0,
                      child: SizedBox(
                        width: 48.w,
                        child: ByButton.gradientImageBtn(
                            title: '',
                            imageSize: 24.w,
                            padding: EdgeInsets.zero,
                            image:
                                'assets/home/novel/btn_chapter_choose_next.png',
                            bgColor: ByColorUtil.color2E3038,
                            onClick: () {
                              provider.toggleChapter(true);
                            }),
                      ),
                    )
                  : Opacity(
                      opacity: provider.isGenerating ? 0.5 : 1.0,
                      child: SizedBox(
                        width: 88,
                        child: ByButton.gradientBtn(
                            textColor: ByColorUtil.colorC1,
                            title: '已完结',
                            bgColor: ByColorUtil.color2E3038,
                            onClick: () {
                              BotToast.showText(text: '已经是最新一章了');
                            }),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
