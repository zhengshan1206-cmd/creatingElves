/*
 * @Author: cold-x
 * @Date: 2025-06-09 19:51:33
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-09-02 10:44:38
 * @FilePath: /fastcreationmaster/lib/global/const/const.dart
 * @Description: 
 */
class Consts {
  static const kSystemAndroid = "android";
  static const kSystemIOS = "ios";

  ///苹果appstoreID
  static const kAppStoreID = "6747186147";

  /// 启动时，用户协议是否已同意
  static const kPrivacyChecked = "kPrivacyChecked";
  static const kSPPrivacyChecked = "kSPPrivacyChecked";

  /// 启动时，用户是否已经过引导页
  static const kLaunchGuideCheck = 'kLaunchGuideCheck';
  static const kUserEnteredGuide = 'kUserEnteredGuide';

  /// 付费页关闭时的二次关闭弹窗确认
  static const kCancelPaySecondTime = 'kCancelPaySecondTime';
  static const kCancelPaySecondTimeDuration = 10 * 60 * 1000;

  /// 未完成小说每日弹窗提示
  static const kDailyUncompleteNovel = 'kDailyUncompleteNovel';

  /// appstore评分弹窗提示
  static const kAppStoreReviewCheck = 'kAppStoreReviewCheck';

  ///版本更新弹窗
  static const kAppVersionDialog = 'kAppVersionDialog';

  ///是否进入过付费页状态
  static const kEnterPayPage = 'kEnterPayPage';

  ///二次付费引导显示状态
  static const kSecondPayGuideShow = 'kSecondPayGuideShow';

  ///二次付费引导开始时间
  static const kSecondPayGuideStartTime = 'kSecondPayGuideStartTime';

  static const ratiosMap = {
    "1:1": 1 / 1,
    "3:4": 3 / 4,
    "4:3": 4 / 3,
    "16:9": 16 / 9,
    "9:16": 9 / 16,
  };
}
