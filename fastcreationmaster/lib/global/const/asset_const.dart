/*
 * @Author: duncy
 * @Date: 2026-01-29 16:11:59
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-02-24 17:38:48
 * @FilePath: /fastcreationmaster/lib/global/const/asset_const.dart
 * @Description: 
 */


class AssetConst {


  static String springFestival() {

    final DateTime now = DateTime.now();
    final DateTime targetDate = DateTime(2026, 2, 25);
    /// 比较当前日期是否大于目标日期
    final bool isAfterTarget = now.isAfter(targetDate);
    if(isAfterTarget) {
      return '';
    }
    return '';
    // return '_spring';
  }
}