import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_common/by_nav_router_utils.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:fast_creation_master/core/controller/base_record_controller.dart';
import 'package:fast_creation_master/core/service/refresh_manager.dart';
import 'package:fast_creation_master/core/widget/view/loading_dialog.dart';
import 'package:fast_creation_master/home/long_novel/bean/novel_bean.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../core/network/novel_apis.dart';
import '../../../core/widget/view/muti_status_view.dart';
import '../../../global/other/event_tracking/event_tracking.dart';
import '../../../global/routes/app_pages.dart';
import '../../../profile/profile_controller.dart';
import '../page/novel_brief_page.dart';
import 'brief_detail_provider.dart';
import 'package:fast_creation_master/core/widget/view/provider_page_tracker.dart';

class NovelRecordController extends BaseRecordController {
  NovelRecordController({required super.type});
  RxList<NovelBean> novelList = <NovelBean>[].obs;

  @override
  void onReady() {
    super.onReady();
    // 确保通知数据已获取
    if (notifyList.isEmpty) {
      getNotifyContent();
    }
    final recordString = type == CreationType.novel ? 'long_novel' : type == CreationType.shortNovel ? 'short_sales' : 'short_story';
    EventTracking.reportDataPoint(
      pageTag: 'myworks_list_${recordString}_works',
      operateType: 'view',
      funcDetailTag: '',
      funcDetailImg: '',
    );
    fetchNovelRecordList(true, refreshManagers[0]);
  }

  @override

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
      for (var record in novelList) {
        ///暂停或者已完结的小说才能被删除
        if (record.pauseStatus == 1 || record.stage == 10) {
          deleteRecordIds.add(record.id!);
        }
      }
    }
  }

  @override

  ///更新当前选择的删除记录
  void updateDeleteRecordIds(int id) {
    if (deleteRecordIds.contains(id)) {
      deleteRecordIds.remove(id);
      allSelected.value = false; // 取消全选状态
    } else {
      deleteRecordIds.add(id);
      if (deleteRecordIds.length == novelList.length) {
        allSelected.value = true; // 如果删除记录数量等于总记录数量，则全选
      }
    }
  }

  @override

  ///删除小说
  void deleteRecord(
      {void Function()? onSuccess,
      void Function(int p1, String p2)? onFailed}) {
    LoadingDialog().show(message: '小说删除中...');
    HttpUtils.post(
      NovelApis.deleteNovel,
      {'ids': deleteRecordIds},
      success: (data) {
        LoadingDialog().dismiss();
        if (data['status'] == 200) {
          // 删除成功后，更新记录列表
          novelList
              .removeWhere((record) => deleteRecordIds.contains(record.id));
          BotToast.showText(text: "删除成功");
          cancelManaging();
          onSuccess?.call();
          if (novelList.isEmpty) {
            statusType.value = MultiStatusType.statusEmpty;
          }
          onSuccess?.call();
          Get.find<ProfileController>().updateUserInfo();
        }
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        BotToast.showText(text: msg);
      },
    );
  }

  ///根据状态值获取记录左上角标签显示
  String setStatusTag(NovelBean bean) {
    if (bean.pauseStatus != 2 && bean.stage! != 10) {
      return '已断更';
    }
    if (bean.contentStage == 4) {
      return '正文生成失败';
    }
    if (bean.chapterStage == 4) {
      return '细纲生成失败';
    }
    switch (bean.stage) {
      case 3:
        return '灵感生成失败';
      case 6:
        return '大纲生成失败';
      case 9:
        return '已断更';
      default:
        return '已完成';
    }
  }

  ///跳转页面
  void gotoPage(
    NovelBean bean, {
    bool? goNovelHome = false,
    int? stage,
  }) {
    Get.log("===当前小说类型=== $type");
    String module = "";
    if (type == CreationType.shortStory) {
      module = "2";
    } else if (type == CreationType.shortNovel) {
      module = "3";
    } else{
      module = "1";
    }

    ///当前想要操作的小说ID
    int clickID = bean.id!;
    if (goNovelHome == true) {
      Get.toNamed(Routes.novelHome, arguments: {
        'id': clickID,
        "module": module,
        "stage": stage,
      })!
          .then((_) {
        updateNovel(clickID);
      });
      return;
    }

    ///进入灵感生成页
    if (bean.stage! <= 4) {
      final provider = BriefDetailProvider();
      ByNavRouterUtils.push(
        Get.context!,
        trackProviderPage(
          pageId: '/novel_brief_page',
          widget: ChangeNotifierProvider(
            create: (context) => provider,
            child: NovelBriefPage(
              novelID: clickID,
            ),
          ),
        ),
      ).then((_) {
        updateNovel(clickID);
      });
    }

    ///大纲页
    else if (bean.stage! <= 8) {
      Get.toNamed(Routes.novelCreateOutline, arguments: {'novelID': clickID})!
          .then((_) {
        updateNovel(clickID);
      });
    }
  }

  ///用户操作完小说后更新该小说的状态
  void updateNovel(int novelID) {
    HttpUtils.get(
      NovelApis.novelInfo,
      {'id': novelID},
      success: (data) {
        if (data['status'] == 200) {
          NovelBean novelBean = NovelBean.fromJson(data['data']);
          try {
            int index =
                novelList.indexWhere((element) => element.id == novelID);
            if (index != -1) {
              novelList[index] = novelBean; // 更新列表中的对应项
            }
          } catch (e) {
            throw Exception('更新小说状态失败: $e');
          }
        }
      },
    );
  }

  ///获取记录列表
  void fetchNovelRecordList(bool isRefresh, RefreshManager refreshManager) {
    if (isRefresh) {
      if (novelList.isEmpty) {
        statusType.value = MultiStatusType.statusLoading;
      }
      refreshManager.pageHelper.resetPage(); // 如果是刷新操作，清空当前列表
    }
    HttpUtils.get(
      NovelApis.novelRecord,
      {
        'page_size': refreshManager.pageHelper.row, // 每页数量
        'page': refreshManager.pageHelper.page, // 页数
        'type': type == CreationType.novel ? 1 : 2
      },
      success: (data) {
        if (data['status'] == 200) {
          final List items = data["data"]["data"] ?? [];
          List<NovelBean> beans = List<NovelBean>.from(items.map(
            (ele) => NovelBean.fromJson(ele),
          ));
          if (isRefresh) {
            novelList.value = beans; // 刷新时清空列表
          } else {
            novelList.addAll(beans); // 加载更多时追加数据
          }

          if (novelList.isEmpty) {
            statusType.value = MultiStatusType.statusEmpty;
          } else {
            statusType.value = MultiStatusType.statusContent;
          }
          refreshManager.pageHelper.addPage();

          final hasMore =
              beans.length < refreshManager.pageHelper.row ? false : true;
          refreshManager.refreshSuccess(isRefresh, hasMore);
        } else {
          if (novelList.isEmpty) {
            statusType.value = MultiStatusType.statusNoNetWork;
          }
        }
      },
      fail: (code, msg) {
        if (novelList.isEmpty) {
          statusType.value = MultiStatusType.statusNoNetWork;
        }
        refreshManager.refreshFailed(isRefresh);
        BotToast.showText(text: msg);
      },
    );
  }
}
