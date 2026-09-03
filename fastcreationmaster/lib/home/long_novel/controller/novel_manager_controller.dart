

import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:fast_creation_master/core/network/file_download.dart';
import 'package:fast_creation_master/core/service/share_service.dart';
import 'package:fast_creation_master/core/widget/view/diolog_view.dart';
import 'package:fast_creation_master/core/widget/view/loading_dialog.dart';
import 'package:fast_creation_master/global/other/illegal_words/controller/illegal_words_controller.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:fast_creation_master/home/long_novel/view/chapter_choose_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/novel_apis.dart';
import '../../../global/other/event_tracking/event_tracking.dart';
import '../../../global/routes/app_pages.dart';
import '../bean/novel_bean.dart';


class NovelManagerItem {
  Rx<bool> downloading = false.obs;///是否可下载
  String title = ''; ///标题
  Rx<bool> isActive = true.obs; ///是否能交互、可点击
  Rx<int> progress  = 0.obs; ///下载进度
}

class NovelManagerController extends GetxController {

  ///小说数据
  NovelBean? bean;

  ///小说标题
  Rx<String> title = ''.obs;

  ///是否有违禁词
  bool hasIllegalWords = false;

  final List<String> titles = ['整本下载', '章节下载', '重命名', '违禁词检测', '删除'];
  List<NovelManagerItem> items = [];
  final int novelID = 0;

  @override
  void onInit() {
    super.onInit();
    for (final title in titles){
      NovelManagerItem item = NovelManagerItem();
      item.title = title;
      items.add(item);
    }
  }

  ///更新小说状态
  void updateNovelStatus() {
    for(int index in [0,1,3,4]){
        NovelManagerItem item = items[index];
        ///是否能删除(暂停中或者已完结的小说能被删除)
        if(index == 4 && (bean!.pauseStatus == 1 || bean!.stage! == 10)) {
          item.isActive.value = true;
          continue;
        }
        else {
          if(bean!.stage! == 10){
            ///违禁词检测
            if(index == 3 && hasIllegalWords) {
              item.isActive.value = true;
              continue;
            }
            if([0,1].contains(index) && !hasIllegalWords) {
              item.isActive.value = true;
              continue;
            }
          }
        }
        item.isActive.value = false;
      }
    // NovelManagerItem item = items[1];
    // if(bean!.generateChapters! > 0) {
    //   item.isActive.value = true;
    // }
    // else {
    //   item.isActive.value = false;
    // }
  }

  ///管理页点击action
  void clickManagerItemIndex(int index) {
    NovelManagerItem item = items[index];
    if (!item.isActive.value){
      if(bean?.stage == 10) {
        if ([0,1].contains(index) && hasIllegalWords){
          BotToast.showText(text: '为了保证您作品过审，完成违禁词检测后才能下载哦');
        }
      }
      else {
        if ([0,1].contains(index)){
          BotToast.showText(text: '整本小说生成完成并且完成违禁词检测后才能下载');
        }
        if(index == 3) {
          BotToast.showText(text: '整本小说生成完成后才能进行检测哦');
        }
      }
      return;
    }
    String reocrdString = '';
    switch (index) {
      ///整本下载
      case 0:
        reocrdString = 'download';
        novelLoading(item);
        break;
      ///章节下载
      case 1:
        reocrdString = 'chapter_download';
        Get.bottomSheet(
          ChapterChooseView(
            charpterNum: bean!.generateChapters!,
            type: ChapterChooseType.download,
            downloadSelected: (chapter) {
            novelLoading(item, indexes: chapter);
          },),
          isScrollControlled: true,
        );
        break;
      ///重命名
      case 2:
        reocrdString = 'rename';
        Get.dialog(CommomDiolog(
          type: CommomDiologTye.textfeild,
          content: bean!.title,
          title: '重命名',
          confirmBgColor: ByColorUtil.colorC1,
          confirmTextColor: Colors.black,
          onConfirm: (text) {
            ///重命名
            novelRename(text);
          },
        ));
        break;
      ///违禁词检测
      case 3:
        reocrdString = 'prohibited_word_detection';
        if(hasIllegalWords) {
          // Get.toNamed(Routes.illegalWords, arguments: {'novelID': bean!.id})?.then((_){
          //   checkNovel(onSuccess: (p0) {
          //     updateNovelStatus();
          //   },);
          // });
          ///修复修改违禁词后不能再点击的问题
          Get.put(IllegalWordsController(novelID: bean!.id!));
          navigator?.pushNamed(
            Routes.illegalWords,
            arguments: {'novelID': bean!.id},
          ).then((_){
            checkNovel(onSuccess: (p0) {
              updateNovelStatus();
            },);
          });
        }
        break;
      // ///分享
      // case 4:
      //   Get.bottomSheet(
      //     const ShareView(),
      //   );
      //   break;
      ///删除
      case 4:
        reocrdString = 'delete';
        Get.dialog(CommomDiolog(
          content: '确定要删除吗',
          title: '删除',
          confirmBgColor: ByColorUtil.colorC1,
          confirmTextColor: Colors.black,
          onConfirm: (text) {
            ///删除小说
            deleteNovel();
          },
        ));

        break;
      default:
        break;
    }

    EventTracking.reportDataPoint(
          pageTag: 'myworks_detail_${reocrdString}_btn',
          operateType: 'click',
          funcDetailImg: '',
          funcDetailTag: novelID.toString(),
        );
  }

