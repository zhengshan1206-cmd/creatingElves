
import 'package:fast_creation_master/home/share_sales/profit_list_view/profit_list_controller.dart';
import 'package:get/get.dart';

class ProfitListBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => ProfitListController());
  }

}