/*
 * @Author: cold-x
 * @Date: 2025-05-14 17:05:39
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-08-06 15:21:07
 * @FilePath: /fastcreationmaster/lib/profile/AboutUs/controllers/about_us_controller.dart
 * @Description: 
 */

import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:fast_creation_master/core/cache/daily_cache_manager.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import '../../../core/network/file_download.dart';
import '../../../core/network/novel_apis.dart';
import '../../../core/util/by_package_utils.dart';
import '../../../global/const/const.dart';
import '../beans/version_update_bean.dart';
import '../pages/version_update_page.dart';
// import 'package:path_provider/path_provider.dart';

class AboutUsController extends GetxController {


  List<String> aboutUsList = [
    "版本更新",
    "隐私政策",
    "用户协议",
    "会员服务协议",
  ];

  // Rx<VersionUpdateBean>? bean;
  var bean = Rx<VersionUpdateBean?>(null);

  ///当前App版本号
  Rx<String> version = ''.obs;
  ///apk下载进度
  Rx<int> progress = 0.obs;
  ///apk下载安装状态 0、默认状态  1、下载中  2、安装中
  Rx<int> isLoadingApk = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getVersion();
  }


  ///是否需要弹窗
  Future<bool> checkUpgrade() async{
    if(bean.value != null){
      ///强制更新
      if(bean.value?.type == 3) {
        return true;
      }
      ///强提示更新
      else if(bean.value?.type == 2) {
        ///获取更新频次
        DailyManagerType type = bean.value!.frequency.toDailyManagerType();
        bool showDialog = await DailyManager.shouldShowPopup(Consts.kAppVersionDialog, type: type);
        if(showDialog) {
          DailyManager.recordPopupDate(Consts.kAppVersionDialog, type: type);
          return true;
        }
      }
    }
    return false;
  }

  ///获取当前版本号信息
  void getVersion() async {
    version.value = await ByPackageUtils.version();
  }

  //跳转到对应的页面
  void jumpToPage(int index) {
    switch (index) {
      case 0:
        showUpdateDialog();
        break;
      case 1:
        Get.toNamed('/privacy');
        break;
      case 2:
        Get.toNamed('/userAgreement');
        break;
      case 3:
        Get.toNamed('/vipAgreement');
        break;
    }
  }

  void fetchVersionInfo({
    void Function()? onSuccess
  }) {
    HttpUtils.get(
      NovelApis.appUpgrade,
      {},
      success: (data) {
        if(data['status'] == 200) {
          if(data['data']!.isNotEmpty) {
            bean.value = VersionUpdateBean.fromJson(data['data']);
          }
          onSuccess?.call();
        }
      });
  }

  // 显示版本更新对话框
  showUpdateDialog() async {
    if (bean.value != null) {
      // 版本更新
      Get.dialog(
        VersionUpdatePage(),
        barrierDismissible: false
      );
      return;
    }
    BotToast.showText(text: '当前版本已是最新版本');
  }

  void downLoadApp(String url, {void Function()? onSuccess}) async{
    isLoadingApk.value = 1;
    FileDownloader.downloadWordFile(
        url: url,
        fileName: 'xsczjl.apk',
        onProgress: (p0) {
          progress.value = (p0 * 100).floor();
          print('_____下载中___${progress.value}');
        },
        done: (file) {
          isLoadingApk.value = 2;
          _installApk(file, onSuccess: onSuccess);
        },
        failed: () {
          isLoadingApk.value = 0;
          BotToast.showText(text: '下载失败');
        });
  }

  Future<void> _installApk(String filePath, {void Function()? onSuccess}) async {
    // 检查文件是否存在
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('APK文件不存在');
    }
    // 打开文件以触发安装
    final result = await OpenFilex.open(filePath);
    if (result.type != ResultType.done) {
      throw Exception('无法打开安装文件: ${result.message}');
    }
    onSuccess?.call();
    isLoadingApk.value = 0;
  }
}