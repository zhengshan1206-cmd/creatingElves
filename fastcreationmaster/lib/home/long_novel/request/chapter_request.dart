


import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';

import '../../../core/network/novel_apis.dart';
import '../../../core/widget/view/loading_dialog.dart';

class ChapterRequest {
  static Future<void> retryChapter(
    ///小说ID
    int novelID, 
    ///章节ID
    int contentID, {
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) async{
    ///创建细纲
    LoadingDialog().show(message: '重新生成中...');
    HttpUtils.post(
      NovelApis.retryNovelContent,
      {
        'id': novelID,
        'content_id': contentID,
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
}