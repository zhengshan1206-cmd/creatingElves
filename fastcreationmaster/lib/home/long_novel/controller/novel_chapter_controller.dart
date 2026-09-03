/*
 * @Author: cold-x
 * @Date: 2025-06-17 19:00:50
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-27 16:04:11
 * @FilePath: /fastcreationmaster/lib/home/long_novel/controller/novel_chapter_controller.dart
 * @Description: 
 */

import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:fast_creation_master/core/controller/base_controller.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/core/widget/view/loading_dialog.dart';
import 'package:fast_creation_master/core/widget/view/muti_status_view.dart';
import 'package:fast_creation_master/home/long_novel/bean/novel_chapter_bean.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../core/network/novel_apis.dart';
import '../../../core/widget/view/diolog_view.dart';
import '../page/novel_chapter_detail_page.dart';
import '../page/novel_detail_page.dart';
import 'package:fast_creation_master/core/widget/view/provider_page_tracker.dart';
import 'chapter_detail_provider.dart';
import 'novel_detail_provider.dart';

class NovelChapterController extends BaseController {
  //小说id
  int novelID;

  ///大纲id
  int outlineID;
  NovelChapterController({
    required this.outlineID,
    required this.novelID,
  });

  ///大纲列表数据
  RxList<ChapterBean> itemList = <ChapterBean>[].obs;

  ///已经提交的章节数
  Rx<int> submittedChapterNum = 0.obs;

  ///细纲是否生成状态
  Rx<int> outlineStatus = 0.obs;

  ScrollController scrollController = ScrollController();

  ///定时器轮循进度
  Timer? _timer;
  bool _isRunning = false;

  ///是否在轮循

  @override
  void onInit() {
    super.onInit();
    fetchChapterList();
  }

  @override
  void onClose() {
    _stopTimer();
    super.onClose();
  }

