/*
 * @Author: cold-x
 * @Date: 2025-06-26 09:21:22
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-08-21 16:54:43
 * @FilePath: /fastcreationmaster/lib/home/long_novel/controller/outline_detail_provider.dart
 * @Description: 
 */


import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:fast_creation_master/core/widget/view/loading_dialog.dart';
import 'package:fast_creation_master/home/long_novel/bean/novel_outline_bean.dart';
import 'package:fast_creation_master/home/long_novel/controller/novel_chapter_controller.dart';
import 'package:fast_creation_master/home/long_novel/controller/stream_controller.dart';
import 'package:get/get.dart';

import '../../../core/network/novel_apis.dart';
import '../../../core/widget/view/muti_status_view.dart';
import '../../../global/routes/app_pages.dart';

class OutlineDetailProvider extends StreamingProvider {
  
  OutlineBean? outlineBean;

  ///跳转至章节列表页
  void gotoChapterList() {
    Get.toNamed(Routes.novelCreateChapter, arguments: {
      'novelID': outlineBean?.novelID,
      'outlineID': outlineBean?.id
    })!.then((_){
      bool isRegister = Get.isRegistered<NovelChapterController>();
      if(isRegister) {
        Get.delete<NovelChapterController>();
      }
    });
  }

  ///获取大纲详情
  void fetchOutlineDetail(
    int id, {
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    statusType = MultiStatusType.statusLoading;
    HttpUtils.get(
      NovelApis.outlineInfo,
      {
        'outline_id': id
      },
      success: (data) {
        if (data['status'] == 200) {
          outlineBean = OutlineBean.fromJson(data['data']);
          content = data['data']['content'];
          statusType = MultiStatusType.statusContent;
          ///生成完成时
          if(outlineBean!.stage! > 2){
            updateStreamingContent(content);
          }
          ///生成中时流式输出
          else if(outlineBean?.stage == 2 && outlineBean!.streamTaskID!.isNotEmpty){
            wsConnect(outlineBean!.streamTaskID!, outlineBean!.streamURL!);
          }
          onSuccess?.call();
        }
        else {
          statusType = MultiStatusType.statusNoNetWork;
        }
      },
      fail: (code, msg) {
        statusType = MultiStatusType.statusNoNetWork;
        notifyListeners();
        onFailed?.call(code, msg);
        BotToast.showText(text: msg);
      },
    );
  }
  
  ///创建细纲
  void createNovelChapter({
    void Function()? onSuccess,
  }) {
    LoadingDialog().show(message: '细纲创建中...');
    HttpUtils.post(
      NovelApis.createChapter,
      {
        'id': outlineBean?.novelID,
        'outline_id': outlineBean?.id,
      },
      success: (data) {
        LoadingDialog().dismiss();
        if (data['status'] == 200) {
          gotoChapterList();
          fetchOutlineDetail(outlineBean!.id!);
          onSuccess?.call();
        }
        else {
          BotToast.showText(text: data['message']);
        }
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        BotToast.showText(text: msg);
      },
    );
  }
}