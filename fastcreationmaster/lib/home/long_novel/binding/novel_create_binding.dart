/*
 * @Author: cold-x
 * @Date: 2025-06-16 20:32:39
 * @LastEditors: cold-x 474647591@qq.com
 * @LastEditTime: 2025-08-19 18:41:29
 * @FilePath: /fastcreationmaster/lib/home/long_novel/binding/novel_create_binding.dart
 * @Description: 
 */



import 'package:fast_creation_master/core/controller/base_record_controller.dart';
import 'package:fast_creation_master/home/long_novel/controller/novel_create_controller.dart';
import 'package:fast_creation_master/home/long_novel/controller/novel_home_controller.dart';
import 'package:get/get.dart';

class NovelCreateBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>?;
    final params = args?['params'];
    final source = args?['type'];
    final id = args?['id'];
    var novelType = args?['novel_type'];
    bool isProfessional = false;
    ///写同款
    if(params != null) {
      final func = args?['func'];
      if(func.contains('short_novel')){
        novelType = CreationType.shortNovel;
        isProfessional = func.contains('professional');
      }
      else if(func.contains('long_novel')){
        novelType = CreationType.novel;
        isProfessional = func.contains('professional');
      }
      else {
        novelType = CreationType.shortStory;
      }
    }
    Get.lazyPut<NovelCreateController>(
      () => NovelCreateController(
        writeArgs: params, 
        type: novelType ?? CreationType.novel, 
        isProfessional: isProfessional,
        source: source ?? NovelHomeSourceType.normal,
        squareID: id ?? 0),
    );
  }
}