import 'package:fast_creation_master/square/zone/controller/square_details_controller.dart';
import 'package:get/get.dart';

class SquareDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SquareDetailsController(id: Get.arguments["id"] ?? 0));
  }
}
