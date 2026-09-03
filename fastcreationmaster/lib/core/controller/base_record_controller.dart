/*
 * @Author: cold-x
 * @Date: 2025-06-06 16:28:52
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-09-09 14:35:43
 * @FilePath: /fastcreationmaster/lib/core/controller/base_record_controller.dart
 * @Description: 
 */

import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_common/by_common_utils.dart';
import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:fast_creation_master/core/controller/base_controller.dart';
import 'package:fast_creation_master/core/widget/view/muti_status_view.dart';
import 'package:fast_creation_master/core/widget/view/provider_page_tracker.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:fast_creation_master/home/long_novel/bean/novel_bean.dart';
import 'package:fast_creation_master/home/long_novel/bean/novel_notify_bean.dart';
import 'package:fast_creation_master/home/long_novel/controller/short_story_provider.dart';
import 'package:fast_creation_master/home/long_novel/page/short_story_detail_page.dart';
import 'package:fast_creation_master/home/long_novel/request/short_story_request.dart';
import 'package:fast_creation_master/home/tool/bean/tool_bean.dart';
import 'package:fast_creation_master/home/tool/page/tool_finish_page.dart';
import 'package:fast_creation_master/profile/profile_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../home/long_novel/controller/brief_detail_provider.dart';
import '../../home/long_novel/page/novel_brief_page.dart';
import '../../home/tool/controller/tool_finish_provider.dart';
import '../network/novel_apis.dart';
import '../service/refresh_manager.dart';
import '../widget/view/diolog_view.dart';

///创作类型
enum CreationType {
  ///小说名
  novelName('novel_name'),

  ///笔名
  penName('pen_name'),

  ///小说推广文
  novelPromotion('novel_spread'),

  ///抖音标题小助手
  douyinAssistant('title_aide'),

  ///短视频脚本
  shortVideoScript('video_script'),

  ///小红书标题小助手
  xhsAssistant('xhs_aide'),

  ///旧版短故事(民间小说)
  folkNovel('folk_story'),

  ///长文小说
  novel('novel'),

  ///短篇创作
  shortNovel('short_novel'),

  ///新版短故事
  shortStory('short_story');

  const CreationType(this.name);

  final String name;
}

///扩展CreationType，提供标题获取功能
extension CreationTypeExt on CreationType {
  String get title {
    switch (this) {
      case CreationType.novelName:
        return "写小说名";
      case CreationType.penName:
        return "写笔名";
      case CreationType.novelPromotion:
        return "写推广文";
      case CreationType.douyinAssistant:
        return "抖音标题小助手";
      case CreationType.shortVideoScript:
        return "短视频脚本";
      case CreationType.xhsAssistant:
        return "小红书标题小助手";
      case CreationType.folkNovel:
      case CreationType.shortStory:
        return "短故事";
      case CreationType.novel:
        return "长文小说";
      case CreationType.shortNovel:
        return "短篇小说";
      default:
        return "";
    }
  }
}

// 扩展String类转换为 CreationType
extension StringToColor on String {
  CreationType? toCreationType() {
    return CreationType.values.firstWhere((e) => e.name == this,
        orElse: () => CreationType.folkNovel);
  }
}

class BaseRecordController extends BaseController {
  ///创建类型
  final CreationType type;
  BaseRecordController({required this.type});

  ///是否处于管理状态
  Rx<bool> isManaging = false.obs;

  ///管理是否全选
  Rx<bool> allSelected = false.obs;

  ///记录列表
  RxList<dynamic> recordList = <dynamic>[].obs;

  ///删除记录表ids
  ///用于删除记录时传递的ids
  RxList<int> deleteRecordIds = <int>[].obs;

  ///通知数据列表
  RxList<NovelNotifyItem> notifyList = <NovelNotifyItem>[].obs;

  ///分类
  List<String> pageTitles = ['全部', '未完成', '已完成', '已断更'];
  PageController pageController = PageController();
  RxInt pageIndex = 0.obs;
  List<RefreshManager> refreshManagers = [];
  bool pageAnimating = false;

