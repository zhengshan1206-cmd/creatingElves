/*
 * @Author: cold-x
 * @Date: 2025-06-16 20:40:06
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-09-18 13:41:57
 * @FilePath: /fastcreationmaster/lib/home/long_novel/page/novel_chapter_page.dart
 * @Description: 
 */

import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/widget/view/bottom_view.dart';
import 'package:fast_creation_master/core/widget/view/muti_status_view.dart';
import 'package:fast_creation_master/home/long_novel/bean/novel_chapter_bean.dart';
import 'package:fast_creation_master/home/long_novel/controller/novel_chapter_controller.dart';
import 'package:fast_creation_master/home/long_novel/page/novel_base_page.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../global/ui/colors.dart';
import '../view/chapter_choose_view.dart';
import '../view/create_step_view.dart';
import '../view/novel_home_view.dart';

// ignore: must_be_immutable
class NovelChapterPage extends NovelCreateBasePage {
  NovelChapterPage({super.key});

  @override
  String get title => '章节细纲';

  @override
  NovelChapterController get controller => Get.find<NovelChapterController>();

  @override
  NovelCreateStepType get stepType => NovelCreateStepType.chapter;

  @override
  Widget buildBody(BuildContext context) {
    return Obx(() => MultiStatusView(
          currentStatus: controller.statusType.value,
          action: () {
            controller.fetchChapterList();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///顶部进度视图
                buildStepView(),
                SizedBox(
                  height: 12.w,
                ),
                Expanded(
                    child: ListView.builder(
                        controller: controller.scrollController,
                        itemCount: controller.itemList.length,
                        itemBuilder: (context, index) {
                          ChapterBean bean = controller.itemList[index];
                          return Padding(
                            padding: EdgeInsets.only(
                                top: index == 0 ? 0 : 6.w, bottom: 6.w),
                            child: Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.w),
                                  color: ByColorUtil.colorBg2,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth: 240.w,
                                          ),
                                          child: ByWidgetsUtil.commonText(
                                              fontSize: 16,
                                              textColor: ByColorUtil.colorF1,
                                              text:
                                                  '第${bean.index}章 ${bean.title}'),
                                        ),
                                        SizedBox(
                                          width: 10.w,
                                        ),
                                        // Offstage(
                                        //   offstage: false,
                                        //   child: ByWidgetsUtil.commonText(
                                        //       textColor: ByColorUtil.colorF2,
                                        //       text: '已完成'),
                                        // ),
                                        const Spacer(),
                                        _chooseOutlineStatus(bean),
                                      ],
                                    ),
                                    if (bean.introduce != null &&
                                        bean.introduce!.isNotEmpty)
                                      SizedBox(
                                        height: 12.w,
                                      ),
                                    if (bean.introduce != null &&
                                        bean.introduce!.isNotEmpty)
                                      ByWidgetsUtil.commonText(
                                          maxLines: 3,
                                          textColor: ByColorUtil.colorF2,
                                          text: bean.introduce ?? ''),
                                  ],
                                )),
                          );
                        })),
                Container(
                  height: 30.w,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: ByColorUtil.colorBg1,
                  ),
                  child: ByWidgetsUtil.commonText(
                      fontSize: 12.sp,
                      textColor: controller.canSubmitContent() &&
                              controller.outlineStatus.value == 6
                          ? ByColorUtil.colorC1
                          : ByColorUtil.colorG4,
                      text: controller.outlineStatus.value != 6
                          ? '细纲正在生成中，请稍候...'
                          : controller.canSubmitContent()
                              ? '当前篇章已生成${controller.generatedContentNum()}篇文章哦，点击继续生成~'
                              : '您必须生成完前置大纲的章节才能生成本大纲章节哦~'),
                ),
                BottomView(
                  showWords: false,
                  padding: 0,
                  enable: controller.outlineStatus.value == 6 &&
                      controller.canSubmitContent(),
                  nextBtnText: controller.submittedChapterNum.value >=
                          controller.lastContentIndex()
                      ? '查看正文'
                      : '一键成文',
                  nextStep: () {
                    if (controller.submittedChapterNum.value >=
                        controller.lastContentIndex()) {
                      ///当前有小说生成时，跳转至小说正文页
                      if (controller.itemList.first.stage! > 4) {
                        controller.gotoNovelInfoPage(
                            controller.itemList.first.id!,
                            jumpToStream: false);
                      } else {
                        BotToast.showText(text: '当前篇章暂无小说生成，请等待前序篇章完成');
                      }
                      return;
                    }

                    Get.log(
                        "==submittedChapterNum==> ${controller.submittedChapterNum.value}   ${controller.itemList.last.index!}");

                    Get.bottomSheet(
                      ChapterChooseView(
                        charpterNum: controller.itemList.last.index!,
                        startChapter: controller.itemList.first.index!,
                        endChapter: controller.itemList.last.index!,
                        finishedNum: controller.submittedChapterNum.value,
                        chapterSelected: (chapter) {

                          Get.log("===chapter $chapter");
                          controller.generateAction(chapter);
                        },
                      ),
                      isScrollControlled: true,
                    );
                  },
                )
              ],
            ),
          ),
        ));
  }

  _chooseOutlineStatus(ChapterBean bean) {
    switch (bean.stage) {
      ///生成失败
      case 7:
      case 8:
        return GestureDetector(
          onTap: () {
            controller.gotoChapterInfoPage(bean);
          },
          child: const GenerateFailedView(),
        );

      ///生成中
      case 2:
      case 5:
        return GestureDetector(
            onTap: () {
              controller.gotoChapterInfoPage(bean);
            },
            child: GenerateProgressView(
              progressText: bean.stage! == 2 ? '生成中' : '内容生成中',
              progress: -1,
            ));

      ///等待生成
      case 1:
        return ByWidgetsUtil.commonText(
            textColor: ByColorUtil.colorF2, text: '等待生成中~');
      default:
        return GestureDetector(
          onTap: () {
            controller.gotoChapterInfoPage(bean);
          },
          child: Row(
            children: [
              ByWidgetsUtil.commonText(
                  textColor: ByColorUtil.colorC1, text: '查看全部'),
              SizedBox(
                width: 4.w,
              ),
              Image.asset(
                'assets/home/novel/icon_novel_detail.png',
                width: 14.w,
                height: 14.w,
              ),
            ],
          ),
        );
    }
  }
}
