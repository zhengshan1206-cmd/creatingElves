/*
 * @Author: cold-x
 * @Date: 2025-06-17 20:53:23
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-08-28 14:46:01
 * @FilePath: /fastcreationmaster/lib/home/long_novel/view/novel_stream_view.dart
 * @Description: 
 */

import 'dart:async';

import 'package:byhy_app_common_utils/app_common/event/common_event.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/util/clipboard.dart';
import 'package:fast_creation_master/home/main_page/controller/home_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:markdown/markdown.dart' as md;
import '../../../core/network/novel_apis.dart';
import '../../../global/routes/app_pages.dart';
import '../../../global/ui/colors.dart';
import '../../../profile/continue_writing/continue_writing_option_dialog.dart';
import '../../../profile/profile_controller.dart';
import '../bean/novel_bean.dart';
import '../controller/novel_home_controller.dart';

class NovelStreamView extends StatefulWidget {
  const NovelStreamView({
    super.key,
    this.title = '',
    this.content = '',
    this.isGeneratingNext = false,
    this.isMarkdown = true,
    this.controller,
    this.showBg = false,
    this.showTitle = true,
    this.isStreaming = true,
    this.isCompleted,
    this.aiContinueWriteEvent,
    this.novelID,
    this.isLastChapter,
  });

  ///标题
  final String? title;

  ///内容
  final String? content;

  ///是否正在流式输出
  final bool? isStreaming;

  ///是否需要markdown格式
  final bool? isMarkdown;

  ///是否正在生成下一部分内容
  final bool? isGeneratingNext;

  ///是否显示背景图
  final bool? showBg;

  ///是否显示标题
  final bool? showTitle;

  final ScrollController? controller;

  final bool? isCompleted;

  ///ai 续写事件
  final VoidCallback? aiContinueWriteEvent;

  ///小说id
  final int? novelID;

  ///是否最后一章
  final bool? isLastChapter;

  @override
  State<NovelStreamView> createState() => _NovelStreamViewState();
}

class _NovelStreamViewState extends State<NovelStreamView> {
  ///是否提交续写
  bool isPostToContinueWrite = false;

  ///监听小说续写成功事件
  late StreamSubscription<NovelContinueSuccessEvent> streamSubscription;
  late NovelHomeController controller;

  /// 倒计时总时长（5秒）
  final int _totalSeconds = 5;

  /// 当前剩余秒数
  int _remainingSeconds = 5;

  /// 定时器对象
  Timer? _timer;

  /// 是否正在倒计时
  bool _isRunning = false;

