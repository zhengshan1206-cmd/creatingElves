/*
 * @Author: cold-x
 * @Date: 2025-06-04 09:23:10
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-08-11 11:28:26
 * @FilePath: /fastcreationmaster/Users/duncy/Desktop/BY/ByHyAppCommonUtils/byhy_app_common_utils/lib/app_common/consts/environment.dart
 * @Description: 
 */

// ignore_for_file: constant_identifier_names
enum Environment {
  TEST('https://inchattest.mianfeiread.com/'),
  PRODUCTION('https://inchat.beiyinapp.com/');

  final String domain;
  const Environment(this.domain);

  bool get isProduction => this == Environment.PRODUCTION;
}