  @override
  void onInit() {
    super.onInit();
    getNotifyContent();

    for (int i = 0; i < pageTitles.length; i++) {
      refreshManagers.add(RefreshManager());
    }

    if (![CreationType.novel, CreationType.shortNovel].contains(type)) {
      fetchRecordList(true); // 初始化时获取记录列表
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  // 监听页面变化
  void onPageChanged(int value) {
    if (pageIndex.value != value && !pageAnimating) {
      pageIndex.value = value;
    }
  }

  ///点击列表事件
  void clickCellEvent(dynamic record) {
    if (isManaging.value) {
      // 如果处于管理状态，更新删除记录ID
      updateDeleteRecordIds(record.id!);
    } else {
      ///小说名笔名不做操作
      if ([CreationType.novelName, CreationType.penName].contains(type)) {
        return;
      }

      ///短故事小说
      if (type == CreationType.shortStory) {
        ///进入灵感生成页
        if (record.stage! <= 4) {
          ///灵感生成失败
          if (record.stage == 3) {
            Get.dialog(NovelDialog(
              confirmText: '重新生成',
              content: '网络错误，灵感需要重新生成，\n生成失败不会消耗字数',
              onConfirm: () {
                ShortStoryRequest.retryBrief(
                  record.id,
                  onSuccess: () {
                    gotoShortStoryPage(0, record);
                  },
                );
              },
            ));
          } else {
            gotoShortStoryPage(0, record);
          }
        } else {
          ///正文生成失败
          if (record.stage == 6) {
            Get.dialog(NovelDialog(
              confirmText: '重新生成',
              showCancelBtn: false,
              content: '网络错误，正文需要重新生成，\n生成失败不会消耗字数',
              onConfirm: () {
                ShortStoryRequest.createShortStoryContent(
                  record.id,
                  onSuccess: (data) {
                    gotoShortStoryPage(1, record);
                  },
                );
              },
            ));
          } else {
            gotoShortStoryPage(1, record);
          }
        }
        return;
      }
      // 如果不处于管理状态，执行默认操作
      final provider = ToolFinishProvider();
      provider.creationID = record.id;
      provider.type = type;
      provider.isStreaming = record.status == 2 ? true : false;
      ByNavRouterUtils.push(
        Get.context!,
        trackProviderPage(
          pageId: '/tool_finish_page',
          widget: ChangeNotifierProvider(
            create: (context) => provider,
            child: const ToolFinishPage(),
          ),
        ),
      );
    }
  }

  ///短故事跳转
  ///[status] 跳转状态 0 跳转至灵感页 1 跳转至正文页
  void gotoShortStoryPage(int status, dynamic record) {
    if (status == 0) {
      final provider = BriefDetailProvider();
      provider.type = CreationType.shortStory;
      ByNavRouterUtils.push(
        Get.context!,
        trackProviderPage(
          pageId: '/novel_brief_page',
          widget: ChangeNotifierProvider(
            create: (context) => provider,
            child: NovelBriefPage(
              novelID: record.id,
            ),
          ),
        ),
      ).then((_) {
        updateNovel(record.id);
      });
    } else if (status == 1) {
      final provider = ShortStoryProvider();
      provider.novelID = record.id;
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
        updateNovel(record.id);
      });
    }
  }

  ///用户操作完短故事小说后更新该小说的状态
  void updateNovel(
    int novelID,
  ) {
    HttpUtils.get(
      NovelApis.shortStoryInfo,
      {'short_novel_id': novelID},
      success: (data) {
        if (data['status'] == 200) {
          NovelBean novelBean = NovelBean.fromJson(data['data']);
          try {
            int index =
                recordList.indexWhere((element) => element.id == novelID);
            if (index != -1) {
              recordList[index] = novelBean; // 更新列表中的对应项
            }
          } catch (e) {
            throw Exception('更新小说状态失败: $e');
          }
        }
      },
    );
  }

  ///获取底部按钮显示文字
  String updateManagingText() {
    if (isManaging.value) {
      return allSelected.value ? "取消全选" : "全选";
    } else {
      return "管理";
    }
  }

  ///取消管理
  void cancelManaging() {
    isManaging.value = false;
    allSelected.value = false; // 取消全选状态
    deleteRecordIds.clear(); // 清空删除记录ID列表
  }

  ///更新记录管理状态
  void updateManagingStatus() {
    ///如果当前不是管理状态，点击后进入管理状态
    if (!isManaging.value) {
      isManaging.value = true;
      return;
    }
    // 如果当前是管理状态，点击后点击全选删除
    allSelected.value = !allSelected.value;
    // 取消全选状态，清空删除记录ID列表
    deleteRecordIds.clear();
    if (allSelected.value) {
      // 全选状态下，添加所有记录的ID到删除列表
      for (var record in recordList) {
        deleteRecordIds.add(record.id!);
      }
    }
  }

  ///更新当前选择的删除记录
  void updateDeleteRecordIds(int id) {
    if (deleteRecordIds.contains(id)) {
      deleteRecordIds.remove(id);
      allSelected.value = false; // 取消全选状态
    } else {
      deleteRecordIds.add(id);
      if (deleteRecordIds.length == recordList.length) {
        allSelected.value = true; // 如果删除记录数量等于总记录数量，则全选
      }
    }
  }

