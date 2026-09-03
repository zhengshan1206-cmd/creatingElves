/*
 * @Author: cold-x
 * @Date: 2025-06-17 19:01:51
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-06-27 12:20:25
 * @FilePath: /fastcreationmaster/lib/home/long_novel/binding/novel_chapter_binding.dart
 * @Description: 
 */







import 'package:fast_creation_master/home/long_novel/controller/novel_chapter_controller.dart';
import 'package:get/get.dart';

class NovelChapterBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>?;
    final novelID = args?['novelID'];
    final outlineID = args?['outlineID'];
    Get.lazyPut<NovelChapterController>(
      () => NovelChapterController(novelID: novelID, outlineID: outlineID),
    );
  }
}