

import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';

import '../../../core/network/novel_apis.dart';
import '../../../core/widget/view/loading_dialog.dart';

class ShortStoryRequest {
  static Future<void> retryBrief(
    ///小说ID
    int novelID, {
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) async{
    ///创建细纲
    LoadingDialog().show(message: '重新生成中...');
    HttpUtils.post(
      NovelApis.shortStoryRetryBrief,
      {
        'short_novel_id': novelID,
      },
      success: (data) {
        LoadingDialog().dismiss();
        if (data['status'] == 200) {
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

  ///生成短故事
  static Future<void> createShortStoryContent(
    int novelID,{
    void Function(dynamic)? onSuccess,
    void Function(int, String)? onFailed,
  }) async{
    LoadingDialog().show(message: '创建中...');
    HttpUtils.post(
      NovelApis.shortStoryCreateContent,
      {
        'short_novel_id': novelID
      },
      success: (data) {
        LoadingDialog().dismiss();
        if (data['status'] == 200) {
          onSuccess?.call(data);
        }
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        onFailed?.call(code, msg);
        BotToast.showText(text: msg);
      },
    );
  }
}