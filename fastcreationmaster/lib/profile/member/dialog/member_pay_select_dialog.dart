import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:fast_creation_master/profile/member/controller/member_center_controller.dart';
import 'package:fast_creation_master/profile/member/dialog/member_agree_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class MemberPaySelectDialog extends StatelessWidget {
  MemberPaySelectDialog({
    super.key,
    required this.payList,
    required this.selectedIndex,
  });

  final controller = Get.find<MemberCenterController>();
  final List<Map<String, dynamic>> payList;

  ///选中索引
  final int selectedIndex;

  ///支付列表
  Widget _buildPayList() {
    if (payList.isEmpty) {
      return const Center(
        child: Text(
          '暂无可用支付方式',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }
    return SizedBox(
      height: 58 * payList.length.toDouble(),
      child: GetBuilder<MemberCenterController>(
        id: 'pay_select',
        builder: (_) {
          return ListView.builder(
            itemCount: payList.length,
            itemBuilder: (context, index) {
              final payMethod = payList[index];
              return GestureDetector(
                onTap: () {
                  controller.switchPayMethod(index);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: ByColorUtil.color2E3038,
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            payMethod['icon'] ??
                                'assets/profile/member/member_3.png',
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            payMethod['payName'] ?? '微信支付',
                            style: const TextStyle(
                              fontSize: 14,
                              color: ByColorUtil.colorF1,
                            ),
                          ),
                        ],
                      ),
                      Image.asset(
                        (controller.tabCurrentIndex.value == 0
                                    ? controller.currentPayMethodIndex.value
                                    : controller
                                        .currentWordPackagePayMethodIndex
                                        .value) ==
                                index
                            ? 'assets/profile/member/member_2.png'
                            : 'assets/profile/member/member_1.png',
                        width: 20,
                        height: 20,
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  ///底部按钮
  Widget _buildBottomButton() {
    return GestureDetector(
        onTap: () async {
          Get.back();
          if (!controller.agreementChecked.value) {
            await Get.dialog(const MemberAgreeDialog());
          } else {
            controller.packageBuy();
          }
        },
        child: SizedBox(
          width: double.infinity,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: ByColorUtil.linearGradientMultiple(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF82D7FF),
                    const Color(0xFFBFE0FF),
                    const Color(0xFFDCC8FF),
                  ],
                  stops: [
                    0.1,
                    0.35,
                    0.92
                  ]),
            ),
            child: const Center(
              child: Text(
                '立即支付',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: ByColorUtil.colorF7,
                ),
              ),
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: const BoxDecoration(
        color: ByColorUtil.colorBg2,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '请选择支付方式',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: ByColorUtil.colorF1,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Image.asset(
                  'assets/profile/member/member_close_icon.png',
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildPayList(),
          const SizedBox(height: 8),
          _buildBottomButton(),
        ],
      ),
    );
  }
}
