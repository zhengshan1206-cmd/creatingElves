
import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/util/by_screen_utils.dart';
import 'package:fast_creation_master/core/widget/view/by_button.dart';
import 'package:fast_creation_master/global/other/illegal_words/view/highlight_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../ui/colors.dart';
import '../controller/illegal_words_manager.dart';
import 'illegal_words_replace_dialog.dart';

class IllegalWordsDialog extends StatefulWidget {
  const IllegalWordsDialog({super.key, required this.manager});

  final IllegalWordsManager manager; ///违禁词管理器

  @override
  State<IllegalWordsDialog> createState() => _IllegalWordsDialogState();
}

class _IllegalWordsDialogState extends State<IllegalWordsDialog> {

  String lastDetectedContent = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PanToUnfocus(
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                bottom: 14.h + ByScreenUtils.bottomSafeHeight,
                left: 11.w,
                right: 11.w,
              ),
              decoration: BoxDecoration(
                color: ByColorUtil.colorBg2,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.w),
                  topRight: Radius.circular(18.w),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 13.h),
                  _buildTitle(context),
                  SizedBox(height: 10.h),
                  _buildInputWidget(context, 350.h),
                  SizedBox(height: 10.h),
                  _buildProhibitedWords(context),
                  SizedBox(height: 10.h),
                  _buildActions(context),
                  SizedBox(
                    height: 50.h,
                    child: ByButton.gradientBtn(
                      title: "确定",
                      textColor: Colors.black,
                      onClick: () {
                        if (widget.manager.bandedWords.isNotEmpty) {
                          BotToast.showText(text: '当前还有违禁词需要处理');
                        }
                        else {
                          ///这里返回新的解说文本
                          Get.back(result: {
                            "content": widget.manager.content.value,
                          });
                        }
                      },
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

  /// 文本内容显示组件
  _buildInputWidget(BuildContext context, double? height) {
    return Obx(() => SizedBox(
      height: 400.h,
      child: SingleChildScrollView(
        child: MultiHighlightText(
          text: widget.manager.content.value,
          highlights: widget.manager.bandedWords,
          normalStyle: const TextStyle(
            color: ByColorUtil.colorF1,
          ),
          highlightStyle: const TextStyle(
            color: ByColorUtil.colorG4
          ),
        ),
      ),));
  }


  ///替换视图
  _buildActions(BuildContext context) {
    return Obx(() => Offstage(
      offstage: widget.manager.bandedWords.isEmpty,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        height: 44.h,
        child: Row(
          children: [
            Expanded(
              child: ByButton.gradientImageBtn(
                image: 'assets/global/common/btn_illegal_words_letter.png',
                title: "首字母替换",
                fontSize: 14.sp,
                fontWeight: FontWeight.normal,
                textColor: ByColorUtil.colorC1,
                bgColor: ByColorUtil.color2E3038,
                onClick: () {
                  widget.manager.replaceWithInitialLetterOfPinyin();
                  widget.manager.detectIllegalWords(widget.manager.content.value);
                },
              ),
            ),
            SizedBox(width: 11.w),
            Expanded(
              child: ByButton.gradientImageBtn(
                image: 'assets/global/common/btn_illegal_words_batch.png',
                title: "批量替换",
                fontSize: 14.sp,
                fontWeight: FontWeight.normal,
                textColor: ByColorUtil.colorC1,
                bgColor: ByColorUtil.color2E3038,
                onClick: () {
                  if (widget.manager.bandedWords.isEmpty) {
                    BotToast.showText(text: "暂无违禁词，请重新检测");
                    return;
                  }
                  showDialog(
                    context: context,
                    useSafeArea: false,
                    builder: (ctx) => IllegalWordsReplaceDialog(manager: widget.manager,),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }

  ///顶部视图
  Row _buildTitle(BuildContext context) {
    return Row(
      children: [
        ByWidgetsUtil.commonText(
          text: "违禁词检测",
          textColor: ByColorUtil.colorF1,
          fontWeight: FontWeight.w600,
          fontSize: 17.sp,
        ),
        const Spacer(),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Get.back();
          },
          child: Container(
            width: 30.w,
            height: 30.w,
            alignment: Alignment.center,
            child: Image.asset(
              "assets/global/common/btn_close.png",
              width: 30,
              height: 30,
            ),
          ),
        ),
        // SizedBox(width: 11.w),
      ],
    );
  }

  /// 违禁词列表
  _buildProhibitedWords(BuildContext context) {
    return Obx(() => widget.manager.bandedWords.isEmpty ? Container() : SizedBox(
      height: 35.h,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        itemCount: widget.manager.bandedWords.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.manager.updateSelectedBandedWord(widget.manager.bandedWords[index]);
            },
            child: Obx(() => Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              margin: EdgeInsets.only(
                  right:
                      (index == widget.manager.bandedWords.length - 1) ? 0 : 10.w),
              decoration: BoxDecoration(
                color: ByColorUtil.color2E3038,
                borderRadius: BorderRadius.circular(6.w),
                border: Border.all(
                  color: widget.manager.bandedWords[index] ==
                          widget.manager.selectedBandedWord.value
                      ? ByColorUtil.colorG4
                      : Colors.transparent,
                ),
              ),
              child: ByWidgetsUtil.commonText(
                fontSize: 14.sp,
                text: widget.manager.bandedWords[index],
                fontWeight: FontWeight.normal,
                textColor: widget.manager.bandedWords[index] ==
                          widget.manager.selectedBandedWord.value
                      ? ByColorUtil.colorG4
                      : ByColorUtil.colorF1,
              ),
            ),
          ));
        },
      ),
    ));
  }
}






class PanToUnfocus extends StatelessWidget {
  const PanToUnfocus({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      onPanStart: (details) {
        FocusScope.of(context).unfocus();
      },
      child: child,
    );
  }
}