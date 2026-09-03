/*
 * @Author: cold-x
 * @Date: 2025-06-16 20:30:05
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-08-11 14:41:47
 * @FilePath: /fastcreationmaster/lib/home/long_novel/page/novel_outline_detail_page.dart
 * @Description: 大纲详情生成和展示页面
 */

import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/widget/view/bottom_view.dart';
import 'package:fast_creation_master/global/other/novel_words/controller/words_controller.dart';
import 'package:fast_creation_master/home/long_novel/controller/outline_detail_provider.dart';
import 'package:fast_creation_master/home/long_novel/view/create_step_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../core/controller/user_controller.dart';
import '../../../core/widget/view/muti_status_view.dart';
import '../../../global/routes/app_pages.dart';
import '../../../global/ui/colors.dart';
import '../view/novel_stream_view.dart';

///大纲详情生成和展示页面
// ignore: must_be_immutable

class NovelOutlineDetailPage extends StatefulWidget {
  const NovelOutlineDetailPage({
    super.key,
    required this.id});

  final int id; ///大纲id

  @override
  State<NovelOutlineDetailPage> createState() => _NovelOutlineDetailPageState();
}

class _NovelOutlineDetailPageState extends State<NovelOutlineDetailPage> {

  @override
  void initState() {
    final provider = context.read<OutlineDetailProvider>();
    provider.fetchOutlineDetail(widget.id);
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
      title: Consumer<OutlineDetailProvider>(builder: (context, provider, child){
        return ByWidgetsUtil.commonText(
            text: provider.outlineBean != null ? '篇章大纲${provider.outlineBean?.index}' : '',
            textColor: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w500);
      }),
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
    WordsController words = Get.find<WordsController>();
    return Consumer<OutlineDetailProvider>(
      builder: (context, provider, child) {
        return MultiStatusView(
          currentStatus: provider.statusType,
          action: () => provider.fetchOutlineDetail(widget.id),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              children: [
                ///顶部进度视图
                const CreateStepView(currentStep: 1),
                SizedBox(
                  height: 12.w,
                ),

                Expanded(
                  child: NovelStreamView(
                    controller: provider.scrollController,
                    isStreaming: provider.isGenerating,
                    content: provider.content,
                    title: provider.outlineBean?.title,
                  ),
                ),
                SizedBox(
                  height: 12.w,
                ),

                if (provider.outlineBean != null && provider.outlineBean!.stage! < 3)
                ///底部提示
                Container(
                  height: 30.w,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: ByColorUtil.colorBg1,
                  ),
                  child: ByWidgetsUtil.commonText(
                      fontSize: 12.sp,
                      textColor: ByColorUtil.colorG4,
                      text: '篇章大纲生成中，请稍后生成细纲'),
                ),

                if (provider.outlineBean != null)
                ///底部进度条
                provider.isGenerating
                    ? Container()
                    : BottomView(
                        padding: 0,
                        words: words.getWords(WordsType.outline, provider.outlineBean!.chaptersNum!),
                        showWords: provider.outlineBean!.allowGenerateChapter! && provider.outlineBean!.stage! == 3,
                        enable: provider.outlineBean!.allowGenerateChapter! || provider.outlineBean!.stage! >= 5,
                        nextBtnText: provider.outlineBean!.stage! >= 5 || provider.outlineBean!.stage == 7 ? '查看章节细纲' : '生成章节细纲',
                        nextStep: () {
                          ///生成细纲
                          if (provider.outlineBean!.allowGenerateChapter!) {
                              ///字数不够
                              if (!words.isWordsEnable(WordsType.outline,
                                  provider.outlineBean!.chaptersNum!)) {
                                Get.find<UserController>().jumpToPayPage(source: 'novel_outline_detail_words_unable',);
                                return;
                              } else {
                                provider.createNovelChapter();
                              }
                            }
                          ///查看细纲
                          if (provider.outlineBean!.stage! >= 5) {
                            provider.gotoChapterList();
                          }
                        },
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
