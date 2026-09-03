
import 'package:fast_creation_master/home/share_sales/share_sales_controller.dart';
import 'package:get/get.dart';

class ShareSalesBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => ShareSalesController());
  }

}
