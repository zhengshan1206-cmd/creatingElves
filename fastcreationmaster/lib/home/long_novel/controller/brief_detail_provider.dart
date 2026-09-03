/*
 * @Author: cold-x
 * @Date: 2025-06-26 16:24:05
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-27 12:00:27
 * @FilePath: /fastcreationmaster/lib/home/long_novel/controller/brief_detail_provider.dart
 * @Description: 
 */



import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:fast_creation_master/core/controller/base_record_controller.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/core/service/app_review_service.dart';
import 'package:fast_creation_master/core/widget/view/loading_dialog.dart';
import 'package:fast_creation_master/home/long_novel/controller/novel_home_controller.dart';
import 'package:fast_creation_master/home/long_novel/controller/stream_controller.dart';
import 'package:fast_creation_master/home/long_novel/request/short_story_request.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../core/widget/view/provider_page_tracker.dart';
import '../../../global/launch/controller/launch_controller.dart';
import '../../../global/other/event_tracking/event_tracking.dart';
import '../../../profile/member/dialog/intercept.dart';
import '../../../core/network/novel_apis.dart';
import '../../../core/service/data_service.dart';
import '../../../core/service/local_streaming.dart';
import '../../../core/widget/view/diolog_view.dart';
import '../../../core/widget/view/muti_status_view.dart';
import '../../../global/routes/app_pages.dart';
import '../bean/novel_bean.dart';
import '../page/short_story_detail_page.dart';
import 'short_story_provider.dart';

class BriefDetailProvider extends StreamingProvider {
   ///小说详情内容
  NovelBean? novelBean;
  ///小说id
  late final int? novelID; 

  ///进入来源
  NovelHomeSourceType? source;

  ///灵感页类型
  CreationType type = CreationType.novel;

  ///是否回首页
  bool isBackToMain = false;

  ///页面标题
  String pageTitle = '小说灵感';

  ///是否显示下方生成按钮
  bool showBottom = true;

  ///引导页小说的灵感内容
  String guideBriefContent = '';
  ///引导页小说的灵感内容
  String guideBriefTitle = '';

  LocalStreamManager? localStreamManager;


  @override
  void dispose() {
    localStreamManager?.dispose();
    super.dispose();
  }

  ///引导页假流式输出
  void guideStreamOutput() {
    localStreamManager = LocalStreamManager(
      intervalMs: 100,
      charsPerStep: 12,
    );
    
    localStreamManager?.setTargetString(guideBriefContent);
    maxWords = guideBriefContent.length;
    localStreamManager?.output = (String substring, bool isGen) {
      isGenerating = isGen;
      content += substring;
      if(isGenerating) {
        pageTitle = '创意酝酿中...';
      }
      else {
        pageTitle = '爆款创意完成';
      }
      updateProgress();
      scrollToBottom();
    };
    localStreamManager?.start();
  }

  ///引导页弹出付费引导动画效果
  void popPayGuideDialog() {
    if (isBackToMain) {
      return;
    }
    final UserController userController = Get.find<UserController>();
    Get.dialog(
      useSafeArea: false,
      InterceptView(
      type: InterceptType.guideBriefIntercept,
      close: () {
        EventTracking.reportDataPoint(
                  pageTag: 'accept_writing_basics_close_btn',
                  operateType: 'click',
                  funcDetailImg: '',
                  funcDetailTag: '',
                  extra: {'source': 2});
      },
      action: () {
        Get.back();
        EventTracking.reportDataPoint(
                  pageTag: 'accept_writing_basics_ai_btn',
                  operateType: 'click',
                  funcDetailImg: '',
                  funcDetailTag: '',
                  extra: {'source': 2});
        userController.checkPreLogin(
          source: 'guide_novel_brief',
          actionCallback: () {

          },
        );
      },
    ));
  }

  ///延迟加载
  void delayToLoad() {
    if(needRecirleData) {
      Future.delayed(const Duration(seconds: 3),() {
        ///防止控制器没有被摧毁仍在轮循，用户切换账号时会报错
        final user = Get.find<UserController>();
        if(user.userInfoBean.value?.isFormal == 0) {
          needRecirleData = false;
          return;
        }
        fetchNovelDetail(novelID!);
      });
    }
    
  }

