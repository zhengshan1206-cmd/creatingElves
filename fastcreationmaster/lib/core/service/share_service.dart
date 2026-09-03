/*
 * @Author: cold-x
 * @Date: 2025-07-04 16:08:36
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-07-04 16:19:53
 * @FilePath: /fastcreationmaster/lib/core/service/share_service.dart
 * @Description: 
 */


import 'package:share_plus/share_plus.dart';

///分享服务
class ShareService {

  ///分享文件、图片
  static Future<void> shareFile(String filePath,
  {
    String? desc = '1', 
    void Function()? success}) async {
    final params = ShareParams(
      text: desc,
      files: [XFile(filePath)],
    );
    final result = await SharePlus.instance.share(params);
    if (result.status == ShareResultStatus.success) {
      success?.call();
    }
  }
}
