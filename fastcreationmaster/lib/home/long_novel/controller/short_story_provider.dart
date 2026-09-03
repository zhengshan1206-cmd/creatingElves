/*
 * @Author: cold-x
 * @Date: 2025-06-27 13:55:10
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-08-27 16:14:24
 * @FilePath: /fastcreationmaster/lib/home/long_novel/controller/short_story_provider.dart
 * @Description: 
 */


import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:fast_creation_master/core/widget/view/loading_dialog.dart';
import 'package:fast_creation_master/core/widget/view/share_view.dart';
import 'package:fast_creation_master/home/long_novel/controller/brief_detail_provider.dart';
import 'package:fast_creation_master/home/long_novel/controller/stream_controller.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../core/controller/base_record_controller.dart';
import '../../../core/network/file_download.dart';
import '../../../core/network/novel_apis.dart';
import '../../../core/service/share_service.dart';
import '../../../core/util/page_helper.dart';
import '../../../core/widget/view/muti_status_view.dart';
import '../../../core/widget/view/provider_page_tracker.dart';
import '../bean/novel_bean.dart';
import '../bean/novel_chapter_bean.dart';
import '../page/novel_brief_page.dart';

class ShortStoryProvider extends StreamingProvider {

  ///小说id
  int? novelID;

  ///大纲列表数据
  List<ChapterBean> itemList = [];

  ///临时缓存正文内容
  Map<String, ChapterBean> contentMap = {};

  ///小说数据
  NovelBean? novelBean;

  ///小说的总章节数
  int chapterNum = 0;


  ///是否是创作广场入口
  bool isSquare = false;

  ///短故事小说流式输出url
  String streamURL = '';
  ///短故事小说流式输出任务ID
  String streamTaskID = '';

  ///分页
  final PageHelper _pageHelper = PageHelper();
  PageHelper get pageHelper => _pageHelper;


  // void _scrollToTop() {
  //   // 滚动到顶部
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (scrollController.hasClients) {
  //       scrollController.jumpTo(scrollController.position.minScrollExtent);
  //     }
  //   });
  // }

  ///进入灵感页
  void gotoBriefPage() {
    final provider = BriefDetailProvider();
    provider.type = CreationType.shortStory;
    ///不显示底部按钮
    provider.showBottom = false;
    ByNavRouterUtils.push(
      Get.context!,
      trackProviderPage(
        pageId: '/novel_brief_page',
        widget: ChangeNotifierProvider(
          create: (context) => provider,
          child: NovelBriefPage(
            novelID: novelID!,
          ),
        ),
      ),
    );
  }

  ///分享小说链接至微信、朋友圈
  void shareNovel(String url) {
    Get.bottomSheet(
      ShareView(
        title: novelBean?.title,
        desc: novelBean?.introduce,
        webURL: url),
    );
  }

  ///获取小说详情
  void fetchNovelDetail(
    int id, {
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    statusType = MultiStatusType.statusLoading;
    HttpUtils.get(
      NovelApis.shortStoryInfo,
      {
        'short_novel_id' : id
      },
      success: (data) {
        if (data['status'] == 200) {
          novelBean = NovelBean.fromJson(data['data']);
          onSuccess?.call();
          ///生成完成时
          if(novelBean!.stage! > 5){
            // briefGenerateFailed();
            fetchShortStoryList();
          }
          ///生成中时流式输出
          else if(novelBean?.stage == 5 && novelBean!.contentStreamTaskID!.isNotEmpty){
            statusType = MultiStatusType.statusContent;
            wsConnect(novelBean!.contentStreamTaskID!, novelBean!.contentStreamURL!,);
          }
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

  

  ///获取正文列表
  void fetchShortStoryList({
    bool isRefresh = true,
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    HttpUtils.get(
      NovelApis.shortStoryContentList,
      {
        'short_novel_id': novelID,
        'page': pageHelper.page,
        'page_size': pageHelper.row
      },
      success: (data) {
        if (data['status'] == 200) {
          statusType = MultiStatusType.statusContent;
          final List items = data["data"]['data'] ?? [];
          final pageContent = items
              .map((item) => item['content'] ?? '') // 提取content，处理可能的null
              .join('');
          // 提取所有content并拼接
          if(isRefresh) {
            content = pageContent;
          }
          else {
            content += pageContent;
          }
          pageHelper.addPage();

          final hasMore = items.length < pageHelper.row ? false : true;
          refreshSuccess(isRefresh, hasMore);
          notifyListeners();
          onSuccess?.call();
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

  ///导出小说
  void downloadShortStory() {
    LoadingDialog().show(message: '小说导出中...');
    HttpUtils.post(
      NovelApis.shortStoryDownload,
      {
        'short_novel_id': novelID,
      },
      success: (data) {
        if (data['status'] == 200) {
          FileDownloader.downloadWordFile(
              url: data['data']['url'],
              fileName: '${novelBean!.title}.docx',
              onProgress: (p0) {
                LoadingDialog().show(message: '小说下载中${(p0 * 100).floor()}%...');
              },
              done: (file) {
                ///分享小说
                LoadingDialog().dismiss();
                ShareService.shareFile(file, desc: '分享小说');
              },
              failed: (){
                LoadingDialog().dismiss();
                BotToast.showText(text: '下载失败');
              });
        }
        else {
          LoadingDialog().dismiss();
        }
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        BotToast.showText(text: msg);
      },
    );
  }

  ///分享小说，获取小说网页链接
  void fetchShortStoryWebURL() {
    LoadingDialog().show(message: '小说链接获取中...');
    HttpUtils.get(
      NovelApis.shortStoryShare,
      {
        'short_novel_id': novelID,
        'is_new': 2
      },
      success: (data) {
        if (data['status'] == 200) {
          LoadingDialog().dismiss();
          final url = data['data']['url'];
          shareNovel(url);
        }
        else {
          LoadingDialog().dismiss();
        }
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        BotToast.showText(text: msg);
      },
    );
  }

  ///分页上拉
  final EasyRefreshController refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  void refreshSuccess(bool isRefresh, bool hasMore) {
    if (isRefresh) {
      refreshController.finishRefresh(IndicatorResult.success, false);
      if (hasMore) {
        refreshController.resetFooter();
      }
    } else {
      refreshController.finishLoad(
          hasMore ? IndicatorResult.success : IndicatorResult.noMore, true);
    }
  }

  void refreshFailed(bool isRefresh) {
    if (isRefresh) {
      refreshController.finishRefresh(IndicatorResult.fail, false);
    } else {
      refreshController.finishLoad(IndicatorResult.fail, false);
    }
  }
}