  ///开始轮循
  _startTimer() {
    if (_isRunning) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isRunning) {
        ///防止控制器没有被摧毁仍在轮循，用户切换账号时会报错
        final user = Get.find<UserController>();
        if (user.userInfoBean.value?.isFormal == 0) {
          _isRunning = false;
          return;
        }
        fetchChapterList(showLoading: false);
      }
    });
    _isRunning = true;
  }

  ///结束轮循
  _stopTimer() {
    _timer?.cancel();
    _isRunning = false;
  }

  ///页面显示完成后开始轮循
  void viewDidAppear() {
    fetchChapterList(showLoading: false);
    print('___________开始轮循');
    _startTimer();
  }

  ///页面消失完成后停止轮循
  void viewDidDisappear() {
    print('___________停止轮循');
    _stopTimer();
  }

  ///是否能生成正文
  bool canSubmitContent() {
    if (itemList.isNotEmpty) {
      final int index = itemList.first.index!;

      ///如果是大纲1，返回能生成
      if (index <= 2) {
        return true;
      }
      if (submittedChapterNum.value + 1 >= index) {
        return true;
      }
    }
    return false;
  }

  ///当前篇章生成的章节数
  int generatedContentNum() {
    if (itemList.isNotEmpty) {
      final int index = itemList.first.index!;
      final int generateNum = submittedChapterNum.value + 1 - index;
      if(generateNum > itemList.last.index!) {
        return itemList.last.index! - index + 1;
      }
      if (generateNum > 36) {
        return 36;
      }
      return generateNum > 0 ? generateNum : 0;
    }
    return 0;
  }

  ///最后一章的序列
  int lastContentIndex() {
    if (itemList.isNotEmpty) {
      return itemList.last.index!;
    }
    return 0;
  }

  ///更新选择一键生成action
  void generateAction(int index) {
    final selectedItems = itemList.where((element) {
      return element.index! > submittedChapterNum.value && element.index! <= index;
    }).toList();
    final selectedIDs = selectedItems.map((e) => e.id).toList();
    generateNovelContent(selectedIDs);
  }

  ///进入小说正文页
  void gotoNovelInfoPage(int chapterID, {bool? jumpToStream = true}) {
    viewDidDisappear();
    final provider = NovelDetailProvider();
    provider.novelID = novelID;
    provider.contentID = chapterID;
    provider.outlineID = outlineID;
    provider.jumpToStreamChapter = jumpToStream!;
    ByNavRouterUtils.push(
      Get.context!,
      trackProviderPage(
        pageId: '/novel_detail_page',
        widget: ChangeNotifierProvider(
          create: (context) => provider,
          child: const NovelDetailPage(),
        ),
      ),
    ).then((_) {
      viewDidAppear();
    });
  }

  ///进入小说细纲详情页
  void gotoChapterInfoPage(ChapterBean bean) {
    viewDidDisappear();
    final provider = ChapterDetailProvider();
    ByNavRouterUtils.push(
      Get.context!,
      trackProviderPage(
        pageId: '/novel_chapter_detail_page',
        widget: ChangeNotifierProvider(
          create: (context) => provider,
          child: NovelChapterDetailPage(
            bean: bean,
          ),
        ),
      ),
    ).then((_) {
      viewDidAppear();
    });
  }

  ///细纲是否生成失败
  void chapterGenerateFailed() {
    if (outlineStatus.value == 7) {
      Get.dialog(NovelDialog(
        confirmText: '重新生成',
        content: '网络错误，需要重新生成，\n生成失败不会消耗字数',
        onConfirm: () {
          createNovelChapter();
        },
      ));
    }
  }

  void _scrollToBottom() {
    // 确保在下一帧滚动到底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 70),
          curve: Curves.easeOut,
        );
      }
    });
  }

  ///获取章节细纲列表页
  void fetchChapterList({
    bool? showLoading = true,
    void Function()? onSuccess,
  }) {
    if (showLoading!) {
      statusType.value = MultiStatusType.statusLoading;
    }
    HttpUtils.get(
      NovelApis.chapterList,
      {'id': novelID, 'outline_id': outlineID},
      success: (data) {
        if (data['status'] == 200) {
          outlineStatus.value = data['data']['outline_stage'];
          submittedChapterNum.value = data['data']['max_sub_index'];
          if (data['data']['list'] is List) {
            final List items = data["data"]['list'] ?? [];
            List<ChapterBean> beans = List<ChapterBean>.from(items.map(
              (ele) => ChapterBean.fromJson(ele),
            ));
            itemList.value = beans;
            chapterGenerateFailed();
            if (outlineStatus.value != 7) {
              _startTimer();
            }

            ///生成中时滑动到最底部
            // if(outlineStatus.value == 5) {
            //   _scrollToBottom();
            // }
            onSuccess?.call();
            if (itemList.isEmpty && showLoading) {
              statusType.value = MultiStatusType.statusEmpty;
            } else {
              statusType.value = MultiStatusType.statusContent;
            }
          } else {
            if (itemList.isEmpty && showLoading) {
              statusType.value = MultiStatusType.statusEmpty;
            }
          }
          print(
              '____QQQQQQ+++$outlineStatus=_____$submittedChapterNum===>${itemList.first.index}');
        } else {
          if (itemList.isEmpty && showLoading) {
            statusType.value = MultiStatusType.statusNoNetWork;
          }
        }
      },
      fail: (code, msg) {
        if (itemList.isEmpty && showLoading) {
          statusType.value = MultiStatusType.statusNoNetWork;
        }
        BotToast.showText(text: msg);
      },
    );
  }

  ///生成正文，一键成文
  void generateNovelContent(
    List contentIDs, {
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    LoadingDialog().show(message: '正文生成中...');
    HttpUtils.post(
      NovelApis.createNovelContent,
      {'id': novelID, 'outline_id': outlineID, 'content_ids': contentIDs},
      success: (data) {
        LoadingDialog().dismiss();
        if (data['status'] == 200) {
          ///进入当前提交的第一个小说详情页
          if (contentIDs.isNotEmpty) {
            fetchChapterList(showLoading: false);
          }
          gotoNovelInfoPage(contentIDs[0]);
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

  ///创建细纲
  void createNovelChapter({
    void Function()? onSuccess,
  }) {
    LoadingDialog().show(message: '细纲创建中...');
    HttpUtils.post(
      NovelApis.createChapter,
      {
        'id': novelID,
        'outline_id': outlineID,
      },
      success: (data) {
        LoadingDialog().dismiss();
        if (data['status'] == 200) {
          onSuccess?.call();
          fetchChapterList();
        } else {
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
