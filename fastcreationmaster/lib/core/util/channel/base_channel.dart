/*
 * @Author: cold-x
 * @Date: 2025-04-14 17:58:13
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-06-09 11:21:40
 * @FilePath: /fastcreationmaster/lib/core/util/channel/base_channel.dart
 * @Description: 
 */
import 'package:flutter/services.dart';

import 'channel_api.dart';

class BaseChannel {
  late var channel;

  factory BaseChannel() => _singleton;

  BaseChannel._() {
    channel = const MethodChannel(ChannelApi.channelIdentifier);
  }

  static final BaseChannel _singleton = BaseChannel._();

  static BaseChannel get instance => BaseChannel();

  Future<dynamic> callNativeMethod(String method, {dynamic params}) async {
    try {
      final result = await channel.invokeMethod(
        method,
        params,
      );
      // byDebugPrint(
      //   "${result ?? "null"}<>${method}<>${params ?? "null"}",
      //   tag: "<><><><><><><>BaseChannel<><><><><><><>",
      // );

      return result != null
          ? result["code"] == ChannelApi.channelSuccess
              ? result["data"]
              : Future.error(result["msg"] ??= "")
          : result;
    } on Exception catch (e) {
      return Future.error(e);
    }
  }
}
