import 'package:get/get.dart';
import 'package:fast_creation_master/square/zone/controller/square_zone_controller.dart';

class SquareZoneBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SquareZoneController(
        id: Get.arguments?["id"] ?? 0,
        iconUrl: Get.arguments?["iconUrl"] ?? ""));
  }
}
