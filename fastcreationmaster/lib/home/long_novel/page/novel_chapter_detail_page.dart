/*
 * @Author: cold-x
 * @Date: 2025-06-16 20:30:05
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-08-22 11:41:51
 * @FilePath: /fastcreationmaster/lib/home/long_novel/page/novel_chapter_detail_page.dart
 * @Description: 章节细纲详情生成和展示页面
 */


import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/widget/view/muti_status_view.dart';
import 'package:fast_creation_master/home/long_novel/bean/novel_chapter_bean.dart';
import 'package:fast_creation_master/home/long_novel/view/create_step_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../global/routes/app_pages.dart';
import '../../../global/ui/colors.dart';
import '../controller/chapter_detail_provider.dart';
import '../view/novel_stream_view.dart';




///章节细纲详情生成和展示页面
class NovelChapterDetailPage extends StatefulWidget {
  const NovelChapterDetailPage({
    super.key,
    required this.bean});

  final ChapterBean bean;

  @override
  State<NovelChapterDetailPage> createState() => _NovelChapterDetailPageState();
}

class _NovelChapterDetailPageState extends State<NovelChapterDetailPage> {

  String title = '章节细纲';

  @override
  void initState() {
    final provider = context.read<ChapterDetailProvider>();
    provider.fetchChapterDetail(widget.bean.novelID!, widget.bean.id!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColorUtil.colorBg1,
      appBar: buildAppBar(context),
      body: buildBody(context),
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
          text: title,
          textColor: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w500),
      // actions: [
      //   buildActions(context),
      // ],
    );
  }

  Widget buildActions(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.all(12.w),
        child: ByWidgetsUtil.commonText(
          bgColor: Colors.transparent,
          textColor: ByColorUtil.colorC1,
          fontWeight: FontWeight.w500,
          fontSize: 14,
          text: '创作记录',
        ),
      ),
      onTap: () {
        Get.toNamed(Routes.novelRecord);
      },
    );
  }

  Widget buildBody(BuildContext context) {
    return Consumer<ChapterDetailProvider>(builder: (context, provider, child) {
      return MultiStatusView(
        currentStatus: provider.statusType,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Column(
            children: [
              ///顶部进度视图
              const CreateStepView(currentStep: 2),
              SizedBox(
                height: 12.w,
              ),
              Expanded(
                child: NovelStreamView(
                  controller: provider.scrollController,
                  isStreaming: provider.isGenerating,
                  content: provider.content,
                  title: provider.chapterBean?.title ?? '',
                  // novelID: provider.,
                ),
              ),
              SizedBox(
                height: 12.w,
              ),
            ],
          ),
        ),
      );
    });
  }
}
