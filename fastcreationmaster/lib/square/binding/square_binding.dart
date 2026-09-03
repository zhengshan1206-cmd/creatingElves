import 'package:fast_creation_master/square/zone/controller/square_controller.dart';
import 'package:get/get.dart';

class SquareBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SquareController());
  }
}
