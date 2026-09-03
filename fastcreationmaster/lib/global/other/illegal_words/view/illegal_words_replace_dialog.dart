

import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/widget/view/by_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/util/by_screen_utils.dart';
import '../../../ui/colors.dart';
import '../controller/illegal_words_manager.dart';

class IllegalWordsReplaceDialog extends StatefulWidget {
  const IllegalWordsReplaceDialog({super.key, required this.manager});

  final IllegalWordsManager manager; ///违禁词管理器

  @override
  State<IllegalWordsReplaceDialog> createState() => _IllegalWordsReplaceDialogState();
}

class _IllegalWordsReplaceDialogState extends State<IllegalWordsReplaceDialog> {

  final TextEditingController wordsEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
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
                _buildProhibitedWords(context),
                SizedBox(height: 20.h),
                _buildSelectedWord(context),
                SizedBox(height: 7.h),
                Image.asset(
                  "assets/global/common/icon_illegal_words_swap.png",
                  width: 16.w,
                  height: 16.w,
                ),
                SizedBox(height: 7.h),
                _buildInput(),
                SizedBox(height: 10.h),
                ByButton.gradientBtn(
                  title: "替换",
                  textColor: Colors.black,
                  onClick: () {
                    widget.manager.replaceWord(wordsEditingController.text, () {
                      widget.manager.detectIllegalWords(
                        widget.manager.content.value,
                        onSuccess: (p0) {
                          widget.manager.selectedBandedWord.value =
                                widget.manager.bandedWords.first;
                        },
                        noIllegalWords: () {
                          FocusScope.of(context).unfocus();
                          Get.back();
                        },
                      );
                    });
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Row _buildTitle(BuildContext context) {
    return Row(
      children: [
        ByWidgetsUtil.commonText(
          text: "批量替换",
          textColor: ByColorUtil.colorF1,
          fontSize: 17,
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
      ],
    );
  }

  _buildProhibitedWords(BuildContext context) {

    return Obx(() => Wrap(
      spacing: 5,
      runSpacing: 5,
      children: List.generate(
        widget.manager.bandedWords.length,
        (index) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              widget.manager.updateSelectedBandedWord(widget.manager.bandedWords[index]);
            },
            child: Obx(() => Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: ByColorUtil.color2E3038,
                borderRadius: BorderRadius.circular(6.w),
                border: Border.all(
                  color:
                      widget.manager.bandedWords[index] == widget.manager.selectedBandedWord.value
                          ? ByColorUtil.colorG4
                          : Colors.transparent,
                ),
              ),
              child: ByWidgetsUtil.commonText(
                fontSize: 14.sp,
                text: widget.manager.bandedWords[index],
                fontWeight: FontWeight.normal,
                textColor: widget.manager.bandedWords[index] == widget.manager.selectedBandedWord.value 
                    ? ByColorUtil.colorG4 : ByColorUtil.colorF1,
              ),
            )),
          );
        },
      ),
    ));
  }

  _buildSelectedWord(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ByColorUtil.color2E3038,
        borderRadius: BorderRadius.circular(10.w),
      ),
      child: Obx(() => ByWidgetsUtil.commonText(
        text: widget.manager.selectedBandedWord.value,
        textColor: ByColorUtil.colorF1,
        fontSize: 13.sp,
      ),
    ));
  }

  _buildInput() {
    return Container(
      height: 44.w,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ByColorUtil.color2E3038,
        borderRadius: BorderRadius.circular(10.w),
      ),
      child: TextField(
        maxLines: null,
        expands: true,
        controller: wordsEditingController,
        cursorColor: ByColorUtil.colorF1,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: ByColorUtil.colorF1,
          fontSize: 13
        ),
        decoration: InputDecoration(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.w),
          border: InputBorder.none,
          labelStyle: const TextStyle(
            fontSize: 13,
            color: ByColorUtil.colorF1,
          ),
          hintStyle: TextStyle(
            fontSize: 13,
            color: ByColorUtil.colorF1.withOpacity(0.3),
          ),
          hintText: "请输入替换内容",
        ),
      ),
    );
  }
}
