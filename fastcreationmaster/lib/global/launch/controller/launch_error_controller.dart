/*
 * @Author: cold-x
 * @Date: 2025-06-14 14:44:55
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-06-14 14:52:49
 * @FilePath: /fastcreationmaster/lib/global/launch/controller/launch_error_controller.dart
 * @Description: 
 */

import 'package:get/get.dart';

class LaunchErrorController extends GetxController {
  var launching = false.obs;
  var launchFaild = false.obs;
  var progress = 0.0.obs;
  var reTryCount = 0.obs;
}
