/*
 * @Author: cold-x
 * @Date: 2025-06-11 10:37:56
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-08-21 14:54:16
 * @FilePath: /fastcreationmaster/lib/home/tool/page/tool_finish_page.dart
 * @Description: 
 */

import 'package:byhy_app_common_utils/app_ui/by_widgets_util.dart';
import 'package:fast_creation_master/core/controller/base_record_controller.dart';
import 'package:fast_creation_master/core/util/clipboard.dart';
import 'package:fast_creation_master/core/widget/view/muti_status_view.dart';
import 'package:fast_creation_master/core/widget/view/progress_view.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../core/util/by_screen_utils.dart';
import '../../../core/widget/view/by_button.dart';
import '../../../global/routes/app_pages.dart';
import '../controller/tool_finish_provider.dart';

class ToolFinishPage extends StatefulWidget {
  const ToolFinishPage({
    super.key,
  });

  @override
  State<ToolFinishPage> createState() => _ToolFinishPageState();
}

class _ToolFinishPageState extends State<ToolFinishPage>
    with AutomaticKeepAliveClientMixin {
  late final String title;

  ScrollController? scroll;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ToolFinishProvider>();
    provider.fetchContent();
    provider.startListening();
    title = provider.type!.title;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
      actions: [
        buildActions(context),
      ],
    );
  }

  Widget buildActions(BuildContext context) {
    final provider = context.read<ToolFinishProvider>();
    return !provider.isStreaming!
        ? Container()
        : GestureDetector(
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
              Get.toNamed(Routes.record, arguments: {'type': provider.type});
            },
          );
  }

  Widget buildBody(BuildContext context) {
    return Consumer<ToolFinishProvider>(builder: (context, provider, child) {
      return MultiStatusView(
        currentStatus: provider.statusType,
        action: () {
          provider.fetchContent();
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Stack(
            children: [
              ///短故事才有标题
              if (provider.type == CreationType.folkNovel)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 56.w + ByScreenUtils.bottomSafeHeight + 10.w,
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: ByColorUtil.colorBg2,
                      borderRadius: BorderRadius.circular(10.w),
                    ),
                    child:

                        ///生成标题
                        ByWidgetsUtil.commonText(
                            fontSize: 17,
                            textColor: Colors.white,
                            text: provider.title),
                  ),
                ),
              Positioned(
                top: provider.type == CreationType.folkNovel ? 36.w : 0,
                left: 0,
                right: 0,
                bottom: 56.w + ByScreenUtils.bottomSafeHeight + 10.w,
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  child: SingleChildScrollView(
                    controller: provider.scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ///生成内容
                        ByWidgetsUtil.commonText(
                            maxLines: 99999,
                            fontSize: 14.sp,
                            textColor: ByColorUtil.colorF2,
                            text: provider.content),
                        if(!provider.isGenerating && provider.content.isNotEmpty)
                        SizedBox(height: 12.w,),
                        if(!provider.isGenerating && provider.content.isNotEmpty)
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
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 56.w + ByScreenUtils.bottomSafeHeight,
                  padding: EdgeInsets.only(
                      top: 4.w, bottom: ByScreenUtils.bottomSafeHeight + 4.w),
                  child: SizedBox(
                    height: 48.w,

                    ///生成进度，以及复制内容
                    child: provider.isGenerating
                        ? _buildProgressView()
                        : Row(
                            children: [
                              Expanded(
                                child: ByButton.gradientBtn(
                                  textColor: ByColorUtil.colorF5,
                                  bgColor: ByColorUtil.color2E3038,
                                  title: '复制',
                                  onClick: () {
                                    if (provider.type ==
                                        CreationType.folkNovel) {
                                      ///复制标题
                                      ClipboardManager.clip(
                                          '${provider.title}\n\n${provider.content}');
                                    } else {
                                      ///复制
                                      ClipboardManager.clip(
                                          provider.bean?.content);
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: ByButton.gradientBtn(
                                  textColor: Colors.black,
                                  title: '继续创作',
                                  onClick: () {
                                    provider.continueCreation();
                                  },
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildProgressView() {
    final provider = context.read<ToolFinishProvider>();
    return ProgressView(
      progress: provider.progress,
    );
  }
}