  ///删除记录action
  void deleteRecordAction({
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    if (deleteRecordIds.isEmpty) {
      BotToast.showText(text: "请选择要删除的记录");
      return;
    }
    Get.dialog(CommomDiolog(
      title: '确认删除',
      confirmBgColor: ByColorUtil.colorG4,
      onConfirm: (String text) {
        deleteRecord();
      },
    ));
  }

  ///批量删除记录请求
  void deleteRecord({
    void Function()? onSuccess,
    void Function(int, String)? onFailed,
  }) {
    HttpUtils.post(
      type == CreationType.shortStory
          ? NovelApis.shortStoryDelete
          : NovelApis.deleteRecord,
      type == CreationType.shortStory
          ? {'short_novel_ids': deleteRecordIds}
          : {
              'ids': deleteRecordIds,
            },
      success: (data) {
        if (data['status'] == 200) {
          // 删除成功后，更新记录列表
          recordList
              .removeWhere((record) => deleteRecordIds.contains(record.id));
          BotToast.showText(text: "删除成功");
          cancelManaging();
          if (recordList.isEmpty) {
            statusType.value = MultiStatusType.statusEmpty;
          }
          // 关闭所有打开的 Slidable
          Slidable.of(Get.context!)?.close();
          onSuccess?.call();
          Get.find<ProfileController>().updateUserInfo();
        }
      },
      fail: (code, msg) {
        onFailed?.call(code, msg);
        BotToast.showText(text: msg);
      },
    );
  }

  ///获取记录列表
  void fetchRecordList(bool isRefresh) {
    if (isRefresh) {
      if (recordList.isEmpty) {
        statusType.value = MultiStatusType.statusLoading;
      }
      pageHelper.resetPage(); // 如果是刷新操作，清空当前列表
    }
    HttpUtils.get(
      type == CreationType.shortStory
          ? NovelApis.shortStoryList
          : NovelApis.creationRecord,
      type == CreationType.shortStory
          ? {
              'page_size': pageHelper.row, // 每页数量
              'page': pageHelper.page, // 页数
            }
          : {
              'is_needle_content': '1',
              'func': type.name,
              'page_size': pageHelper.row, // 每页数量
              'page': pageHelper.page, // 页数
            },
      success: (data) {
        if (data['status'] == 200) {
          final List items = data["data"]["data"] ?? [];

          List<dynamic> beans;
          if (type == CreationType.shortStory) {
            beans = List<NovelBean>.from(items.map(
              (ele) => NovelBean.fromJson(ele),
            ));
          } else {
            beans = List<ToolBean>.from(items.map(
              (ele) => ToolBean.fromJson(ele),
            ));
          }
          if (isRefresh) {
            recordList.value = beans; // 刷新时清空列表
          } else {
            recordList.addAll(beans); // 加载更多时追加数据
          }

          if (recordList.isEmpty) {
            statusType.value = MultiStatusType.statusEmpty;
          } else {
            statusType.value = MultiStatusType.statusContent;
          }
          pageHelper.addPage();

          final hasMore = beans.length < pageHelper.row ? false : true;
          refreshSuccess(isRefresh, hasMore);
        } else {
          if (recordList.isEmpty) {
            statusType.value = MultiStatusType.statusNoNetWork;
          }
        }
      },
      fail: (code, msg) {
        if (recordList.isEmpty) {
          statusType.value = MultiStatusType.statusNoNetWork;
        }
        refreshFailed(isRefresh);
        BotToast.showText(text: msg);
      },
    );
  }

  ///获取通知文案
  void getNotifyContent() {
    HttpUtils.get(NovelApis.getNoticeList, {}, success: (data) {
      byDebugPrint(data, tag: "peizhi11111111111111---");
      try {
        // 使用模型解析响应数据
        NovelNotifyResponse response = NovelNotifyResponse.fromJson(data);
        // 直接获取列表数据
        notifyList.value = response.data ?? [];
      } catch (e) {}
    }, fail: (code, msg) {
      byDebugPrint(msg, tag: "peizhi11111111111111---");
      notifyList.clear();
    });
  }

  ///检查是否有通知数据
  bool get hasNotifyData {
    return notifyList.isNotEmpty;
  }

  ///获取第一个通知项的完整文本
  String? get firstNotifyText {
    if (hasNotifyData) {
      return notifyList.first.complete;
    }
    return null;
  }
}

class ByDebugPrint {}
