/*
 * @Author: cold-x
 * @Date: 2025-06-12 15:57:53
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-09-02 11:25:59
 * @FilePath: /fastcreationmaster/lib/home/tool/controller/name_finish_controller.dart
 * @Description: 
 */

import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:fast_creation_master/core/controller/base_controller.dart';
import 'package:fast_creation_master/core/widget/view/loading_dialog.dart';
import 'package:fast_creation_master/core/widget/view/muti_status_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controller/base_record_controller.dart';
import '../../../core/network/novel_apis.dart';
import '../../../core/service/app_review_service.dart';
import '../bean/tool_bean.dart';

class NameFinishController extends BaseController {
  ///创建时IDs
  final List<dynamic> creationIDs;

  ///创建类型
  final CreationType type;

  ///创建参数
  final Map<String, dynamic> params;

  ///创建参数显示标题
  final Map<String, String> itemTitles;

  NameFinishController(
      {required this.creationIDs,
      required this.type,
      required this.params,
      required this.itemTitles});

  ///滚动控制器
  ScrollController scrollController = ScrollController();

  ///创建生成的内容数据
  RxList<ToolBean> itemList = <ToolBean>[].obs;

  ///当前生成的ids
  late List<dynamic> currentIDs;

  ///延迟加载时间
  int second = 1;

  // @override
  // Rx<MultiStatusType> get statusType => MultiStatusType.statusLoading.obs;

  ///是否正在生成
  RxBool isGenerating = false.obs;

  @override
  void onInit() {
    super.onInit();
    currentIDs = creationIDs;
    statusType.value = MultiStatusType.statusLoading;
    delayLoad();
  }

  ///延迟加载名称
  void delayLoad() {
    Future.delayed(Duration(seconds: second), fetchNames);
  }

  ///获取小说名笔名
  void fetchNames() {
    if (itemList.isEmpty) {
      statusType.value = MultiStatusType.statusLoading;
    }
    HttpUtils.post(
      NovelApis.mutiNames,
      {"ids": currentIDs, "is_needle_content": "1"},
      success: (data) {
        if (data['status'] == 200) {
          final List items = data["data"] ?? [];
          List<ToolBean> beans = List<ToolBean>.from(items.map(
            (ele) => ToolBean.fromJson(ele),
          ));
          // 检查是否有content为空的项
          bool hasEmptyContent = beans.any((item) => item.content == "");
          if (hasEmptyContent) {
            isGenerating.value = true;
            Future.delayed(Duration(seconds: second), fetchNames);
            // return;
          } else {
            isGenerating.value = false;
          }

          if (itemList.isEmpty) {
            itemList.value = beans;
          } else {
            // 处理新数据
            for (var newBean in beans) {
              // 查找是否存在相同id的项
              int existingIndex = itemList
                  .indexWhere((existingBean) => existingBean.id == newBean.id);

              if (existingIndex == -1) {
                // 如果不存在，添加到列表开头
                // itemList.add(newBean);
                itemList.insert(0, newBean);
              } else if (newBean.content?.isNotEmpty == true) {
                // 如果存在且新数据的content不为空，替换旧数据
                itemList[existingIndex] = newBean;
              }
            }
          }
          if (itemList.isEmpty) {
            statusType.value = MultiStatusType.statusEmpty;
          } else {
            statusType.value = MultiStatusType.statusContent;
          }

          AppReviewService.requestReview();
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        if (itemList.isEmpty) {
          statusType.value = MultiStatusType.statusNoNetWork;
        }
      },
    );
  }

  ///重新生成笔名小说名
  void createNames() {
    if (isGenerating.value) {
      BotToast.showText(text: 'AI正在创作中,请稍后！');
      return;
    }
    LoadingDialog().show(message: '重新生成中...');
    HttpUtils.post(
      NovelApis.createNovel,
      params,
      success: (data) {
        LoadingDialog().dismiss();
        print('_____________+++$data');
        if (data['status'] == 200) {
          currentIDs = data['data']['ids'];
          delayLoad();
        }
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        BotToast.showText(text: msg);
      },
    );
  }
}