  ///灵感是否生成失败
  void briefGenerateFailed() {
    if (novelBean!.stage! == 3) {
      Get.dialog(NovelDialog(
        confirmText: '重新生成',
        content: '网络错误，灵感需要重新生成，\n生成失败不会消耗字数',
        onConfirm: () {
          retryBrief(novelBean!.id!);
        },
      ));
    }
  }

  ///进入小说正文页
  void gotoNovelInfoPage(String url, String taskID) {
    final provider = ShortStoryProvider();
    provider.novelID = novelID;
    provider.streamURL = url;
    provider.streamTaskID = taskID;
    ByNavRouterUtils.push(
      Get.context!,
      trackProviderPage(
        pageId: '/short_story_detail_page',
        widget: ChangeNotifierProvider(
          create: (context) => provider,
          child: const ShortStoryDetailPage(),
        ),
      ),
    ).then((_) {
      // updateNovel(clickID);
    });
  }
  
  ///获取小说详情
  void fetchNovelDetail(
    int id, {
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    statusType = MultiStatusType.statusLoading;
    HttpUtils.get(
      type == CreationType.shortStory ? NovelApis.shortStoryInfo : NovelApis.novelInfo,
      type == CreationType.shortStory ? {
        'short_novel_id' : id
      } : {
        'id': id,
      },
      success: (data) {
        if (data['status'] == 200) {
          novelBean = NovelBean.fromJson(data['data']);
          statusType = MultiStatusType.statusContent;
          onSuccess?.call();
          ///生成完成时
          if(novelBean!.stage! > 2){
            briefGenerateFailed();
            content = data['data']['details']['inspiration'];
            updateStreamingContent(content);
          }
          ///生成中时流式输出
          else if(novelBean?.stage == 2 && novelBean!.streamTaskID!.isNotEmpty){
            wsConnect(
              novelBean!.streamTaskID!, 
              novelBean!.streamURL!,
              delayToFinish: true,
              successStream: () {
                ///灵感完成时弹出app评分
                if(source != NovelHomeSourceType.guide) {
                  AppReviewService.requestReview();
                } 
              },);
          }
          ///状态未改变时循环拉取数据
          else if (novelBean?.stage == 1) {
            delayToLoad();
            return;
          }
          needRecirleData = false;
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

  ///生成短故事
  void createShortStory() {
    ShortStoryRequest.createShortStoryContent(
      novelID!,
      onSuccess: (data) {
        fetchNovelDetail(novelID!);

        ///流式输出地址
        final streamURL = data['data']['content_ws_url'];
        ///流式输出任务id
        final streamTaskID = data['data']['content_task_id'];
        gotoNovelInfoPage(streamURL, streamTaskID);
      },
    );
  }

  ///创建大纲
  void createNovelOutline({
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    LoadingDialog().show(message: '大纲创建中');
    HttpUtils.post(
      NovelApis.createOutline,
      {
        'id': novelID
      },
      success: (data) {
        LoadingDialog().dismiss();
        if (data['status'] == 200) {
          fetchNovelDetail(novelID!);
          Get.toNamed(Routes.novelCreateOutline, arguments: {'novelID': novelID});
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

  ///重新生成灵感
  void retryBrief(int novelID,{
    void Function()? success,
  }) {

    LoadingDialog().show(message: '灵感生成中');
    HttpUtils.post(
      NovelApis.retryBrief,
      {
        'id': novelID
      },
      success: (data) {
        LoadingDialog().dismiss();
        if (data['status'] == 200) {
          delayToLoad();
          success?.call();
        } else {
          BotToast.showText(text: '灵感生成失败');
        }
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        if (code == 1003 && source != NovelHomeSourceType.guide) {
          ///如果是字数不够
          Get.back();
          Get.find<UserController>().jumpToPayPage(source: 'novel_brief_retry',);
        }
        BotToast.showText(text: msg);
      },
    );
  }
  
  ///灵感本地流式输出
  ///用于引导页
  void fetchRandomBrief() {
    guideStreamOutput();

    ///生成中时流式输出
    if (Get.find<UserController>().isAudit()) {
      EventTracking.reportDataPoint(
                  pageTag: 'accept_writing_basics_dialog',
                  operateType: 'view',
                  funcDetailImg: '',
                  funcDetailTag: '',
                  extra: {'source': 2});
      Future.delayed(const Duration(seconds: 5), () {
        popPayGuideDialog();
      });
    }
  }
}