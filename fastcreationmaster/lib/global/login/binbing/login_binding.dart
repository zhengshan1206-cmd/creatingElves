/*
 * @Author: duncy
 * @Date: 2025-07-04 10:57:28
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-01-27 15:05:18
 * @FilePath: /fastcreationmaster/lib/global/login/binbing/login_binding.dart
 * @Description: 
 */
import 'package:fast_creation_master/global/login/controller/login_controller.dart';
import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments ?? {};
    Get.put<LoginController>(LoginController(
      isBindMode: args["isBind"] ?? false,
      showClose: args["showClose"] ?? true,
      onLoginSuccessCallback: args["onLoginSuccess"],
    ));
  }
}
