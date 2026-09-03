/*
 * @Author: cold-x
 * @Date: 2025-06-12 15:40:13
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-06-12 15:41:34
 * @FilePath: /fastcreationmaster/lib/core/util/clipboard.dart
 * @Description: 
 */


import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/services.dart';

class ClipboardManager {
  static void clip(String? content) {
    Clipboard.setData(
      ClipboardData(
        text: content ?? '',
      ),
    );
    BotToast.showText(text: "复制成功");
  }
}