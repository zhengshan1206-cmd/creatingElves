import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:fast_creation_master/core/widget/view/muti_status_view.dart';
import 'package:fast_creation_master/home/long_novel/view/novel_stream_view.dart';
import 'package:fast_creation_master/home/long_novel/view/share_earn_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../global/other/event_tracking/event_tracking.dart';
import '../../../global/ui/colors.dart';
import '../controller/short_story_provider.dart';

///短故事详情页面
class ShortStoryDetailPage extends StatefulWidget {
  const ShortStoryDetailPage({super.key});

  @override
  State<ShortStoryDetailPage> createState() => _ShortStoryDetailPageState();
}

class _ShortStoryDetailPageState extends State<ShortStoryDetailPage> {
  @override
  void initState() {
    final provider = context.read<ShortStoryProvider>();
    provider.startListening();
    super.initState();
    // provider.pageHelper.row = 36;
    ///短故事并且是生成后直接进入
    // if(provider.streamTaskID.isNotEmpty) {
    //   provider.wsConnect(provider.streamTaskID, provider.streamURL);
    //   return;
    // }
    provider.fetchNovelDetail(provider.novelID!);
    EventTracking.reportDataPoint(
          pageTag: 'myworks_detail_short_story_works',
          operateType: 'view',
          funcDetailImg: '',
          funcDetailTag: provider.novelID.toString(),
        );
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
        title: ByWidgetsUtil.commonText(
            text: '短故事',
            textColor: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w500));
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
          Expanded(
            child: Center(
              child: ByWidgetsUtil.commonText(
                  text: '短故事',
                  textColor: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w500),
            ),
          ),
          // const ShareEarnView()
        ],
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return Consumer<ShortStoryProvider>(builder: (context, provider, child) {
      return MultiStatusView(
        currentStatus: provider.statusType,
        action: () {
          provider.fetchNovelDetail(provider.novelID!);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 12.w,
                  ),
                  _buildBriefView(),
                  SizedBox(
                    height: 12.w,
                  ),
                  Expanded(
                    child: EasyRefresh(
                      controller: provider.refreshController,

                      ///页面刚进入时小说正文处于完成状态时才能上拉加载更多，不支持实时更新小说状态
                      onLoad: provider.novelBean?.stage == 7
                          ? () {
                              provider.fetchShortStoryList(isRefresh: false);
                            }
                          : null,
                      child: NovelStreamView(
                        showBg: false,
                        isMarkdown: false,
                        controller: provider.scrollController,
                        isStreaming: provider.isGenerating,
                        isGeneratingNext: false,
                        content: provider.content,
                        title: provider.novelBean?.title,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 12.w,
                  ),
                ],
              ),

              ///下载
              if (!provider.isGenerating || provider.novelBean?.stage == 7)
                Positioned(
                    bottom: 78.h, right: 12.w, child: _buildBtn('download')),
              if (!provider.isGenerating || provider.novelBean?.stage == 7)

                ///分享
                Positioned(
                    bottom: 146.h, right: 12.w, child: _buildBtn('share')),
            ],
          ),
        ),
      );
    });
  }

  ///顶部小说灵感
  Widget _buildBriefView() {
    return GestureDetector(
      onTap: () {
        final provider = context.read<ShortStoryProvider>();
        provider.gotoBriefPage();
      },
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
              'assets/home/novel/icon_short_story_brief_tip.png',
              width: 16.w,
              height: 16.w,
            ),
            SizedBox(
              width: 4.0.w,
            ),
            ByWidgetsUtil.commonText(
              text: '小说灵感',
              textColor: Colors.white,
              fontSize: 15.sp,
            ),
            const Spacer(),
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
    );
  }

  ///下载分享按钮
  Widget _buildBtn(String type) {
    final provider = context.read<ShortStoryProvider>();
    return GestureDetector(
      onTap: () {
        ///分享
        if (type == 'share') {
          provider.fetchShortStoryWebURL();
        }

        ///下载
        else if (type == 'download') {
          provider.downloadShortStory();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: ByColorUtil.colorF1,
          borderRadius: BorderRadius.circular(26.w),
        ),
        child: Container(
          width: 52.w,
          height: 52.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26.w),
            gradient: LinearGradient(colors: [
              ByColorUtil.colorC1.withOpacity(0.32),
              ByColorUtil.colorC1.withOpacity(0.08)
            ]),
          ),
          child: Center(
            child: Image.asset(
              'assets/home/novel/btn_novel_$type.png',
              width: 24.w,
              height: 24.w,
            ),
          ),
        ),
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
}