  ///小说下载
  void novelLoading(NovelManagerItem item,{List<int>? indexes = const []}) {
    ///正在下载时
    if (item.downloading.value) {
      return;
    }
    item.progress.value = 0;
    item.downloading.value = true;
    item.isActive.value = false;
    
    HttpUtils.post(
      NovelApis.downloadNovel,
      {
        'id': bean!.id,
        'index_ids': indexes
      },
      success: (data) {
        if (data['status'] == 200) {
          FileDownloader.downloadWordFile(
              url: data['data']['url'],
              fileName: '${bean!.title}.docx',
              onProgress: (p0) {
                item.progress.value = (p0 * 100).floor();
              },
              done: (file) {
                item.isActive.value = true;
                item.downloading.value = false;
                ///分享小说
                ShareService.shareFile(file, desc: '分享小说');
              },
              failed: (){
                BotToast.showText(text: '下载失败');
              });
        }
      },
      fail: (code, msg) {
        BotToast.showText(text: msg);
        item.isActive.value = true;
        item.downloading.value = false;
      },
    );
  }

  ///重命名小说
  void novelRename(String titleName) {
    if(titleName.isEmpty) {
      BotToast.showText(text: '标题不能为空');
      return;
    }
    LoadingDialog().show(message: '修改小说名...');
    HttpUtils.post(
      NovelApis.editNovelInfo,
      {
        'id': bean!.id,
        'title': titleName,
      },
      success: (data) {
        LoadingDialog().dismiss();
        if (data['status'] == 200) {
          title.value = titleName;
          bean!.title = titleName;
          BotToast.showText(text: '修改成功');
        }
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        BotToast.showText(text: msg);
      },
    );

  }

  ///删除小说
  void deleteNovel({
    void Function()? onSuccess,
    void Function(int, String)? onFailed,}) {
    LoadingDialog().show(message: '小说删除中...');
    HttpUtils.post(
      NovelApis.deleteNovel,
      {
        'ids': [bean!.id]
      },
      success: (data) {
        LoadingDialog().dismiss();
        if (data['status'] == 200) {
          BotToast.showText(text: '小说已删除');
          Get.back();
          Get.back();
          onSuccess?.call();
        }
      },
      fail: (code, msg) {
        LoadingDialog().dismiss();
        BotToast.showText(text: msg);
      },
    );
  }
  
  ///获取小说违禁词列表
  void checkNovel({
    void Function(dynamic)? onSuccess,
  }) {
    HttpUtils.post(
      NovelApis.checkNovel,
      {
        'id': bean!.id
      },
      success: (data) {
        if(data['status'] == 200) {
          int status = data['data']['check_status'];
          if(status == 4) {
            hasIllegalWords = true;
          }
          else if(status == 3) {
            hasIllegalWords = false;
          }
          // else {
          //   Get.dialog(const NovelDialog(
          //     content: '当前小说的违禁词正在被系统检测中，请稍候再试',
          //     confirmText: '我知道了',
          //   ));
          // }
          onSuccess?.call(data);
        }
      },
    );
  }
}