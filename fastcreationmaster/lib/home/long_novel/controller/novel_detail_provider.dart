/*
 * @Author: cold-x
 * @Date: 2025-06-27 13:55:10
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-08-28 14:51:04
 * @FilePath: /fastcreationmaster/lib/home/long_novel/controller/novel_detail_provider.dart
 * @Description: 
 */


import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_common/event/common_event.dart';
import 'package:byhy_app_common_utils/app_http/apis.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:fast_creation_master/core/widget/view/loading_dialog.dart';
import 'package:fast_creation_master/global/other/illegal_words/controller/illegal_words_manager.dart';
import 'package:fast_creation_master/home/long_novel/controller/stream_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/cache/global_controller.dart';
import '../../../core/network/novel_apis.dart';
import '../../../core/util/page_helper.dart';
import '../../../core/widget/view/diolog_view.dart';
import '../../../core/widget/view/muti_status_view.dart';
import '../../../global/other/event_tracking/event_tracking.dart';
import '../../../global/routes/routes_utils.dart';
import '../../../profile/continue_writing/continue_writing_option_dialog.dart';
import '../bean/novel_chapter_bean.dart';
import '../request/chapter_request.dart';

class NovelDetailProvider extends StreamingProvider {

  ///小说id
  int? novelID;
  ///小说正文或者细纲id
  int? contentID;
  ///小说大纲id
  int? outlineID = 0;

  ///大纲列表数据
  List<ChapterBean> itemList = [];

  ///临时缓存正文内容
  Map<String, ChapterBean> contentMap = {};

  ///当前正文数据
  ChapterBean? chapterBean;

  ///当前章节数顺序
  int currentChapter = 0;

  ///小说的总章节数
  int chapterNum = 0;

  ///是否需要直接跳转到当前的流式输出章节
  bool jumpToStreamChapter = false;

  ///是否是创作广场入口
  bool isSquare = false;

  ///是否是引导页入口
  bool isGuide = false;

  ///防抖操作
  bool isAdding = false;
  bool isMinusing = false;

  ///底部banner
  List<BannerBean> bannerList = [];

  ///分页
  final PageHelper _pageHelper = PageHelper();
  PageHelper get pageHelper => _pageHelper;


  ///当前小说的状态
  int? stage;

  void delayToLoad() {
    Future.delayed(Duration(seconds: jumpToStreamChapter ? 3 : 0), (){
      if(jumpToStreamChapter) {
        fetchGeneratingChapter();
      }
      else {
        fetchNovelInfo(
        showLoading: true);
      }
      if(itemList.isEmpty) {
        fetchNovelInfoList();
      }
    });
  }

  ///切换章节
  void toggleChapter(bool isAdd) {
    ///生成中，最小为0，最大章节时返回不操作
    if(isGenerating || (currentChapter == 0 && !isAdd) || (currentChapter == chapterNum - 1 && isAdd)) {
      return;
    }
    if (isAdd) {
      ///防抖
      if (isAdding) {
        return;
      }
      else {
        isAdding = true;
        Future.delayed(const Duration(milliseconds: 300), () {
          isAdding = false;
        });
      }
      if (chapterBean!.nextStage! == 7){
        retryChapter();
        return;
      }
      if (chapterBean!.nextStage! <= 3){
        BotToast.showText(text: '当前已经是生成的最新一章了');
        return;
      }
      currentChapter ++;
      contentID = chapterBean!.nextID;
    }
    else {
      ///防抖
      if (isMinusing) {
        return;
      }
      else {
        isMinusing = true;
        Future.delayed(const Duration(milliseconds: 300), () {
          isMinusing = false;
        });
      }
      currentChapter --;
      contentID = chapterBean!.preID;
    }
    reloadData();
  }

