/*
 * @Author: cold-x
 * @Date: 2025-06-10 15:17:38
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-06-24 14:19:51
 * @FilePath: /fastcreationmaster/lib/home/tool/binding/tool_create_binding.dart
 * @Description: 
 */


import 'package:fast_creation_master/home/tool/controller/tool_create_controller.dart';
import 'package:get/get.dart';

class ToolCreateBinding extends Bindings {
  @override
  void dependencies() {
    // 获取传递的参数
    final args = Get.arguments as Map<String, dynamic>?;
    final type = args?['type'];
    Get.put<ToolCreateController>(
      ToolCreateController(type: type),
    );
  }
}