/*
 * @Author: cold-x
 * @Date: 2025-06-24 09:15:20
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-08-07 14:01:29
 * @FilePath: /fastcreationmaster/lib/global/launch/binding/guide_binding.dart
 * @Description: 
 */
import 'package:get/get.dart';

import '../controller/guide_controller.dart';

class GuideBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(GuideController());
  }
}