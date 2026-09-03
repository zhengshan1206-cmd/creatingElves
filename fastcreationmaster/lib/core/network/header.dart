import 'package:flutter/services.dart';
import '../util/channel/channel_api.dart';

class UserAgentUtil {
  // 定义原生通道名称（需与原生代码一致）
  static const MethodChannel _channel = MethodChannel(ChannelApi.channelIdentifier);

  // 获取设备User-Agent
  static Future<String?> getUserAgent() async {
    try {
      // 调用原生方法
      final String? userAgent = await _channel.invokeMethod('getUserAgent');
      return userAgent;
    } on PlatformException catch (e) {
      print('获取User-Agent失败: ${e.message}');
      return null;
    }
  }
}