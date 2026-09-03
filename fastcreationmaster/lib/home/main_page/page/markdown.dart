/*
 * @Author: cold-x
 * @Date: 2025-07-10 19:25:21
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-07-10 20:03:33
 * @FilePath: /fastcreationmaster/lib/home/main_page/page/markdown.dart
 * @Description: 
 */


import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/widget/view/by_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';

import '../../../global/ui/colors.dart';

class MarkdownView extends StatefulWidget {
  const MarkdownView({super.key});

  @override
  State<MarkdownView> createState() => _MarkdownViewState();
}

class _MarkdownViewState extends State<MarkdownView> {

  String content = '';
  int count = 0;
  String current = '';
  String text = '';
  ScrollController scrollController = ScrollController();
  bool running = true;

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose() {
    running = false;
    super.dispose();
  }

  void getText() {
    for (int i = 0; i < 10; i ++){
      content += text;
    };
  }

  void addContent() {
    count++;
    if (12 * count < content.length && running) {
      setState(() {
        current = content.substring(0, 12 * count);
        _scrollToBottom();
      });
      Future.delayed(const Duration(milliseconds: 10), () {
        addContent();
      });
    }
  }

  Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/markdown.txt');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ByColorUtil.colorBg1,
      appBar: buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Markdown(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                data: current,
                styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(
                        color: ByColorUtil.colorF1, fontSize: 14),
                    h1: const TextStyle(
                        color: ByColorUtil.colorF1, fontSize: 16),
                    h2: const TextStyle(
                        color: ByColorUtil.colorF1, fontSize: 16),
                    h3: const TextStyle(
                        color: ByColorUtil.colorF1, fontSize: 16),
                    h4: const TextStyle(
                        color: ByColorUtil.colorF1, fontSize: 14),
                    a: const TextStyle(
                        color: ByColorUtil.colorF1,
                        decoration: TextDecoration.underline),
                    code: TextStyle(
                        color: Colors.orange,
                        backgroundColor: Colors.grey[100]),
                    blockquote: const TextStyle(
                        color: ByColorUtil.colorF1,
                        fontStyle: FontStyle.italic),
                    listBullet: const TextStyle(color: ByColorUtil.colorF1),
                    // 更多样式...
                  ),),
                
            ),
          ),
          const SizedBox(height: 12,),
          Row(
            children: [
              const SizedBox(width: 10,),
              SizedBox(
                width: 80,
                child: ByWidgetsUtil.commonText(text: "${current.length}字",fontSize: 17, textColor: Colors.red)),
              const SizedBox(width: 10,),
              Expanded(
                child: ByButton.gradientBtn(title: '获取', onClick: () async{
                  text = await loadAsset();
                }),
              ),
              const SizedBox(width: 10,),
              Expanded(
                child: ByButton.gradientBtn(title: '展示', onClick: (){
                  getText();
                  addContent();
                }),
              ),
            ],
          )
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
          text: 'Markdown',
          textColor: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w500),
    );
  }

  void _scrollToBottom() {
    // 确保在下一帧滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(mounted)scrollController.jumpTo(scrollController.position.maxScrollExtent);
      // if (scrollController.hasClients) {
      //   scrollController.animateTo(
      //     ,
      //     duration: const Duration(milliseconds: 20),
      //     curve: Curves.easeOut,
      //   );
      // }
    });
  }
}