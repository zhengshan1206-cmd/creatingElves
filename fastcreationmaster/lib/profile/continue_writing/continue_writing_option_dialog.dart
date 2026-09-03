import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_common/event/common_event.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/global/other/novel_words/controller/words_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/network/novel_apis.dart';
import '../../core/widget/view/by_text_field.dart';
import '../../home/long_novel/bean/novel_continue_write_model.dart';
import '../profile_controller.dart';

///续写配置弹窗
class ContinueWritingOptionDialog extends StatefulWidget {
  final int? novelId;
  const ContinueWritingOptionDialog({
    super.key,
    required this.novelId,
  });

  @override
  State<ContinueWritingOptionDialog> createState() =>
      _ContinueWritingOptionDialogState();
}

class _ContinueWritingOptionDialogState
    extends State<ContinueWritingOptionDialog> {
  ///是否大结局
  int isEnd = 1;

  ///续写配置
  List<LongNovelContinue> longNovelContinue = [];

  ///最大章节数
  int maxChapter = 1000;

  ///最小章节数
  int minChapter = 0;

  ///当前章节数
  int currentChapter = 36;

  ///章节数量的controller
  final TextEditingController controller = TextEditingController();

  ///章节数量的focusNode
  final FocusNode focusNode = FocusNode();

  ///大结局类型选择
  String groupValue = "";

  late StreamSubscription<bool> keyboardSubscription;

  final KeyboardVisibilityController keyboardVisibilityController =
      KeyboardVisibilityController();

  bool keyboardVisible = false;

  @override
  void initState() {
    super.initState();
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      if (mounted) {
        setState(() {
          keyboardVisible = visible;
        });
      }
      Get.log('键盘是否可见 $visible');
    });
    initData();
  }

  initData() {
    Get.find<ProfileController>().updateUserInfo();
    longNovelContinue = Get.find<UserController>().longNovelContinue;
    controller.text = currentChapter.toString();
    if (longNovelContinue.isNotEmpty) {
      groupValue = longNovelContinue.first.key ?? "";
    }

    controller.addListener(() {
      if (controller.text.isNotEmpty) {
        int num = int.parse(controller.text);
        currentChapter = num;
      } else {
        currentChapter = 0;
      }
    });


    if (mounted) {
      setState(() {});
    }
  }

  ///添加章节
  addChapter() {
    if (currentChapter >= maxChapter) {
      return;
    }
    if (currentChapter < maxChapter) {
      currentChapter += 36;
    }
    if (currentChapter >= maxChapter) {
      currentChapter = maxChapter;
    }

    controller.text = currentChapter.toString();

    if (mounted) {
      setState(() {});
    }
  }

  ///减少章节
  reduceChapter() {
    if (currentChapter <= minChapter) {
      return;
    }
    currentChapter -= 36;
    if (currentChapter <= minChapter) {
      currentChapter = minChapter;
    }

    controller.text = currentChapter.toString();

    if (mounted) {
      setState(() {});
    }
  }

  ///继续 续写接口
  continueWrite() {
    HttpUtils.post(
      NovelApis.continueWrite,
      {
        "id": "${widget.novelId}",
        "chapters_num": currentChapter,
        "finale_type": isEnd == 1 ? groupValue : "",
        "is_finale": isEnd == 1 ? 1 : 2
      },
      success: (data) {
        Get.log("继续 续写接口 novel/aiNovel/novelContinue=====>$data");
        eventBus.fire(const NovelContinueSuccessEvent());
        Get.find<ProfileController>().updateUserInfo();
        Get.back();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    ///剩余字数
    String remainingWords = Get.find<ProfileController>().getUserWords();

    ///消耗字数
    String costWords = Get.find<WordsController>().getWords(WordsType.total, currentChapter);
    bool couldContinueWrite = false;
    String remainingWordsNumber = Get.find<ProfileController>().getUserWords(needDetail: true);
    int costWordsNumber = Get.find<WordsController>().getNovelTotalWords(currentChapter);
    Get.log("===costWords $costWordsNumber  ===remainingWordsNumber $remainingWordsNumber");
    if (int.parse(remainingWordsNumber) > costWordsNumber) {
      couldContinueWrite = true;
    }

    return InkResponse(
      onTap: (){
        if(focusNode.hasFocus){
          focusNode.unfocus();
        }
      },
      child: Container(
        width: 1.sw,
        height: 398.w,
        decoration: BoxDecoration(
          color: const Color(0XFF1E1F24),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.w),
            topRight: Radius.circular(
              12.w,
            ),
          ),
        ),
        padding: EdgeInsets.only(
          top: 16.w,
          left: 12.w,
          right: 12.w,
        ),
        margin: EdgeInsets.only(
          bottom: keyboardVisible ? 30.w : 0,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "续写配置",
                  style: TextStyle(
                    color: const Color(0XFFFFFFFF),
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                InkResponse(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                      width: 30.w,
                      height: 30.w,
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/global/common/btn_close.png',
                        fit: BoxFit.fill,
                        width: 30.w,
                        height: 30.w,
                      )),
                )
              ],
            ),
            SizedBox(
              height: 21.w,
            ),
            Row(
              children: [
                Text(
                  "续写章节数",
                  style: TextStyle(
                    color: const Color(0XFFFFFFFF),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(),

                ///减章节数
                InkResponse(
                  onTap: () {
                    reduceChapter();
                  },
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: currentChapter > minChapter
                            ? Colors.white
                            : const Color(0XFF4D4E56),
                      ),
                      borderRadius: BorderRadius.circular(6.w),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: 16.w,
                      height: 2.w,
                      color: currentChapter > minChapter
                          ? Colors.white
                          : const Color(0XFF4D4E56),
                    ),
                  ),
                ),
                SizedBox(
                  width: 6.w,
                ),

                Container(
                  width: 56.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: const Color(0XFF4D4E56),
                    border: Border.all(
                      color: const Color(0XFF4D4E56),
                    ),
                    borderRadius: BorderRadius.circular(6.w),
                  ),
                  alignment: Alignment.center,
                  child: ByTextField(
                    maxLength: 4,
                    align: TextAlign.center,
                    inputFormatters: [
                      // FilteringTextInputFormatter.digitsOnly,

                      NumberRangeFormatter(min: 0, max: 1000), // 限制范围
                    ],
                    textColor: const Color(0XFF98FC4A),
                    inputType: TextInputType.number,
                    controller: controller,
                    focusNode: focusNode,
                    change: (p0) {
                      Get.log("===currentChapter=== $p0");
                    },
                  ),
                ),

                SizedBox(
                  width: 6.w,
                ),

                ///增加章节数
                InkResponse(
                  onTap: () {
                    addChapter();
                  },
                  child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: currentChapter < maxChapter
                              ? Colors.white
                              : const Color(0XFF4D4E56),
                        ),
                        borderRadius: BorderRadius.circular(6.w),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.add,
                        color: currentChapter < maxChapter
                            ? Colors.white
                            : const Color(0XFF4D4E56),
                        size: 24.w,
                      )),
                ),
              ],
            ),
            SizedBox(
              height: 21.w,
            ),

            ///是否大结局
            Row(
              children: [
                Text(
                  "是否大结局",
                  style: TextStyle(
                    color: const Color(0XFFFFFFFF),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 4.w,
                ),
                RadioTheme(
                  data: RadioThemeData(
                    /// 设置未选中时的圆形大小
                    visualDensity: const VisualDensity(
                      horizontal: VisualDensity.minimumDensity,
                      vertical: VisualDensity.minimumDensity,
                    ),

                    /// 选中时的圆点大小
                    splashRadius: 12.w, // 点击水波纹大小
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Transform.scale(
                    scale: 0.8, // 整体缩放
                    child: Radio(
                      value: 1,
                      onChanged: (value) {
                        setState(() {
                          isEnd = value as int;
                        });
                      },
                      groupValue: isEnd,
                      activeColor: const Color(0XFF98FC4A),
                    ),
                  ),
                ),
                Text(
                  "是",
                  style: TextStyle(
                    color: const Color(0XFFFFFFFF),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  width: 20.w,
                ),
                RadioTheme(
                  data: RadioThemeData(
                    /// 设置未选中时的圆形大小
                    visualDensity: const VisualDensity(
                      horizontal: VisualDensity.minimumDensity,
                      vertical: VisualDensity.minimumDensity,
                    ),

                    /// 选中时的圆点大小
                    splashRadius: 12.w, // 点击水波纹大小
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Transform.scale(
                    scale: 0.8, // 整体缩放
                    child: Radio(
                      value: 2,
                      onChanged: (value) {
                        setState(() {
                          isEnd = value as int;
                        });
                      },
                      groupValue: isEnd,
                      activeColor: const Color(0XFF98FC4A),
                    ),
                  ),
                ),
                Text(
                  "否",
                  style: TextStyle(
                    color: const Color(0XFFFFFFFF),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 31.w,
            ),
            if (isEnd == 1)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 4.w),
                    child: Text(
                      "大结局类型",
                      style: TextStyle(
                        color: const Color(0XFFFFFFFF),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 22.w,
                  ),
                  SizedBox(
                    width: 1.sw - 120.w,
                    child: Column(
                      children: [
                        Wrap(
                          spacing: 0, //主轴上子控件的间距
                          runSpacing: 10.w, //交叉轴上子控件之间的间距
                          children: [
                            ...longNovelContinue.map((e) {
                              Get.log("===子项=== ${e.toJson()}");

                              return SizedBox(
                                width: 85.w,
                                child: Row(
                                  children: [
                                    RadioTheme(
                                      data: RadioThemeData(
                                        /// 设置未选中时的圆形大小
                                        visualDensity: const VisualDensity(
                                          horizontal:
                                          VisualDensity.minimumDensity,
                                          vertical: VisualDensity.minimumDensity,
                                        ),
                                        // 选中时的圆点大小
                                        splashRadius: 12.w, // 点击水波纹大小
                                        materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Transform.scale(
                                        scale: 0.8, // 整体缩放
                                        child: Radio(
                                          value: e.key,
                                          onChanged: (value) {
                                            if (mounted) {
                                              setState(() {
                                                groupValue = value as String;
                                              });
                                            }
                                          },
                                          groupValue: groupValue,
                                          activeColor: const Color(0XFF98FC4A),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "${e.value}",
                                      style: TextStyle(
                                        color: const Color(0XFFFFFFFF),
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            if (isEnd == 1)
              SizedBox(
                height: 40.w,
              ),

            const Spacer(),

            ///预计消耗数字
            Row(
              children: [
                Text(
                  "预计消耗",
                  style: TextStyle(
                    color: Color(0XFFFFFFFF).withOpacity(0.64),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  costWords,
                  style: TextStyle(
                    color: Color(0XFF98FC4A).withOpacity(0.64),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  "字",
                  style: TextStyle(
                    color: Color(0XFFFFFFFF).withOpacity(0.64),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                Text(
                  "剩余",
                  style: TextStyle(
                    color: Color(0XFFFFFFFF).withOpacity(0.64),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  "$remainingWords",
                  style: TextStyle(
                    color: Color(0XFF98FC4A).withOpacity(0.64),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  "字",
                  style: TextStyle(
                    color: Color(0XFFFFFFFF).withOpacity(0.64),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 13.w,
            ),

            ///开始续写
            InkResponse(
              onTap: () {
                if (couldContinueWrite) {
                  if(currentChapter<=0){
                    BotToast.showText(text: "续写章节数量应在1章以上～");
                    return;
                  }
                  continueWrite();
                } else {
                  BotToast.showText(text: "当前字数不足，请充值～");
                  Get.back();
                  Get.find<UserController>().jumpToPayPage(
                    source: 'last_chapter',
                  );
                }
              },
              child: Container(
                width: 1.sw,
                height: 48.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: [0.38, 1.0], // 38%和100%的位置
                    colors: [
                      Color(0xFF98FC4A), // #98FC4A
                      Color(0xFFD7F97D), // #D7F97D
                    ],
                  ),
                  // 对应CSS的border-radius: 15px 15px 15px 15px
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: Text(
                  "开始续写",
                  style: TextStyle(
                    color: const Color(0XFF162408),
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(
              height: 36.w,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.find<ProfileController>().updateUserInfo();
    super.dispose();
  }
}

///小说续写成功事件
class NovelContinueSuccessEvent {
  const NovelContinueSuccessEvent();
}

class NumberRangeFormatter extends TextInputFormatter {
  final int min;
  final int max;

  NumberRangeFormatter({this.min = 0, this.max = 1000});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 只允许输入数字
    if (!RegExp(r'^[0-9]*$').hasMatch(newValue.text)) {
      return oldValue;
    }

    // 处理空输入
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // 转换为整数进行范围检查
    final number = int.tryParse(newValue.text);
    if (number == null) {
      return oldValue;
    }

    // 检查是否在范围内
    if (number < min || number > max) {
      return oldValue;
    }

    // 处理前导零（例如"00123"变为"123"）
    if (newValue.text.length > 1 && newValue.text.startsWith('0')) {
      return TextEditingValue(
        text: newValue.text.replaceFirst(RegExp(r'^0+'), ''),
        selection: TextSelection.collapsed(
          offset: newValue.text.replaceFirst(RegExp(r'^0+'), '').length,
        ),
      );
    }

    return newValue;
  }
}

class RefreshAiContinueWriteEvent{
  const RefreshAiContinueWriteEvent();
}