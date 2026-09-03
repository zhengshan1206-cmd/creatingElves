/*
 * @Author: cold-x
 * @Date: 2025-08-05 09:53:50
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-08-21 10:59:24
 * @FilePath: /fastcreationmaster/lib/home/long_novel/view/content_recreate_view.dart
 * @Description: 
 */
import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/network/http_steaming.dart';
import 'package:fast_creation_master/core/util/by_screen_utils.dart';
import 'package:fast_creation_master/core/widget/view/by_button.dart';
import 'package:fast_creation_master/core/widget/view/diolog_view.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

///AI帮我写页面
class ContentRecreateView extends StatefulWidget {
  const ContentRecreateView({
    super.key,
    required this.args,
    required this.interface,
    this.userAction});
  ///使用文本信息
  final Function(String)? userAction;
  ///参数
  final dynamic args;
  ///流式输出接口
  final String interface;

  @override
  State<ContentRecreateView > createState() => _ContentRecreateViewState();
}

class _ContentRecreateViewState extends State<ContentRecreateView > {

  late final ContentRecreateController controller;

  @override
  void initState() {
    controller = Get.put(ContentRecreateController());
    controller.args = widget.args;
    controller.startStreaming(widget.interface);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        controller.comfirmBack();
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: ByColorUtil.colorBg2,
          borderRadius: BorderRadius.circular(12.w)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ByWidgetsUtil.commonText(
                  text: '故事简介',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  textColor: ByColorUtil.colorF1),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    controller.comfirmBack();
                  },
                  child: Container(
                    alignment: Alignment.centerRight,
                    width: 48,
                    height: 32,
                    child: Image.asset(
                      'assets/global/common/btn_close.png',
                      width: 32,
                      height: 32,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 12.w,),
            Container(
              height: 566.h,
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.w),
                color: ByColorUtil.color2E3038,
              ),
              child: Obx(() => SingleChildScrollView(
                controller: controller.scroll,
                child: ByWidgetsUtil.commonText(
                  maxLines: 99999,
                  text: controller.content.value, 
                  textColor: ByColorUtil.colorF2),
              )),
            ),
            SizedBox(height: 12.w,),
            SizedBox(
              height: 48.w,
              child: Obx(() => Opacity(
                opacity: controller.isGenerating.value ? 0.3 : 1.0,
                child: Row(
                  children: [
                    ByButton.gradientBtn(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      title: '重新生成', 
                      bgColor: ByColorUtil.color2E3038,
                      textColor: ByColorUtil.colorC1,
                      onClick: (){
                        ///重新生成
                        if (!controller.isGenerating.value) {
                          controller.startStreaming(widget.interface);
                        }
                    }),
                    SizedBox(width: 12.w,),
                    Expanded(
                      child: ByButton.gradientBtn(
                          gradient: const LinearGradient(colors: [
                            Color(0xFF82D7FF),
                            Color(0xFFBFE0FF),
                            Color(0xFFDCC8FF)
                          ]),
                          title: '使用',
                          textColor: Colors.black,
                          onClick: () {
                            ///使用AI生成的文本
                            if(!controller.isGenerating.value) {
                              widget.userAction?.call(controller.content.value);
                              Get.back();
                            }
                          }),
                    )
                  ],
                )),
              ),
            ),
            SizedBox(height: ByScreenUtils.bottomSafeHeight + 4.w,),
          ],
        ),
      ),
    );
  }
}


class ContentRecreateController extends GetxController {

  ScrollController scroll = ScrollController();
  ///流式输出参数
  Map<String, dynamic> args = {};
  HttpSteaming? streaming;
  ///是否流式中
  Rx<bool> isGenerating = false.obs;
  ///流式输出内容
  Rx<String> content = 'Ai生成中...'.obs;

  ///生成中时返回拦截
  void comfirmBack() {
    if (isGenerating.value) {
      Get.dialog(NovelDialog(
        showCancelBtn: false,
        content: '当前内容还在生成中，确定要返回吗？',
        cancelText: '取消',
        cancelColor: ByColorUtil.colorBg4,
        cancelTextColor: ByColorUtil.colorF1,
        confirmText: '确定返回',
        confirmTextColor: Colors.black,
        confirmBgColor: ByColorUtil.colorC1,
        onConfirm: () {
          Get.back();
        },
      ));
    }
    else {
      Get.back();
    }
  }

  ///开始流式输出
  void startStreaming(String api) {
    streaming ??= HttpSteaming();
    content.value = 'Ai生成中...';
    isGenerating.value = true;
    streaming?.fetchContentGeneration(args, api,
      streaming: (p0) {
        if(content.value == 'Ai生成中...') {
          content.value = p0;
        }
        else {
          content.value += p0;
        }
        _scrollToBottom();
      },
      complete: () {
        isGenerating.value = false;
        _scrollToBottom();
      },
      error: (p0) {
        isGenerating.value = false;
      },);
  }

  @override
  void dispose() {
    streaming?.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    // 确保在下一帧滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) {
        scroll.jumpTo(scroll.position.maxScrollExtent);
      }
    });
  }
}