  /// 开始或继续倒计时
  void _startTimer() {
    if (!_isRunning && _remainingSeconds > 0) {
      setState(() {
        _isRunning = true;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            isTimerFinish = true;
            _stopTimer();
            if (mounted) {
              setState(() {});
            }
          }
        });
      });
    }
  }

  /// 暂停倒计时
  void _pauseTimer() {
    _stopTimer();
  }

  /// 重置倒计时
  void _resetTimer() {
    _stopTimer();
    setState(() {
      _remainingSeconds = _totalSeconds;
    });
  }

  // 停止定时器
  void _stopTimer() {
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
      setState(() {
        _isRunning = false;
      });
    }
    _cancelQueryNovelTimer();
  }

  bool isTimerFinish = false;
  bool? isCompleted;
  late StreamSubscription<RefreshAiContinueWriteEvent> reSsp;

  /// 查询小说定时器对象
  Timer? _queryNovelTimer;

  /// 启动小说定时器
  void _startQueryNovelTimer({
    int seconds = 1,
  }) {
    /// 取消已有的定时器（如果存在）
    _cancelQueryNovelTimer();

    /// 创建每隔2秒执行一次的定时器
    _queryNovelTimer = Timer.periodic(Duration(seconds: seconds), (timer) {
      /// 每次定时器触发时执行的操作
      _performPolling();
    });
  }

  // 取消定时器
  void _cancelQueryNovelTimer() {
    if (_queryNovelTimer != null && _queryNovelTimer!.isActive) {
      _queryNovelTimer!.cancel();
      _queryNovelTimer = null;
    }
  }

  // 执行轮询操作
  void _performPolling() {
    if (widget.novelID != null && widget.isLastChapter == true) {
      updateNovel(widget.novelID!);
    }
  }

  @override
  void initState() {
    streamSubscription = eventBus.on<NovelContinueSuccessEvent>().listen((e) {
      if (mounted) {
        _startTimer();
        setState(() {
          isPostToContinueWrite = true;
        });
      }
    });
    reSsp = eventBus.on<RefreshAiContinueWriteEvent>().listen((e) {
      if (widget.novelID != null && widget.isLastChapter == true) {
        // _startQueryNovelTimer();
      }
    });
    initData();
    super.initState();
  }

  initData() {
    isCompleted = widget.isCompleted;
    if (widget.novelID != null &&
        widget.isLastChapter == true &&
        isCompleted == true) {
      controller = Get.put(NovelHomeController(novelID: widget.novelID!));
    }
    if (widget.novelID != null && widget.isLastChapter == true) {
      _startQueryNovelTimer();
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Get.log("===isLastChapter  ${widget.isLastChapter}");
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.w),
          image: widget.showBg!
              ? const DecorationImage(
                  alignment: Alignment.topCenter,
                  image:
                      AssetImage('assets/home/novel/icon_novel_content_bg.png'))
              : null,
          color: ByColorUtil.colorBg2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///标题和字数
          if (widget.showTitle!)
            Row(
              children: [
                ByWidgetsUtil.commonText(
                    fontSize: 16.sp,
                    textColor: ByColorUtil.colorF1,
                    text: widget.title!),
                const Spacer(),
                ByWidgetsUtil.commonText(
                    textColor: ByColorUtil.colorF2,
                    text: '${widget.content!.length}字'),
              ],
            ),
          if (widget.showTitle!)
            SizedBox(
              height: 12.w,
            ),
          widget.showTitle!
              ? Expanded(
                  child: !widget.isMarkdown! && !widget.isStreaming!
                      ? SelectableText(
                          widget.content!,
                          key: UniqueKey(),

                          ///SelectableText不支持选择重置，必须重新绘制
                          maxLines: 9999,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: ByColorUtil.colorF2,
                          ),
                        )
                      : SingleChildScrollView(
                          controller: widget.controller,
                          child: _buildMarkDownView()),
                )
              : _buildMarkDownView(),

          if (isCompleted == true && widget.isLastChapter == true)
            _aiContinueWriteBtn(),
        ],
      ),
    );
  }

  ///创建markdown
  Widget _buildMarkDownView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //生成内容
        if (widget.content!.isNotEmpty)
          widget.isMarkdown!
              ? Markdown(
                  padding: EdgeInsets.symmetric(vertical: 12.w),
                  physics: const NeverScrollableScrollPhysics(),
                  selectable: true,
                  styleSheet: _createNightModeStyle(),
                  shrinkWrap: true,
                  data: widget.content!,
                  // builders: {
                  //   'p': CustomParagraphBuilder(),
                  //   'h3': CustomParagraphBuilder(),
                  //   'h4': CustomParagraphBuilder(),
                  //   'blockquote': CustomParagraphBuilder(),
                  //   'listBullet': CustomParagraphBuilder(),
                  // },
                )
              : ByWidgetsUtil.commonText(
                  maxLines: 9999,
                  fontSize: 14.sp,
                  textColor: ByColorUtil.colorF2,
                  text: widget.content!),

        if (widget.content!.isNotEmpty)
          SizedBox(
            height: 12.w,
          ),
        if (widget.content!.isEmpty)

          ///加载提示框
          Container(
            width: 125.w,
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.w),
              color: const Color(0xFFD7F97D).withOpacity(0.1),
            ),
            child: Row(
              children: [
                const CupertinoActivityIndicator(
                  color: ByColorUtil.colorC1,
                  radius: 6,
                ),
                SizedBox(
                  width: 4.w,
                ),
                ByWidgetsUtil.commonText(
                    fontSize: 14.sp,
                    textColor: ByColorUtil.colorC1,
                    text: 'AI正在创作中'),
              ],
            ),
          ),
        if (widget.isGeneratingNext!)
          SizedBox(
            height: 12.w,
          ),
        if (widget.isGeneratingNext!)

          ///下一章内容准备提示框
          Container(
            width: 168.w,
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.w),
              color: const Color(0xFFD7F97D).withOpacity(0.1),
            ),
            child: Row(
              children: [
                const CupertinoActivityIndicator(
                  color: ByColorUtil.colorC1,
                  radius: 6,
                ),
                SizedBox(
                  width: 4.w,
                ),
                ByWidgetsUtil.commonText(
                    fontSize: 14.sp,
                    textColor: ByColorUtil.colorC1,
                    text: '下一章内容准备中...'),
              ],
            ),
          ),
        if (!widget.isStreaming!)
          SizedBox(
            height: 10.w,
          ),
        if (!widget.isStreaming! && widget.content!.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/global/common/icon_novel_warning_gray.png',
                width: 12.w,
                height: 12.w,
              ),
              SizedBox(
                width: 6.w,
              ),
              ByWidgetsUtil.commonText(
                  textColor: ByColorUtil.colorF2,
                  text: '内容由AI生成，禁止利用功能从事违法活动。'),
            ],
          ),
      ],
    );
  }

  // 微信读书深夜模式样式
  MarkdownStyleSheet _createNightModeStyle() {
    return MarkdownStyleSheet(
      // 普通文本样式
      p: const TextStyle(
        color: ByColorUtil.colorF2, // 浅灰色文本
        fontSize: 14.0,
      ),

      // 标题样式
      h1: const TextStyle(
        color: Color(0xFFFFFFFF), // 白色标题
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
      h2: const TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
      h3: const TextStyle(
        color: ByColorUtil.colorF1,
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      ),
      h4: const TextStyle(
        color: ByColorUtil.colorF1,
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
      ),

      strong: const TextStyle(
          color: ByColorUtil.colorF1,
          fontWeight: FontWeight.bold,
          fontSize: 14.0),

      a: const TextStyle(
          color: ByColorUtil.colorF1, decoration: TextDecoration.underline),

      em: const TextStyle(
          color: ByColorUtil.colorC1, decoration: TextDecoration.underline),

      // 列表样式
      listBullet: const TextStyle(
        color: Color(0xFF8A8A8E),
      ),

      // 代码块样式
      code: const TextStyle(
        color: Color(0xFFD0D0D0),
        backgroundColor: Color(0xFF2C2C2E),
        fontSize: 14.0,
      ),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(4.0),
      ),

      // 引用样式
      blockquote: const TextStyle(
        color: Color(0xFF8A8A8E),
        fontStyle: FontStyle.italic,
      ),

      // 表格样式
      tableHead: const TextStyle(
        color: Color(0xFFFFFFFF),
        fontWeight: FontWeight.bold,
      ),
      tableBody: const TextStyle(
        color: Color(0xFFBBBBBB),
      ),
      tableBorder: TableBorder.all(
        color: const Color(0xFF3A3A3C),
        width: 0.5,
      ),
    );
  }

  ///Ai续写按钮
  Widget _aiContinueWriteBtn() {
    bool isRegisterNovelHomeController  =  Get.isRegistered<NovelHomeController>();
    NovelHomeSourceType? source ;
    if(isRegisterNovelHomeController){
      source =  Get.find<NovelHomeController>().source;
    }
    if(source!=null){
      if(source!=NovelHomeSourceType.normal){
        return const SizedBox();
      }
    }
    if (isPostToContinueWrite == true && widget.novelID != null) {
      if (isTimerFinish) {
        return const SizedBox();
      }
      return Row(
        children: [
          Container(
            width: 166.w,
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.w),
              color: const Color(0xFFD7F97D).withOpacity(0.1),
            ),
            child: Row(
              children: [
                const CupertinoActivityIndicator(
                  color: ByColorUtil.colorC1,
                  radius: 6,
                ),
                SizedBox(
                  width: 4.w,
                ),
                ByWidgetsUtil.commonText(
                    fontSize: 14.sp,
                    textColor: ByColorUtil.colorC1,
                    text: '章节大纲已开始续写'),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
              onTap: () {
                Get.toNamed(Routes.novelCreateOutline,
                    arguments: {'novelID': controller.novelID})?.then((_) {
                  controller.loadData();
                });
              },
              child: Row(
                children: [
                  Text(
                    "立即查看",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14.sp,
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Image.asset(
                    'assets/home/share_sales/open_business_icon.png',
                    width: 8,
                    height: 8,
                  ),
                ],
              ))
        ],
      );
    }
    return GestureDetector(
      onTap: () {
        widget.aiContinueWriteEvent?.call();
        Get.find<ProfileController>().updateUserInfo();
      },
      child: Container(
        width: 59.w,
        height: 32.w,
        margin: EdgeInsets.only(
          top: 5.w,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            // 275度角的渐变方向
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [0.0, 1.0],
            colors: [
              // 透明度8%的#98fc4a
              Color.fromRGBO(152, 252, 116, 0.08),
              // 透明度32%的#98fc4a
              Color.fromRGBO(152, 252, 116, 0.32),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color.fromRGBO(152, 252, 116, 0.2),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          "Ai续写",
          style: TextStyle(
            color: Color(0XFF98FC4A),
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  ///流式输出完后更新该小说的状态
  void updateNovel(int novelID) {
    HttpUtils.get(
      NovelApis.novelInfo,
      {'id': novelID},
      success: (data) {
        if (data['status'] == 200) {
          NovelBean novelBean = NovelBean.fromJson(data['data']);
          Get.log("===流式输出完后小说的状态数据===${novelBean.toJson()}");
          if (novelBean.stage == 10) {
            if (mounted) {
              if (widget.isStreaming == true) {
              } else {
                if(mounted){
                  setState(() {
                    isCompleted = true;
                    isTimerFinish = false;
                  });
                }
                _cancelQueryNovelTimer();
              }
            }
          } else {
            if (widget.isStreaming == true) {
            } else {

              if(widget.isCompleted==true){
               if(mounted){
                 setState(() {
                   isCompleted = false;
                 });
               }
               _cancelQueryNovelTimer();
              }

              // if (mounted) {
              //   setState(() {
              //
              //   });
              // }
            }
          }
        }
      },
    );
  }
}

// 1. 创建自定义段落 Builder
class CustomParagraphBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitText(md.Text text, TextStyle? preferredStyle) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0), // 上下间距
        child: _buildSelectableText(
            text.text, Text(text.text, style: preferredStyle),
            style: preferredStyle));
  }

  // 构建可选择的文本组件
  Widget _buildSelectableText(
    String text,
    Widget child, {
    TextStyle? style,
  }) {
    // 提取文本内容（处理嵌套结构）
    if (text.isEmpty) return child;

    return SelectableText.rich(
      TextSpan(
        text: text,
        style: style,
      ),
      // 自定义上下文菜单（添加复制选项）
      contextMenuBuilder: (context, editableTextState) {
        return AdaptiveTextSelectionToolbar(
          anchors: editableTextState.contextMenuAnchors,
          children: [
            TextSelectionToolbarTextButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                // 复制选中的文本到剪贴板
                final selectedText =
                    editableTextState.textEditingValue.selection.textInside(
                  editableTextState.textEditingValue.text,
                );
                ClipboardManager.clip(selectedText);
                // 显示提示（可选）
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已复制到剪贴板')),
                );
              },
              child: const Text('复制'),
            ),
          ],
        );
      },
    );
  }
}
