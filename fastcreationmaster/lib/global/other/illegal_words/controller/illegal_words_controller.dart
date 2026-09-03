

import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:fast_creation_master/core/controller/base_controller.dart';
import 'package:fast_creation_master/core/network/novel_apis.dart';
import 'package:fast_creation_master/core/widget/view/loading_dialog.dart';
import 'package:fast_creation_master/core/widget/view/muti_status_view.dart';
import 'package:fast_creation_master/global/other/illegal_words/controller/illegal_words_manager.dart';
import 'package:fast_creation_master/home/long_novel/bean/novel_chapter_bean.dart';
import 'package:get/get.dart';
import '../bean/illegal_words_bean.dart';

class IllegalWordsController extends BaseController {

  //小说id
  int novelID;
  IllegalWordsController({
    required this.novelID,
    });

  RxList<NovelIllegalWordsBean> itemList = <NovelIllegalWordsBean>[].obs;
  ///违禁词总数
  Rx<int> totolNum = 0.obs;

  IllegalWordsManager manager = IllegalWordsManager();

  @override
  void onInit() {
    super.onInit();
    checkNovelList(isFirstLoad: true);
  }

  ///获取小说违禁词列表
  void checkNovelList({
    bool isFirstLoad = false,
    void Function(dynamic)? onSuccess,
  }) {
    if(isFirstLoad){
      statusType.value = MultiStatusType.statusLoading;
    }
    HttpUtils.get(
      NovelApis.novelIllegalWordsList,
      {
        'id': novelID
      },
      success: (data) {
        if(data['status'] == 200) {
          final items = data['data']['list'];
          totolNum.value = data['data']['total_forbidden_num'];
          List<NovelIllegalWordsBean> beans = List<NovelIllegalWordsBean>.from(items.map(
              (ele) => NovelIllegalWordsBean.fromJson(ele),
            ));
          itemList.value = beans;
          onSuccess?.call(data);
          if(beans.isEmpty) {
            statusType.value = MultiStatusType.statusEmpty;
          }
          else {
            statusType.value = MultiStatusType.statusContent;
          }
        }
        else {
          statusType.value = MultiStatusType.statusNoNetWork;
        }
      },
      fail: (code, msg) {
        statusType.value = MultiStatusType.statusNoNetWork;
        BotToast.showText(text: msg);
      },
    );
  }

  ///获取小说正文详情
  void fetchNovelInfo(NovelIllegalWordsBean bean, {
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    LoadingDialog().show();
    HttpUtils.get(
      NovelApis.novelDetailInfo,
      {
        'id': novelID,
        'content_id': bean.id
      },
      success: (data) {
        LoadingDialog().dismiss();
        if (data['status'] == 200) {
          ChapterBean chapterBean = ChapterBean.fromJson(data['data']);
          manager.content.value = chapterBean.novelContent ?? '';
          manager.updateBandedWords(bean.words!);
          manager.updateSelectedBandedWord(manager.bandedWords.first);
          manager.showIllegalWordsDialog(manager: manager, onSuccess: (p0) {
            editChapterInfo(bean.id!, p0);
          },);
          onSuccess?.call();
        }
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        onFailed?.call(code, msg);
        BotToast.showText(text: msg);
      },
    );
  }

  ///修改小说章节内容
  void editChapterInfo(int contentID, String content, {
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    LoadingDialog().show();
    HttpUtils.post(
      NovelApis.editChapterInfo,
      {
        'id': novelID,
        'content_id': contentID,
        'chapter_content': content
      },
      success: (data) {
        LoadingDialog().dismiss();
        if (data['status'] == 200) {
          checkNovelList();
          onSuccess?.call();
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