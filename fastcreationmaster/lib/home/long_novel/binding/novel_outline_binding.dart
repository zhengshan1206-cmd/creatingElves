/*
 * @Author: cold-x
 * @Date: 2025-06-17 19:01:27
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-06-30 18:48:13
 * @FilePath: /fastcreationmaster/lib/home/long_novel/binding/novel_outline_binding.dart
 * @Description: 
 */




import 'package:fast_creation_master/home/long_novel/controller/novel_outline_controller.dart';
import 'package:get/get.dart';

class NovelOutlineBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>?;
    final novelID = args?['novelID'];
    Get.lazyPut<NovelOutlineController>(
      () => NovelOutlineController(novelID: novelID),
    );
  }
}