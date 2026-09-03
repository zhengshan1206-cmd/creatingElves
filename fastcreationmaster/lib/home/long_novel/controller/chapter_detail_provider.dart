/*
 * @Author: cold-x
 * @Date: 2025-06-26 15:17:15
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-08-22 11:41:27
 * @FilePath: /fastcreationmaster/lib/home/long_novel/controller/chapter_detail_provider.dart
 * @Description: 
 */

import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:fast_creation_master/home/long_novel/bean/novel_chapter_bean.dart';
import 'package:fast_creation_master/home/long_novel/controller/stream_controller.dart';

import '../../../core/network/novel_apis.dart';
import '../../../core/widget/view/muti_status_view.dart';

class ChapterDetailProvider extends StreamingProvider {
  
  ChapterBean? chapterBean;

  ///获取章节细纲详情
  void fetchChapterDetail(
    int novelID, int contentID, {
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    statusType = MultiStatusType.statusLoading;
    HttpUtils.get(
      NovelApis.chapterInfo,
      {
        'id': novelID,
        'content_id': contentID
      },
      success: (data) {
        if (data['status'] == 200) {
          chapterBean = ChapterBean.fromJson(data['data']);
          content = chapterBean?.content ?? '';
          statusType = MultiStatusType.statusContent;
          ///生成完成时
          if(chapterBean!.stage! > 2){
            updateStreamingContent(content);
          }
          ///生成中时流式输出
          else if(chapterBean!.stage == 2 && chapterBean!.chapterStreamTaskID!.isNotEmpty){
            wsConnect(chapterBean!.chapterStreamTaskID!, chapterBean!.streamURL);
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
}