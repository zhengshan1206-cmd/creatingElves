/*
 * @Author: cold-x
 * @Date: 2025-06-12 16:05:10
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-06-12 17:52:39
 * @FilePath: /fastcreationmaster/lib/home/tool/binding/name_finish_binding.dart
 * @Description: 
 */



import 'package:fast_creation_master/home/tool/controller/name_finish_controller.dart';
import 'package:get/get.dart';

class NameFinishBinding extends Bindings {
  @override
  void dependencies() {
    // 获取传递的参数
    final args = Get.arguments as Map<String, dynamic>?;
    final ids = args?['ids'];
    final type = args?['type'];
    final params = args?['params'];
    final titles = args?['titles'];
    Get.lazyPut<NameFinishController>(
      () => NameFinishController(creationIDs: ids, type: type, params: params, itemTitles: titles),
    );
  }
}