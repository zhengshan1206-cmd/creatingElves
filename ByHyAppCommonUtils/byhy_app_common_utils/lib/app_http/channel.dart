/*
 * @Author: cold-x
 * @Date: 2025-07-04 10:57:28
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-09-04 17:23:59
 * @FilePath: /fastcreationmaster/Users/duncy/Desktop/BY/ByHyAppCommonUtils/byhy_app_common_utils/lib/app_http/channel.dart
 * @Description: 
 */
///渠道类型 不同项目 配置不同渠道
enum ChannelType {
  ///华为应用市场
  huawei('231784b1578e1a86', 1951),

  ///快手-磁力聚星
  kwaiMgs('d0d4734827b15d78', 2088),

  ///百度广告-投放
  baiduLaunch('57bc032cecfab9cf', 2024),

  ///百度默认
  baidu('ad95c83cf8513e86', 1950),

  ///应用宝
  tencent('1e6d3d2afc49a11b', 1954),

  ///vivo
  vivo('565f110bbafa50a0', 1953),

  ///小米
  xiaomi('3b2e76567e7795eb', 1952),

  ///oppo
  oppo('cd297144dfc400fd', 1955),

  ///快手
  kwai('5d8769fea61e27a5', 2002),

  ///头条
  headlines('7b00e5cd3e08547f', 2001),

  ///荣耀
  huaweiHonor('c4d994eb1eb3f00c', 1956),

  /// 腾讯投放
  tencentLaunch('c1e1d85b0a00d821', 2043),

  /// 知乎
  zhihu('bddf98571257df09', 2089),

  /// 小红书
  xiaohongshu('6b469e1f23511ca2', 2091),

  ///新图
  xintu('fac9e96d685180ce', 2092),

  ///vivo投放
  vivoStream('3da6b93b8b8df4e6', 2090),

  ///VIVO-LSY-联调
  VIVO_LSY('0c02a84f40e9e0fc', 2049),

  ///vivo-应用投放
  vivoAppStream('77db7e9059f5ece1', 2060),

  ///ios
  iosAppStore("81fc86dce01ddf93", 1957),

  /// 测试
  launchTest("9a0c5a33b4c5cba7", 1938),

  ///
  shareTest("9e3d2dbd27b95353",2126);

  final String channel;
  final num code;

  const ChannelType(this.channel, this.code);
}
