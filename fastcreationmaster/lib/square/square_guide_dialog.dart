import 'package:fast_creation_master/core/controller/user_controller.dart';
import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:fast_creation_master/profile/member/widget/scale_transition_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'dart:ui';

class SquareGuideDialog extends StatelessWidget {
  SquareGuideDialog({super.key});

  final userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 44),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                height: 357,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                    image: AssetImage('assets/square/square_dialog_1.png'),
                    fit: BoxFit.contain,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      margin: const EdgeInsets.only(left: 26, top: 105),
                      child: Image.asset(
                        'assets/square/square_dialog_2.png',
                        height: 26,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Image.asset(
                      'assets/square/square_dialog_3.png',
                      height: 35,
                      fit: BoxFit.fitHeight,
                    ),
                    const SizedBox(height: 70),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 42),
                      child: ScaleTransitionWidget(
                        child: GestureDetector(
                          onTap: () => {
                            Get.back(),
                            userController.checkPreLogin(source: 'square_guide', actionCallback: () {
                              userController.jumpToPayPage(source: 'square_guide');
                            })
                          },
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(46),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '立即开通',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: ByColorUtil.colorF1,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Image.asset(
                  'assets/square/square_dialog_4.png',
                  height: 32,
                  width: 32,
                  fit: BoxFit.fill,
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
