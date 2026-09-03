/*
 * @Author: cold-x
 * @Date: 2025-07-08 17:42:31
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-09-04 14:22:44
 * @FilePath: /fastcreationmaster/lib/profile/member/binding/member_center_binding.dart
 * @Description: 
 */
import 'package:fast_creation_master/profile/member/controller/member_center_controller.dart';
import 'package:get/get.dart';

class MemberCenterBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>?;
    Get.lazyPut<MemberCenterController>(
      () =>  MemberCenterController(
          isBackHome: args?['isBackHome'] ?? false,
          showSKUDialog: args?['showSKU'] ?? false,
          source: args?['source'] ?? 'unknown',
          payPageStyle: args?['style'] ?? 1,
          payScreenType: args?['type'] ?? 0,
        ));
  }
}
