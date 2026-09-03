/*
 * @Author: cold-x
 * @Date: 2025-07-23 14:17:22
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-09-01 17:52:37
 * @FilePath: /fastcreationmaster/lib/global/launch/controller/guide_controller.dart
 * @Description: 
 */
import 'package:bot_toast/bot_toast.dart';
import 'package:byhy_app_common_utils/app_common/aes/byhy_aes_storage_utils.dart';
import 'package:byhy_app_common_utils/app_common/by_common_utils.dart';
import 'package:byhy_app_common_utils/app_http/http_utils.dart';
import 'package:fast_creation_master/core/network/novel_apis.dart';
import 'package:fast_creation_master/global/const/const.dart';
import 'package:fast_creation_master/global/launch/controller/launch_controller.dart';
import 'package:get/get.dart';

import '../../../core/service/data_service.dart';
import '../../login/controller/onekey_manager.dart';

class GuideController extends GetxController {
  final RxInt giveWords = 0.obs;

  @override
  void onInit() {
    ByStorageUtils.saveBool(Consts.kLaunchGuideCheck, true);
    ByStorageUtils.saveInt(Consts.kUserEnteredGuide, 2);
    // getGiveWords();
    DataService.onEvent('guide', {'action': 'guide', 'launch': Get.find<LaunchController>().isLaunched});
    super.onInit();
  }

  @override
  void onReady() {
    initGetPhone();
    super.onReady();
  }

  ///一键登录取号
  void initGetPhone() {
    ///一键登录，闪验初始化
    OneKeyManager.init(checkLogin: false);
  }

  ///赠送字数
  void getGiveWords() {
    HttpUtils.post(NovelApis.getCommonConfig, {}, success: (data) {
      byDebugPrint(data, tag: "赠送字数");
      giveWords.value = data['data']['gift_word_pack'] ?? 0;
    }, fail: (code, msg) {
      BotToast.showText(text: msg);
    });
  }
}
