/*
 * @Author: cold-x
 * @Date: 2025-06-12 18:07:37
 * @LastEditors: duncy 474647591@qq.com
 * @LastEditTime: 2026-02-25 19:24:32
 * @FilePath: /fastcreationmaster/lib/global/launch/page/launch_page.dart
 * @Description: 
 */

import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/global/const/asset_const.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../controller/launch_controller.dart';

class LaunchPage extends StatefulWidget {
  const LaunchPage({
    super.key,
  });

  @override
  State<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage> {

  final controller = Get.put(LaunchController(), permanent: true);
  final userController = Get.put(UserController(), permanent: true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        controller.checkAgreement();
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(),
            Positioned.fill(
              child: Image.asset(
                "assets/global/launch/launch_bg${AssetConst.springFestival()}.png",
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
