/*
 * @Author: cold-x
 * @Date: 2025-06-17 19:00:50
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-08-21 17:01:21
 * @FilePath: /fastcreationmaster/lib/home/long_novel/controller/novel_outline_controller.dart
 * @Description: 
 */


import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:fast_creation_master/core/controller/base_controller.dart';
import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/core/widget/view/loading_dialog.dart';
import 'package:fast_creation_master/home/long_novel/bean/novel_outline_bean.dart';
import 'package:get/get.dart';

import '../../../core/network/novel_apis.dart';
import '../../../core/widget/view/diolog_view.dart';
import '../../../core/widget/view/muti_status_view.dart';

class NovelOutlineController extends BaseController{

  //小说id
  int novelID;
  NovelOutlineController({
    required this.novelID,
    });


  ///大纲列表数据
  RxList<OutlineBean> itemList = <OutlineBean>[].obs;

  ///当前可以生成的大纲
  Rx<int> currentOutlineIndex = 0.obs;

  ///小说状态
  int novelStatus = 0;

  ///定时器轮循进度
  Timer? _timer;
  bool _isRunning = false;///是否在轮循

  @override
  void onInit() {
    super.onInit();
    fetchOutlineList();
  }

  @override
  void onClose() {
    _stopTimer();
    super.onClose();
  }

  ///开始轮循
  _startTimer() {
    if (_isRunning) return;
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if(_isRunning) {
        ///防止控制器没有被摧毁仍在轮循，用户切换账号时会报错
        final user = Get.find<UserController>();
        if(user.userInfoBean.value?.isFormal == 0) {
          _isRunning = false;
          return;
        }
        fetchOutlineList();
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
    fetchOutlineList();
    _startTimer();
  }

  ///页面消失完成后停止轮循
  void viewDidDisappear() {
    _stopTimer();
  }

  ///更新大纲状态，若失败提示用户重新生成
  void updateOutlineGenerateStatus() {
    if(novelStatus == 6) {
      Get.dialog(NovelDialog(
          confirmText: '重新生成',
          content: '网络错误，需要重新生成，\n生成失败不会消耗字数',
          onConfirm: () {
            createNovelOutline();
          },
        ));
    }
  }

  ///更新可生成细纲的大纲
  void updateChapterAwailable() {
    updateOutlineGenerateStatus();
    ///小说大纲未生成
    if (novelStatus < 7) {
      currentOutlineIndex.value = 0;
    } else {
      try {
        OutlineBean bean = itemList.firstWhere((item) => [3,5,7].contains(item.stage));
        currentOutlineIndex.value = bean.index!;
      } catch (e) {
        currentOutlineIndex.value = 0;
      }
    }
  }

  ///获取大纲列表页
  void fetchOutlineList({
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    if(itemList.isEmpty) {
      statusType.value = MultiStatusType.statusLoading;
    }
    HttpUtils.get(
      NovelApis.outlineList,
      {
        'id': novelID
      },
      success: (data) {
        if (data['status'] == 200) {
          final List items = data["data"]["outline_list"] ?? [];
          novelStatus = data['data']['novel_stage'];
          List<OutlineBean> beans = List<OutlineBean>.from(items.map(
            (ele) => OutlineBean.fromJson(ele),
          ));
          itemList.value = beans;
          updateChapterAwailable();
          _startTimer();
          onSuccess?.call();
          if (itemList.isEmpty) {
            statusType.value = MultiStatusType.statusEmpty;
          } else {
            statusType.value = MultiStatusType.statusContent;
          }
        }
        else {
          if (itemList.isEmpty) {
          statusType.value = MultiStatusType.statusNoNetWork;
        }
        }
      },
      fail: (code, msg) {
        if (itemList.isEmpty) {
          statusType.value = MultiStatusType.statusNoNetWork;
        }
        onFailed?.call(code, msg);
        BotToast.showText(text: msg);
      },
    );
  }

  ///创建大纲
  void createNovelOutline({
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    LoadingDialog().show(message: '大纲创建中...');
    HttpUtils.post(
      NovelApis.createOutline,
      {
        'id': novelID
      },
      success: (data) {
        LoadingDialog().dismiss();
        if (data['status'] == 200) {
          fetchOutlineList();
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