import 'package:fast_creation_master/core/controller/base_record_controller.dart';
import 'package:get/get.dart';

class RecordBinding extends Bindings {
  @override
  void dependencies() {
    // 获取传递的参数
    final args = Get.arguments as Map<String, dynamic>?;
    final type = args?['type'];
    Get.lazyPut<BaseRecordController>(
      () => BaseRecordController(type: type),
    );
  }
}
