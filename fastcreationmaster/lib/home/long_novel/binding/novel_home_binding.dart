/*
 * @Author: cold-x
 * @Date: 2025-06-12 18:56:29
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-08-28 14:25:47
 * @FilePath: /fastcreationmaster/lib/home/long_novel/binding/novel_home_binding.dart
 * @Description: 
 */



import 'package:fast_creation_master/home/long_novel/controller/novel_home_controller.dart';
import 'package:fast_creation_master/home/long_novel/controller/novel_manager_controller.dart';
import 'package:get/get.dart';

class NovelHomeBinding extends Bindings {
  @override
  void dependencies() {
    // 获取传递的参数
    final args = Get.arguments as Map<String, dynamic>?;
    final type = args?['type'];
    final id = args?['id'];
    final selected = args?['select'];
    Get.lazyPut<NovelHomeController>(
      () => NovelHomeController(source: type ?? NovelHomeSourceType.normal, novelID: id ?? 0, selectNovelType: selected),
    );

    Get.lazyPut<NovelManagerController>(
      () => NovelManagerController(),
    );
  }
}