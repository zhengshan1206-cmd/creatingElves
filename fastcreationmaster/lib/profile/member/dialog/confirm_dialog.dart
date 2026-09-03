import 'package:fast_creation_master/global/ui/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog(
      {super.key,
      required this.title,
      required this.content,
      required this.onConfirm,
      required this.onCancel,
      this.confirmText = '确定',
      this.cancelText = '取消',
      this.height = 240});
  final String title;
  final String content;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String confirmText;
  final String cancelText;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 327,
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: ByColorUtil.colorBg2,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    color: ByColorUtil.colorF1,
                    decoration: TextDecoration.none,
                  ),
                ),
                GestureDetector(
                  onTap: () => {Get.back()},
                  child: Image.asset(
                    'assets/profile/member/member_close_icon.png',
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: content,
                    style: const TextStyle(
                      fontSize: 15,
                      color: ByColorUtil.colorF1,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                      onCancel();
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: ByColorUtil.color2E3038,
                      ),
                      child: Center(
                        child: Text(
                          cancelText,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            color: ByColorUtil.colorF2,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                      onConfirm();
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: ByColorUtil.colorG4,
                      ),
                      child: Center(
                        child: Text(
                          confirmText,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: ByColorUtil.colorF1,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
