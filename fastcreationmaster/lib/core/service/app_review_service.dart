/*
 * @Author: cold-x
 * @Date: 2025-09-02 10:37:06
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-09-02 19:21:57
 * @FilePath: /fastcreationmaster/lib/core/service/app_review_service.dart
 * @Description: 
 */

import 'dart:io';

import 'package:byhy_app_common_utils/app_common/aes/byhy_aes_storage_utils.dart';
import 'package:in_app_review/in_app_review.dart';
import '../../global/const/const.dart';
import '../cache/daily_cache_manager.dart';

///app评分服务
class AppReviewService {
  static void requestReview() async {
    // bool checkDate = await DailyManager.shouldShowPopup(Consts.kAppStoreReviewCheck, type: DailyManagerType.twentyfourHous);
    if(!Platform.isIOS) {
      return;
    }
    final int? date = ByStorageUtils.getInt(Consts.kAppStoreReviewCheck);
    if(date != null && date > 0) {
      return;
    }
    final InAppReview inAppReview = InAppReview.instance;
    final bool available = await inAppReview.isAvailable();
    /// 记录当前日期
    DailyManager.recordPopupDate(Consts.kAppStoreReviewCheck, type: DailyManagerType.twentyfourHous);
    if (available) {
      ///拉取评分弹窗
      inAppReview.requestReview();
    }
    // else {
    //   ///去苹果商店评分
    //   inAppReview.openStoreListing(appStoreId: Consts.kAppStoreID);
    // }
  }
}