  ///重试失败的章节小说
  void retryChapter() {
    Get.dialog(NovelDialog(
          showCancelBtn: false,
          cancelText: '稍后生成',
          confirmText: '重新生成',
          content: '该章节正文生成失败，需要重新生成，\n生成失败不会消耗字数',
          onConfirm: () {
            ///重新生成失败章节
            ChapterRequest.retryChapter(
              novelID!, 
              chapterBean!.nextID!,
              onSuccess: () {
                LoadingDialog().show(message: '重新生成中...');
                Future.delayed(const Duration(seconds: 3), (){
                  LoadingDialog().dismiss();
                  toggleChapter(true);
                });
              },);
          },
        ));
  }

  ///重新获取数据
  void reloadData() {
    if (currentChapter >= chapterNum || chapterBean!.stage! < 4){
      BotToast.showText(text: '当前已经是生成的最新一章了');
      currentChapter --;
      return;
    }
    content = '';
    if(isSquare){
      fetchSquareNovelInfo();
    }
    else {
      fetchNovelInfo(showLoading: false);
    }
  }

  void _scrollToTop() {
    // 滚动到顶部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.minScrollExtent);
      }
    });
  }

  ///获取当前正在生成的章节数id
  void fetchGeneratingChapter({
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    statusType = MultiStatusType.statusLoading;
    HttpUtils.get(
      NovelApis.generatingChapter,
      {
        'id': novelID,
      },
      success: (data) {
        if (data['status'] == 200) {
          ChapterBean bean = ChapterBean.fromJson(data['data']);
          contentID = bean.id;
          fetchNovelInfo();
        }
      },
      fail: (code, msg) {
        onFailed?.call(code, msg);
        BotToast.showText(text: msg);
      },
    );
  }

  ///获取章节细纲列表页
  void fetchNovelInfoList({
    bool? showLoading,
    bool? jumptoStreamChapter = false,
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    HttpUtils.get(
      NovelApis.novelDetailList,
      {
        'id': novelID,
        'page': pageHelper.page,
        'page_size': pageHelper.row
      },
      success: (data) {
        if (data['status'] == 200) {
          final List items = data["data"]['data'] ?? [];
          List<ChapterBean> beans = List<ChapterBean>.from(items.map(
            (ele) => ChapterBean.fromJson(ele),
          ));
          chapterNum = data['data']['total'];
          itemList.addAll(beans);
          notifyListeners();
          onSuccess?.call();
        }
      },
      fail: (code, msg) {
        onFailed?.call(code, msg);
        BotToast.showText(text: msg);
      },
    );
  }

  ///获取小说正文详情
  void fetchNovelInfo({
    bool? showLoading = true,
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    ///是否使用本地缓存
    if(contentMap.keys.contains('$contentID')) {
      chapterBean = contentMap['$contentID']!;
      content = chapterBean?.novelContent ?? '';
      if (isGenerating) {
        finishStream();
      } 
      updateStreamingContent(chapterBean?.novelContent ?? '');
      _scrollToTop();
      return;
    }
    if(showLoading!) {
      statusType = MultiStatusType.statusLoading;
    }
    HttpUtils.get(
      NovelApis.novelDetailInfo,
      {
        'id': novelID,
        'content_id': contentID
      },
      success: (data) {
        if (data['status'] == 200) {
          chapterBean = ChapterBean.fromJson(data['data']);
          content = chapterBean?.novelContent ?? '';
          currentChapter = chapterBean!.index! - 1;
          statusType = MultiStatusType.statusContent;
          ///无流式，内容已经生成完成
          if (chapterBean?.stage == 6) {
            ///缓存正文内容
            contentMap['$contentID'] = chapterBean!; 
            if (isGenerating) {
              finishStream();
            } 
            updateStreamingContent(content);
            _scrollToTop();
          }
          ///流式输出
          else {
            if(chapterBean!.novelStreamTaskID!.isNotEmpty) {
              bool hasNextChapter = chapterBean!.nextStage! > 3;
              wsConnect(
                chapterBean!.novelStreamTaskID!, chapterBean!.streamURL,
                hasNext: hasNextChapter,
                successStream: () {
                  print('______$isGenerating');
                  ///自动流式下一章内容
                  print('___________流式输出结束，下一章是否能流式输出：$hasNextChapter');
                  eventBus.fire(RefreshAiContinueWriteEvent());
                  if (hasNextChapter){
                    ///延迟加载
                    Future.delayed(const Duration(seconds: 3), (){
                      toggleChapter(true);
                    });
                  }
                },);
            }
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

  ///广场创作页
  ///获取章节细纲列表页
  void fetchSquareNovelInfoList({
    bool? showLoading,
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    HttpUtils.get(
      isGuide ? NovelApis.novelGuideDetailList : NovelApis.novelSquareDetailList,
      {
        'id': novelID,
        'page': pageHelper.page,
        'page_size': pageHelper.row
      },
      success: (data) {
        if (data['status'] == 200) {
          final List items = data["data"]['data'] ?? [];
          List<ChapterBean> beans = List<ChapterBean>.from(items.map(
            (ele) => ChapterBean.fromJson(ele),
          ));
          chapterNum = data['data']['total'];
          itemList.addAll(beans);
          notifyListeners();
          onSuccess?.call();
        }
      },
      fail: (code, msg) {
        onFailed?.call(code, msg);
        BotToast.showText(text: msg);
      },
    );
  }

  ///广场创作页
  ///获取小说正文详情
  void fetchSquareNovelInfo({
    bool? showLoading = true,
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    ///是否使用本地缓存
    if(contentMap.keys.contains('$contentID')) {
      chapterBean = contentMap['$contentID']!;
      content = chapterBean?.novelContent ?? '';
      updateStreamingContent(chapterBean?.novelContent ?? '');
      _scrollToTop();
      return;
    }
    if(showLoading!) {
      statusType = MultiStatusType.statusLoading;
    }
    HttpUtils.get(
      isGuide ? NovelApis.novelGuideChapterDetails : NovelApis.novelSquareDetailInfo,
      {
        'id': novelID,
        'chapter_id': contentID
      },
      success: (data) {
        if (data['status'] == 200) {
          chapterBean = ChapterBean.fromJson(data['data']);
          content = chapterBean?.novelContent ?? '';
          statusType = MultiStatusType.statusContent;
          currentChapter = chapterBean!.index! - 1;
          ///缓存正文内容
          contentMap['$contentID'] = chapterBean!; 
          updateStreamingContent(content);
          _scrollToTop();
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

  /// [postion] banner所处的位置
  loadBanners({
    required int postion,
  }) {
    HttpUtils.get(
      APIs.homeBanner,
      {
        "postion": postion,
      },
      showMsgWhenFailed: false,
      success: (data) {
        final List bannerData = data["data"]["item"] ?? [];
        // byDebugPrint(data["item"], tag: "banner所处的位置");
        List<BannerBean> beans =
            bannerData.map((e) => BannerBean.fromJson(e)).toList();
        bannerList = beans;
        if (bannerList.isNotEmpty &&
            !GlobalController.instance.banner.novelDetailBanner) {
          BannerBean bean = beans.first;
          EventTracking.reportDataPoint(
            pageTag: 'banner',
            operateType: 'view',
            funcDetailTag: bean.id.toString(),
            funcDetailImg: bean.imgUrl,
          );
        }
        notifyListeners();
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
      },
    );
  }

  ///违禁词检测
  void illegalWordsDetect() {
    IllegalWordsManager illegalWordsManager = IllegalWordsManager();
    illegalWordsManager.detectIllegalWords(content, showDialog: true, onSuccess: (p0) {
      content = p0;
      notifyListeners();
    },);
  }

  ///ai续写
  void aiContinueWriteEvent(int? id,){
    showModalBottomSheet(
        context: Get.context!,
        isDismissible: false,
        enableDrag: false,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return ContinueWritingOptionDialog(novelId: id,);
        });
  }
}