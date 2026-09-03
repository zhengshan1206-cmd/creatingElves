
import 'package:fast_creation_master/global/other/illegal_words/controller/illegal_words_controller.dart';
import 'package:get/get.dart';

class IllegalWordsBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>?;
    final novelID = args?['novelID'];
    Get.lazyPut<IllegalWordsController>(
      () => IllegalWordsController(novelID: novelID),
    );
  }
}